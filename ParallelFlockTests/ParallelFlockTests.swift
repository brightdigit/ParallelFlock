@testable import ParallelFlock
import XCTest

extension UUID {
  static func random(_: Int) -> UUID {
    return UUID()
  }
}

extension Array: DefaultInitializable {
}

extension UInt32: DefaultInitializable {
}

extension String: DefaultInitializable {
}

class StringClass: DefaultInitializable {
  let string: String

  init(string: String) {
    self.string = string
  }

  required init() {
    self.string = String()
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

  func testArrayDynamicMap() {
    let exp = expectation(description: "completed conversion")

    _ = (0 ... 100).map { $0 }.parallel.map({ $1(StringClass(string: String(repeating: "a", count: $0))) }, completion: { result in
      for (count, string) in result.enumerated() {
        XCTAssertEqual(string.string.count, count)
      }
      exp.fulfill()
    })

    wait(for: [exp], timeout: 300)
  }

  func testArrayMap() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let uuids = (0 ... 5000).map(UUID.random)

    let exp = expectation(description: "completed conversion")

    let group = DispatchGroup()

    var expected: [String]!
    var actual: [String]!

    group.enter()

    let operation = uuids.parallel.map({ (uuid, completion) -> Void in
      completion(uuid.uuidString)
    }) { result in
      actual = result
      group.leave()
    }

    group.enter()
    DispatchQueue.main.async {
      expected = uuids.map { $0.uuidString }
      group.leave()
    }

    group.notify(queue: .main) {
      XCTAssertEqual(expected, actual)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 300)
  }
}
