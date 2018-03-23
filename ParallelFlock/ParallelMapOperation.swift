import Foundation

/**
 The operation for a parallel map.
 */
public class ParallelMapOperation<T, U> {
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

  public private(set) var temporaryPointer: UnsafeMutablePointer<U>!

  /**
   Creates *ParallelMapOperation*.
   */
  public init(
    source: [T],
    default defaultValue: U,
    transform: @escaping ParallelMapTransform<T, U>,
    completion: @escaping ParallelMapCompletion<U>,
    mainQueue: DispatchQueue? = nil,
    itemQueue: DispatchQueue? = nil) {
    self.source = source
    self.transform = transform
    self.completion = completion
    self.itemQueue = itemQueue ?? ParallelOptions.defaultQueue
    self.mainQueue = mainQueue ?? ParallelOptions.defaultQueue

    self.temporaryPointer = UnsafeMutablePointer<U>.allocate(capacity: self.source.count)

    #if swift(>=4.1)
      self.temporaryPointer.initialize(repeating: defaultValue, count: self.source.count)
    #else
      self.temporaryPointer.initialize(to: defaultValue, count: self.source.count)
    #endif
  }

  /**
   Begins the operation.
   */
  public func begin() {
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
          group.leave()
        })
      })
    }
    group.notify(queue: self.mainQueue, execute: {
      let buffer = UnsafeBufferPointer<U>.init(start: self.temporaryPointer, count: self.source.count)
      let result = [U](buffer)
      assert(result.count == self.source.count)
      self.completion(result)
    })
  }

  deinit {
    self.temporaryPointer.deinitialize(count: self.source.count)

    #if swift(>=4.1)
      self.temporaryPointer.deallocate()
    #else
      self.temporaryPointer.deallocate(capacity: self.source.count)
    #endif

    self.temporaryPointer = nil
  }
}
