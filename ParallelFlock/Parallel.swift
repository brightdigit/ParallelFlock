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
  /**
   Creates a *ParallelMapOperation* and begin the operation.
   */
  public func map<U>(
    _ each: @escaping (T, @escaping (U) -> Void) -> Void,
    completion: @escaping ([U]) -> Void) -> ParallelMapOperation<T, U> {
    let operation = ParallelMapOperation(source: self.source, itemClosure: each, completion: completion)
    operation.begin()
    return operation
  }
}
