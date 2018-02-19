import Foundation

public struct ParallelOptions {
  public static let defaultQos: DispatchQoS = {
    if #available(OSXApplicationExtension 10.10, *) {
      return DispatchQoS.default
    } else {
      return DispatchQoS.unspecified
    }
  }()

  public static let defaultQueue: DispatchQueue = {
    if #available(OSXApplicationExtension 10.10, *) {
      return DispatchQueue.global()
    } else {
      return DispatchQueue(label: UUID().uuidString)
    }
  }()
}
