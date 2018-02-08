//
//  ParallelFlock_iOSTests.swift
//  ParallelFlock-iOSTests
//
//  Created by Leo Dion on 2/7/18.
//  Copyright © 2018 Bright Digit, LLC. All rights reserved.
//

import XCTest
@testable import ParallelFlock

extension UUID {
  static func random (_: Int) -> UUID {
    return UUID()
  }
}
class ParallelFlock_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      let uuids = (0...200).map(UUID.random)
      
      let exp = expectation(description: "completed conversion")
      
      var op : ParallelMapOperation<UUID, String>?
      let operation = uuids.parallel.map({ (uuid, completion : @escaping (String) -> Void) in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
          if let progress = op?.progress {
            print(progress)
          }
          completion(uuid.uuidString)
        })
      }) { (result) in
        XCTAssertEqual(result.count, uuids.count)
        
        exp.fulfill()
      }
      
      op = operation
      
      wait(for: [exp], timeout: 300)
    }
  
    
}
