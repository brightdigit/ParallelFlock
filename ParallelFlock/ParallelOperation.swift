import Foundation

public protocol ParallelOperation {
  func begin()
  var sourceCount: Int { get }
  var completedCount: Int { get }
}

extension ParallelOperation {
  public var progress: Double {
    return Double(self.completedCount) / Double(self.sourceCount)
  }
}

extension ParallelReduceOperation: ParallelOperation {

  public var completedCount: Int {
    switch self.status {

    case .initialized:
      return 0
    case let .running(count):
      return count
    case .completed:
      return sourceCount
    }
  }
}

extension ParallelMapOperation: ParallelOperation {

  public var completedCount: Int {
    switch self.status {

    case .initialized:
      return 0
    case let .running(count):
      return count
    case .completed:
      return sourceCount
    }
  }
}
