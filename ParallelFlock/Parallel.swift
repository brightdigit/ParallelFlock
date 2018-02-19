import Foundation

public class Parallel<T> {
  public let source: [T]

  public init(source: [T]) {
    self.source = source
  }
}

public extension Array {
  public var parallel: Parallel<Element> {
    return Parallel(source: self)
  }
}

extension Parallel {
  func map<U>(
    _ each: @escaping ParallelMapItemClosure<T, U>,
    completion: @escaping ParallelMapCompletionClosure<U>) -> ParallelMapOperation<T, U> {
    let operation = ParallelMapOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }

  func reduce(
    _ each: @escaping ParallelReduceItemClosure<T>,
    completion: @escaping ParallelCompletionClosure<T>) -> ParallelReduceOperation<T> {
    let operation = ParallelReduceOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }
}
