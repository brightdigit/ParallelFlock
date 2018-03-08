import Foundation

public typealias ParallelMapTransform<T, U> = (T, @escaping (U) -> Void) -> Void
