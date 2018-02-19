import Foundation

public class ParallelMapOperation<T, U> {
  public let source: [T]
  public let itemClosure: ParallelMapItemClosure<T, U>
  public let completion: ParallelMapCompletionClosure<U>
  public let queue: DispatchQueue
  public let arrayQueue: DispatchQueue

  public private(set) var status = ParallelOperationStatus<[U]>.initialized
  public private(set) var temporaryResult: [U?]

  public var sourceCount: Int {
    return self.source.count
  }
  public init(
    source: [T],
    itemClosure: @escaping ParallelMapItemClosure<T, U>,
    completion: @escaping ParallelMapCompletionClosure<U>,
    queue: DispatchQueue? = nil,
    arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.itemClosure = itemClosure
    self.completion = completion
    self.queue = queue ?? ParallelOptions.defaultQueue
    self.arrayQueue = arrayQueue ?? DispatchQueue(
      label: "arrayQueue",
      qos: ParallelOptions.defaultQos,
      attributes: .concurrent,
      autoreleaseFrequency: .inherit,
      target: nil)

    self.temporaryResult = [U?].init(repeating: nil, count: self.source.count)
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

    for (index, item) in self.source.enumerated() {
      group.enter()
      self.queue.async(execute: {
        self.itemClosure(item, { result in
          self.arrayQueue.async(group: nil, qos: ParallelOptions.defaultQos, flags: .barrier, execute: {
            self.temporaryResult[index] = result
            count += 1
            self.status = .running(count)

            group.leave()
          })
        })
      })
    }

    group.notify(queue: self.queue, execute: {
      let result: [U]
      #if swift(>=4.1)
        result = self.temporaryResult.compactMap { $0 }
      #else
        result = self.temporaryResult.flatMap { $0 }
      #endif
      assert(result.count == self.source.count)
      self.status = .completed(result)
      self.completion(result)
    })
  }
}