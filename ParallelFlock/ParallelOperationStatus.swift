import Foundation

public enum ParallelOperationStatus<U> {
  case initialized
  case running(Int)
  case completed(U)
}
