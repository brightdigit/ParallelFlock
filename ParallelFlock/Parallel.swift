import Foundation

/**
 Encapsulates parallel functionality for an array.
 */
public class Parallel<T> {
  /**
   The source array for our parallel functions.
   */
  public let source: [T]

  /**
   Creates the parallel array from the *source*.
   */
  public init(source: [T]) {
    self.source = source
  }
}

public extension Array {
  /**
   Creates a parallel encapsulation of the array.
   */
  public var parallel: Parallel<Element> {
    return Parallel(source: self)
  }
}

public extension Parallel {
  public func async(_ closure: @escaping (T, T) -> T) -> ParallelReduceItemClosure<T> {
    return {
      $2(closure($0, $1))
    }
  }

  public func async<U>(_ closure: @escaping (T) -> U) -> ParallelMapTransform<T, U> {
    return {
      $1(closure($0))
    }
  }

  /**
   Creates a *ParallelMapOperation* and begin the operation.
   */
  public func map<U>(
    _ transform: @escaping ParallelMapTransform<T, U>,
    completion: @escaping ParallelMapCompletion<U>) -> ParallelMapOperation<T, U> {
    let operation = ParallelMapOperation(source: self.source, transform: transform, completion: completion)
    operation.begin()
    return operation
  }

  public func map<U>(
    _ transform: @escaping (T) -> U,
    completion: @escaping ParallelMapCompletion<U>) -> ParallelMapOperation<T, U> {
    return self.map(self.async(transform), completion: completion)
  }

  public func reduce(
    _ each: @escaping ParallelReduceItemClosure<T>,
    completion: @escaping ParallelOperationCompletion<T>) -> ParallelReduceOperation<T> {
    let operation = ParallelReduceOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }

  public func reduce(
    _ each: @escaping (T, T) -> T,
    completion: @escaping ParallelOperationCompletion<T>) -> ParallelReduceOperation<T> {
    return self.reduce(self.async(each), completion: completion)
  }
}
