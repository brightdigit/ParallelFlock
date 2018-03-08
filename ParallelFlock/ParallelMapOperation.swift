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
  public let transform: (T, @escaping (U) -> Void) -> Void

  /**
   The completion closure.
   */
  public let completion: ([U]) -> Void

  /**
   The DispatchQueue for each item map.
   */
  public let itemQueue: DispatchQueue

  /**
   The DispatchQueue for the main operation.
   */
  public let mainQueue: DispatchQueue

  /**
   The DispatchQueue for barrier array operation.
   */
  public let arrayQueue: DispatchQueue

  /**
   The temporary result array.
   */
  public private(set) var temporaryResult: [U?]

  /**
   Creates *ParallelMapOperation*.
   */
  public init(
    source: [T],
    transform: @escaping (T, @escaping (U) -> Void) -> Void,
    completion: @escaping ([U]) -> Void,
    mainQueue: DispatchQueue? = nil,
    itemQueue: DispatchQueue? = nil,
    arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.transform = transform
    self.completion = completion
    self.itemQueue = mainQueue ?? ParallelOptions.defaultQueue
    self.mainQueue = itemQueue ?? ParallelOptions.defaultQueue
    self.arrayQueue = arrayQueue ?? DispatchQueue(
      label: "arrayQueue",
      qos: ParallelOptions.defaultQoS,
      attributes: .concurrent,
      autoreleaseFrequency: .inherit,
      target: nil)

    self.temporaryResult = [U?].init(repeating: nil, count: self.source.count)
  }

  /**
   Begins the operation.
   */
  public func begin() {
    // create our DispatchGroup
    let group = DispatchGroup()

    // asynchronously on the main queue...
    self.mainQueue.async {
      // iterate over the enumerated source array
      for (index, item) in self.source.enumerated() {
        // enter the DispatchGroup
        group.enter()
        // asynchronously on our item queue...
        self.itemQueue.async(execute: {
          // call the transform
          self.transform(item, { result in
            // asynchronously on our array queue...
            self.arrayQueue.async(group: nil, qos: ParallelOptions.defaultQoS, flags: .barrier, execute: {
              // set the item at the index of the resulting array
              self.temporaryResult[index] = result
              // leave the group
              group.leave()
            })
          })
        })
      }

      // when the group is completed in the item queue
      group.notify(queue: self.itemQueue, execute: {
        let result: [U]
        // filter the resulting array for non-optional items
        #if swift(>=4.1)
          result = self.temporaryResult.compactMap { $0 }
        #else
          result = self.temporaryResult.flatMap { $0 }
        #endif
        // make sure the result is the same size of the source array
        assert(result.count == self.source.count)
        // call the completion callback
        self.completion(result)
      })
    }
  }
}
