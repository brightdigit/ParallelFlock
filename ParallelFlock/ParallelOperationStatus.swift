//
//  Parallel.swift
//  ParallelFlock
//
//  Created by Leo Dion on 2/7/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import Foundation


public enum ParallelOperationStatus<U>  {
  case initialized
  case running(Int)
  case completed(U)
}