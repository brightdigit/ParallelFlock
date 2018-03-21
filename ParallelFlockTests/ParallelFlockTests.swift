@testable import ParallelFlock
import XCTest

extension UUID {
  static func random(_: Int) -> UUID {
    return UUID()
  }
}

class StringClass {
  let string: String

  init(string: String) {
    self.string = string
  }

  init() {
    self.string = String()
  }
}
class ParallelFlockTests: XCTestCase {
  class OperationWatcher<T> where T: ParallelOperation {
    let operation: T
    var prevProgress = 0.0

    init(operation: T) {
      self.operation = operation
    }

    @objc func onTimer(_: Timer) {
      XCTAssertGreaterThanOrEqual(self.operation.progress, self.prevProgress)
      self.prevProgress = self.operation.progress
      print(self.operation.progress)
    }
  }

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

    _ = (0 ... 100).map { $0 }.parallel.map({ StringClass(string: String(repeating: "a", count: $0)) }) { result in
      for (count, string) in result.enumerated() {
        XCTAssertEqual(string.string.count, count)
      }
      exp.fulfill()
    }

    wait(for: [exp], timeout: 300)
  }

  func testArrayMap() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let uuids = (0 ... 50000).map(UUID.random)

    let exp = expectation(description: "completed conversion")

    let group = DispatchGroup()

    var expected: [String]!
    var actual: [String]!
    var timer: Timer?

    group.enter()

    let operation = uuids.parallel.map({ (uuid) -> String in
      uuid.uuidString
    }) { result in
      timer?.invalidate()
      timer = nil
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

    let watcher = OperationWatcher(operation: operation)

    timer = Timer.scheduledTimer(
      timeInterval: 0.1,
      target: watcher,
      selector: #selector(OperationWatcher<ParallelMapOperation<UUID, String>>.onTimer(_:)),
      userInfo: nil, repeats: true)

    timer?.fire()
    wait(for: [exp], timeout: 300)
  }

  func testArrayReduce() {
    let exp = expectation(description: "completed conversion")
    let numbers = (0 ... 5000).map { _ in arc4random_uniform(200) + 1 }
    let actualSum = numbers.reduce(0, +)
    _ = numbers.parallel.reduce(+, completion: { result in

      XCTAssertEqual(result, actualSum)

      exp.fulfill()
    })
    wait(for: [exp], timeout: 300)
  }
}
