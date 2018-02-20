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
  func async(_ closure: @escaping (T, T) -> T) -> ParallelReduceItemClosure<T> {
    return {
      $2(closure($0, $1))
    }
  }

  func async<U>(_ closure: @escaping (T) -> U) -> ParallelMapItemClosure<T, U> {
    return {
      $1(closure($0))
    }
  }

  func map<U>(
    _ each: @escaping ParallelMapItemClosure<T, U>,
    completion: @escaping ParallelMapCompletionClosure<U>) -> ParallelMapOperation<T, U> {
    let operation = ParallelMapOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }

  func map<U>(
    _ each: @escaping (T) -> U,
    completion: @escaping ParallelMapCompletionClosure<U>) -> ParallelMapOperation<T, U> {
    return self.map(self.async(each), completion: completion)
  }

  func reduce(
    _ each: @escaping ParallelReduceItemClosure<T>,
    completion: @escaping ParallelCompletionClosure<T>) -> ParallelReduceOperation<T> {
    let operation = ParallelReduceOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }

  func reduce(
    _ each: @escaping (T, T) -> T,
    completion: @escaping ParallelCompletionClosure<T>) -> ParallelReduceOperation<T> {
    return self.reduce(self.async(each), completion: completion)
  }
}
