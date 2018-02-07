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
      let uuids = (0...5).map(UUID.random)
      
      let exp = expectation(description: "completed conversion")
      let parallel = Parallel(source: uuids)
      
      parallel.map({ (uuid, completion : (String) -> Void) in
        let nsuuid = uuid as NSUUID
        var bytes = [UInt8]()
        nsuuid.getBytes(&bytes)
        let data = Data(bytes: bytes)
        let string : String = Base32Encode(data: data)
        completion(string)
      }) { (result) in
        print(result)
        XCTAssertEqual(result.count, uuids.count)
        
        exp.fulfill()
      }
      
      wait(for: [exp], timeout: 300)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
