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

  func testPerformanceMap() {
    // This is an example of a performance test case.

    self.measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
      let expect = expectation(description: "map completed")
      let source = [Void](repeating: Void(), count: 100_000_000)

      startMeasuring()
      _ = source.parallel.map({ _ in arc4random_uniform(UInt32.max) }, completion: { _ in
        expect.fulfill()
      })
      waitForExpectations(timeout: 10000) { error in
        XCTAssertNil(error)
        self.stopMeasuring()
      }
    }
  }

  func testArrayMap() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let uuids = (0 ... 50000).map(UUID.random)

    let exp = expectation(description: "completed conversion")

    var progress = 0.0
    let group = DispatchGroup()

    var expected: [String]!
    var actual: [String]!

    let operation: ParallelMapOperation<UUID, String>?
    group.enter()
    operation = uuids.parallel.map({
      $0.uuidString
    }, completion: { result in
      actual = result
      group.leave()
    })

    group.enter()
    DispatchQueue.main.async {
      expected = uuids.map { $0.uuidString }
      group.leave()
    }

    group.notify(queue: .main) {
      XCTAssertEqual(expected, actual)
      exp.fulfill()
    }

    if #available(iOS 10.0, *) {
      let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        guard let operation = operation else {
          return
        }
        XCTAssertGreaterThan(operation.progress, progress)
        progress = operation.progress
      }
    } else {
      // Fallback on earlier versions
    }

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
