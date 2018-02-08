//
//  Parallel.swift
//  ParallelFlock-iOS
//
//  Created by Leo Dion on 2/7/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import Foundation

public typealias ParallelMapItemClosure<T, U> = (T, @escaping (U)->Void) -> Void
public typealias ParallelMapCompletionClosure<U> = (Array<U>) -> Void

public enum ParallelOperationStatus<U>  {
  case initialized
  case running(Int)
  case completed(U)
}

public class ParallelMapOperation<T,U> {
  public let source : Array<T>
  public let itemClosure : ParallelMapItemClosure<T, U>
  public let completion: ParallelMapCompletionClosure<U>
  public let queue : DispatchQueue
  public let arrayQueue : DispatchQueue
  
  public private(set) var status : ParallelOperationStatus<Array<U>> = .initialized
  public private(set) var temporaryResult : Array<U?>

  public init (source: Array<T>, itemClosure: @escaping ParallelMapItemClosure<T,U>, completion: @escaping ParallelMapCompletionClosure<U>, queue: DispatchQueue? = nil, arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.itemClosure = itemClosure
    self.completion = completion
    self.queue = queue ?? DispatchQueue.global()
    self.arrayQueue = arrayQueue ?? DispatchQueue(label: "arrayQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    self.temporaryResult = Array<U?>.init(repeating: nil, count: self.source.count)
  }
  
  public func begin () {
    
    switch self.status {
    case .initialized:
      break
    default:
      return
    }
    
    var count = 0
    self.status = .running(0)
    let group = DispatchGroup()
  
    for (index, item) in self.source.enumerated() {
      group.enter()
      queue.async(execute: {
        self.itemClosure(item, { (result) in
          self.arrayQueue.async(group: nil, qos: .default, flags: .barrier, execute: {
            self.temporaryResult[index] = result
            count += 1
            self.status = .running(count)
            
            group.leave()
          })
        })
      })
    }
      
      group.notify(queue: self.queue, execute: {
        let result = self.temporaryResult.compactMap{$0}
        assert(result.count == self.source.count)
        self.status = .completed(result)
        self.completion(result)
      })
  }
  
}

extension ParallelMapOperation {
  public var progress : Double {
    return Double(self.completedCount) / Double(self.source.count)
    
  }
  
  public var completedCount : Int {
    switch self.status {
      
    case .initialized:
      return 0
    case .running(let count):
      return count
    case .completed(_):
      return source.count
    }
  }
}

public class Parallel<T> {
  public let source : Array<T>
  
  public init (source: Array<T>) {
    self.source = source
  }
}

extension Array {
  public var parallel : Parallel<Element>  {
    return Parallel(source: self)
  }
}

extension Parallel {
  func map<U>(_ each: @escaping ParallelMapItemClosure<T,U>, completion: @escaping ParallelMapCompletionClosure<U>) -> ParallelMapOperation<T, U> {
    let operation = ParallelMapOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }
}

