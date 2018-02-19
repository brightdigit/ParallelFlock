//
//  Parallel.swift
//  ParallelFlock
//
//  Created by Leo Dion on 2/7/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import Foundation

public protocol ParallelOperation {
  func begin ()
  var sourceCount : Int { get }
  var completedCount : Int { get }
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