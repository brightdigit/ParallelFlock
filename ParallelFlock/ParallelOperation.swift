import Foundation

public protocol ParallelOperation {
  associatedtype InputElementType
  associatedtype OutputType
  func begin()
  var source: [InputElementType] { get }
  var status: ParallelOperationStatus<OutputType> { get }
}

public extension ParallelOperation {
  public var progress: Double {
    switch self.status {
    case .initialized:
      return 0.0
    case .completed:
      return 1.0
    case let .running(count):
      return Double(count) / Double(source.count)
    }
  }
}
