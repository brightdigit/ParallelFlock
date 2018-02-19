@testable import ParallelFlock
import XCTest

extension UUID {
  static func random(_: Int) -> UUID {
    return UUID()
  }
}
class ParallelFlockTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

  func testArrayMap() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let uuids = (0 ... 5000).map(UUID.random)

    let exp = expectation(description: "completed conversion")

    var op: ParallelMapOperation<UUID, String>?
    let operation = uuids.parallel.map({ (uuid, completion: @escaping (String) -> Void) in
      DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
        if let progress = op?.progress {
          print(progress)
        }
        completion(uuid.uuidString)
      })
    }, completion: { result in
      XCTAssertEqual(result.count, uuids.count)

      exp.fulfill()
    })

    op = operation

    wait(for: [exp], timeout: 300)
  }

  func testArrayReduce() {
    let exp = expectation(description: "completed conversion")
    let numbers = (0 ... 5000).map { _ in arc4random_uniform(200) + 1 }
    let actualSum = numbers.reduce(0, +)
    var op: ParallelReduceOperation<UInt32>?
    let operation = numbers.parallel.reduce({ lhs, rhs, completion -> Void in
      DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
        if let progress = op?.progress {
          print(progress)
        }
        completion(lhs + rhs)
      })
    }, completion: { result in

      XCTAssertEqual(result, actualSum)

      exp.fulfill()
    })
    op = operation
    wait(for: [exp], timeout: 300)
  }
}
