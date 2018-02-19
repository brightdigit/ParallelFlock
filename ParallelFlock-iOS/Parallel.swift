//
//  Parallel.swift
//  ParallelFlock
//
//  Created by Leo Dion on 2/7/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import Foundation

public typealias ParallelMapItemClosure<T, U> = (T, @escaping (U)->Void) -> Void
public typealias ParallelCompletionClosure<T> = (T) -> Void
public typealias ParallelMapCompletionClosure<U> = ParallelCompletionClosure<Array<U>>
public typealias ParallelReduceItemClosure<T> = (T, T, @escaping (T) -> Void) -> Void

public protocol ParallelOperation {
  func begin ()
  var sourceCount : Int { get }
  var completedCount : Int { get }
}

public struct ParallelOptions {
  public static let defaultQos : DispatchQoS = {
    if #available(OSXApplicationExtension 10.10, *) {
      return DispatchQoS.default
    } else {
      return DispatchQoS.unspecified
    }
  }()
  
  public static let defaultQueue : DispatchQueue = {
    if #available(OSXApplicationExtension 10.10, *) {
      return DispatchQueue.global()
    } else {
      return DispatchQueue(label: UUID.init().uuidString)
    }
  }()
}

public enum ParallelOperationStatus<U>  {
  case initialized
  case running(Int)
  case completed(U)
}

public class ParallelReduceOperation<T>  {
  
  public let source : Array<T>
  public let itemClosure : ParallelReduceItemClosure<T>
  public let completion: ParallelCompletionClosure<T>
  public let queue : DispatchQueue
  public let arrayQueue : DispatchQueue
  
  public private(set) var status : ParallelOperationStatus<T> = .initialized
  public private(set) var temporaryResult : Array<T>
  public private(set) var iterationCount = 0
  
  public var sourceCount: Int {
    return self.source.count
  }
  public var maxIterations : Int {
    return Int(ceil(log2(Double(self.source.count))))
  }
  
  public init (source: Array<T>, itemClosure: @escaping ParallelReduceItemClosure<T>, completion: @escaping ParallelCompletionClosure<T>, queue: DispatchQueue? = nil, arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.itemClosure = itemClosure
    self.completion = completion
    self.queue = queue ?? ParallelOptions.defaultQueue
    
      self.arrayQueue = arrayQueue ?? DispatchQueue(label: "arrayQueue", qos: ParallelOptions.defaultQos, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)

    
    self.temporaryResult = source
  }
  
  public func begin () {
    switch self.status {
    case .initialized:
      break
    default:
      return
    }
    self.status = .running(0)
    self.iterate()
    
  }
  
  public func iterate () {
    if self.iterationCount <= self.maxIterations && self.temporaryResult.count > 1 {
      self.iterationCount += 1
      let right = self.temporaryResult[self.temporaryResult.count/2..<self.temporaryResult.count]
      let left = self.temporaryResult[0..<self.temporaryResult.count/2]
      let zipValues = zip(left, right)
      var values = Array<T>()
      let group = DispatchGroup()
      for (left, right) in zipValues {
        group.enter()
        queue.async {
          self.itemClosure(left, right, { (reduced) in
            self.arrayQueue.async(group: nil, qos: ParallelOptions.defaultQos, flags: .barrier, execute: {
              values.append(reduced)
              group.leave()
            })
          })
        }
      }
      group.notify(queue: queue) {
        if let last = right.last, right.count != left.count {
          values.append(last)
        }
        self.temporaryResult = values
        self.status = .running(self.source.count  - values.count)
        self.iterate()
      }
    } else {
      assert(self.temporaryResult.count == 1)
      let result = self.temporaryResult.first!
        self.status = .completed(result)
        self.completion(result)
      
    }
  }
}

public class ParallelMapOperation<T,U> {
  public let source : Array<T>
  public let itemClosure : ParallelMapItemClosure<T, U>
  public let completion: ParallelMapCompletionClosure<U>
  public let queue : DispatchQueue
  public let arrayQueue : DispatchQueue
  
  public private(set) var status : ParallelOperationStatus<Array<U>> = .initialized
  public private(set) var temporaryResult : Array<U?>

  public var sourceCount: Int {
    return self.source.count
  }
  public init (source: Array<T>, itemClosure: @escaping ParallelMapItemClosure<T,U>, completion: @escaping ParallelMapCompletionClosure<U>, queue: DispatchQueue? = nil, arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.itemClosure = itemClosure
    self.completion = completion
    self.queue = queue ?? ParallelOptions.defaultQueue
    self.arrayQueue = arrayQueue ?? DispatchQueue(label: "arrayQueue", qos: ParallelOptions.defaultQos, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
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
          self.arrayQueue.async(group: nil, qos: ParallelOptions.defaultQos, flags: .barrier, execute: {
            self.temporaryResult[index] = result
            count += 1
            self.status = .running(count)
            
            group.leave()
          })
        })
      })
    }
      
      group.notify(queue: self.queue, execute: {
        let result : Array<U>
        #if swift(>=4.1)
          result = self.temporaryResult.compactMap{$0}
        #else
          result = self.temporaryResult.flatMap{$0}
        #endif
        assert(result.count == self.source.count)
        self.status = .completed(result)
        self.completion(result)
      })
  }
  
}

extension ParallelOperation {
  public var progress : Double {
    return Double(self.completedCount) / Double(self.sourceCount)
    
  }
}

extension ParallelReduceOperation : ParallelOperation {
  
  
  public var completedCount : Int {
    switch self.status {
      
    case .initialized:
      return 0
    case .running(let count):
      return count
    case .completed(_):
      return sourceCount
    }
  }
}

extension ParallelMapOperation : ParallelOperation {

  
  public var completedCount : Int {
    switch self.status {
      
    case .initialized:
      return 0
    case .running(let count):
      return count
    case .completed(_):
      return sourceCount
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
  
  func reduce(_ each: @escaping ParallelReduceItemClosure<T>, completion: @escaping ParallelCompletionClosure<T>) -> ParallelReduceOperation<T> {
    let operation = ParallelReduceOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }
}

