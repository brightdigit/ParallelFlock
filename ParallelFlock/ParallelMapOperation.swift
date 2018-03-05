import Foundation

public class ParallelMapOperation<T, U> {
  public let source: [T]
  public let itemClosure: (T, @escaping (U) -> Void) -> Void
  public let completion: ([U]) -> Void
  public let itemQueue: DispatchQueue
  public let mainQueue: DispatchQueue
  public let arrayQueue: DispatchQueue

  public private(set) var temporaryResult: [U?]

  public init(
    source: [T],
    itemClosure: @escaping (T, @escaping (U) -> Void) -> Void,
    completion: @escaping ([U]) -> Void,
    mainQueue: DispatchQueue? = nil,
    itemQueue: DispatchQueue? = nil,
    arrayQueue: DispatchQueue? = nil) {
    self.source = source
    self.itemClosure = itemClosure
    self.completion = completion
    self.itemQueue = mainQueue ?? ParallelOptions.defaultQueue
    self.mainQueue = itemQueue ?? ParallelOptions.defaultQueue
    self.arrayQueue = arrayQueue ?? DispatchQueue(
      label: "arrayQueue",
      qos: ParallelOptions.defaultQos,
      attributes: .concurrent,
      autoreleaseFrequency: .inherit,
      target: nil)

    self.temporaryResult = [U?].init(repeating: nil, count: self.source.count)
  }

  public func begin() {
    let group = DispatchGroup()

    self.mainQueue.async {
      for (index, item) in self.source.enumerated() {
        group.enter()
        self.itemQueue.async(execute: {
          self.itemClosure(item, { result in
            self.arrayQueue.async(group: nil, qos: ParallelOptions.defaultQos, flags: .barrier, execute: {
              self.temporaryResult[index] = result
              group.leave()
            })
          })
        })
      }

      group.notify(queue: self.itemQueue, execute: {
        let result: [U]
        #if swift(>=4.1)
          result = self.temporaryResult.compactMap { $0 }
        #else
          result = self.temporaryResult.flatMap { $0 }
        #endif
        assert(result.count == self.source.count)
        self.completion(result)
      })
    }
  }
}
