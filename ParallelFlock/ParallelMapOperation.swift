import Foundation

public class ParallelMapOperation<T, U>: ParallelOperation {
  public let source: [T]
  public let itemClosure: ParallelMapItemClosure<T, U>
  public let completion: ParallelMapCompletionClosure<U>
  public let itemQueue: DispatchQueue
  public let mainQueue: DispatchQueue
  public let arrayQueue: DispatchQueue

  public private(set) var status = ParallelOperationStatus<[U]>.initialized
  public private(set) var temporaryPointer: UnsafeMutablePointer<U>

  public init(
    source: [T],
    itemClosure: @escaping ParallelMapItemClosure<T, U>,
    completion: @escaping ParallelMapCompletionClosure<U>,
    queue: DispatchQueue? = nil,
    itemQueue _: DispatchQueue? = nil,
    arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.itemClosure = itemClosure
    self.completion = completion
    self.itemQueue = queue ?? ParallelOptions.defaultQueue
    self.mainQueue = queue ?? ParallelOptions.defaultQueue
    self.arrayQueue = arrayQueue ?? DispatchQueue(
      label: "arrayQueue",
      qos: ParallelOptions.defaultQos,
      attributes: .concurrent,
      autoreleaseFrequency: .inherit,
      target: nil)

    self.temporaryPointer = UnsafeMutablePointer<U>.allocate(capacity: MemoryLayout<U>.size * self.source.count)
  }

  public func begin() {
    switch self.status {
    case .initialized:
      break
    default:
      return
    }

    var count = 0
    self.status = .running(0)
    let group = DispatchGroup()

    self.mainQueue.async {
      for (index, item) in self.source.enumerated() {
        group.enter()
        self.itemQueue.async(execute: {
          self.itemClosure(item, { result in
            self.temporaryPointer[index] = result
            count += 1
            self.status = .running(count)
            group.leave()
          })
        })
      }
      group.notify(queue: self.itemQueue, execute: {
        let buffer = UnsafeBufferPointer<U>.init(start: self.temporaryPointer, count: self.source.count)
        let result = [U](buffer)
        assert(result.count == self.source.count)
        self.status = .completed(result)
        self.completion(result)
      })
    }
  }
}
