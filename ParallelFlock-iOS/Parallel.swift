//
//  Parallel.swift
//  ParallelFlock-iOS
//
//  Created by Leo Dion on 2/7/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import Foundation

public struct Parallel<T> {
  public let source : Array<T>
  
  public func map<U>(_ each: @escaping (T, (U)->Void) -> Void, completion: @escaping ((Array<(T,U)>) -> Void)) {
    let arrayQueue = DispatchQueue(label: "io.zamzam.ZamzamKit.SynchronizedArray", attributes: .concurrent)

    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    var results = Array<(T,U)?>.init(repeating: nil, count: source.count)
    for (index, item) in source.enumerated() {
      debugPrint("group entered", item)
      group.enter()
      queue.async(group: group, execute: {
        each(item, { (result) in
          debugPrint("group start", item, results.count)

          results[index] = (item, result)
          group.leave()
          debugPrint("group leave", item, results.count)
//          arrayQueue.async(group: nil, qos: DispatchQoS.default, flags: DispatchWorkItemFlags.barrier, execute: {
//
//            results.append((item, result))
//            group.leave()
//            debugPrint("group leave", item, results.count)
//          })
        })
      })
    }
    
    group.notify(queue: queue) {
      completion(results.flatMap{$0})
    }
  }
}
