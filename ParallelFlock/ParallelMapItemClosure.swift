import Foundation

public typealias ParallelMapItemClosure<T, U> = (T, @escaping (U) -> Void) -> Void
