import Foundation

/**
 Contains the options used for the creation of *DispatchQueue*.
 */
public struct ParallelOptions {
  /**
   The default *DispatchQoS*.
   */
  public static let defaultQoS: DispatchQoS = {
    if #available(OSXApplicationExtension 10.10, *) {
      return DispatchQoS.default
    } else {
      return DispatchQoS.unspecified
    }
  }()

  /**
   The default *DispatchQueue*.
   */
  public static let defaultQueue: DispatchQueue = {
    if #available(OSXApplicationExtension 10.10, *) {
      return DispatchQueue.global()
    } else {
      let uuid = UUID()
      return DispatchQueue(label: uuid.uuidString)
    }
  }()
}
