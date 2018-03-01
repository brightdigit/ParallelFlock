@testable import ParallelFlock
import XCTest

class ParallelFlockPerformanceTests: XCTestCase {
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
      let source = [Void](repeating: Void(), count: 100_000)

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
}
