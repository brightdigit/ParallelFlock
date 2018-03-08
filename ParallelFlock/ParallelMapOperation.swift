import Foundation

/**
 The operation for a parallel map.
 */
public class ParallelMapOperation<T, U>: ParallelOperation {
  /**
   The source array.
   */
  public let source: [T]

  /**
   The item mapping closure.
   */
  public let transform: ParallelMapTransform<T, U>

  /**
   The completion closure.
   */
  public let completion: ParallelMapCompletion<U>

  /**
   The DispatchQueue for each item map.
   */
  public let itemQueue: DispatchQueue

  /**
   The DispatchQueue for the main operation.
   */
  public let mainQueue: DispatchQueue

  public private(set) var status = ParallelOperationStatus<[U]>.initialized
  public private(set) var temporaryPointer: UnsafeMutablePointer<U>!

  public var memoryCapacity: Int {
    return MemoryLayout<U>.size * self.source.count
  }

  /**
   Creates *ParallelMapOperation*.
   */
  public init(
    source: [T],
    transform: @escaping ParallelMapTransform<T, U>,
    completion: @escaping ParallelMapCompletion<U>,
    queue: DispatchQueue? = nil,
    itemQueue _: DispatchQueue? = nil) {
    self.source = source
    self.transform = transform
    self.completion = completion
    self.itemQueue = queue ?? ParallelOptions.defaultQueue
    self.mainQueue = queue ?? ParallelOptions.defaultQueue

    self.temporaryPointer = UnsafeMutablePointer<U>.allocate(capacity: self.memoryCapacity)
  }

  /**
   Begins the operation.
   */
  public func begin() {
    switch self.status {
    case .initialized:
      break
    default:
      return
    }

    self.status = .running(0)

    self.mainQueue.async(execute: self.run)
  }

  func run() {
    var count: Int = 0
    let group = DispatchGroup()
    for (offset, element): (Int, T) in self.source.enumerated() {
      group.enter()
      self.itemQueue.async(execute: {
        self.transform(element, { result in
          self.temporaryPointer[offset] = result
          count += 1
          self.status = .running(count)
          group.leave()
        })
      })
    }
    group.notify(queue: self.mainQueue, execute: {
      let buffer = UnsafeBufferPointer<U>.init(start: self.temporaryPointer, count: self.source.count)
      let result = [U](buffer)
      assert(result.count == self.source.count)
      self.status = .completed(result)
      self.completion(result)
    })
  }

  deinit {
    self.temporaryPointer.deinitialize(count: self.source.count)

    #if swift(>=4.1)
      self.temporaryPointer.deallocate()
    #else
      self.temporaryPointer.deallocate(capacity: self.memoryCapacity)
    #endif

    self.temporaryPointer = nil
    self.status = .invalid
  }
}
