import Foundation

public typealias ParallelReduceItemClosure<T> = (T, T, @escaping (T) -> Void) -> Void
