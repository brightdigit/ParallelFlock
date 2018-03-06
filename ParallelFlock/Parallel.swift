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

public extension Parallel {
  public func map<U>(
    _ each: @escaping (T, @escaping (U) -> Void) -> Void,
    completion: @escaping ([U]) -> Void) -> ParallelMapOperation<T, U> {
    let operation = ParallelMapOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }
}
