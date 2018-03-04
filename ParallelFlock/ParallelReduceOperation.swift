import Foundation

public class ParallelReduceOperation<T>: ParallelOperation {
  public let source: [T]
  public let itemClosure: ParallelReduceItemClosure<T>
  public let completion: ParallelCompletionClosure<T>
  public let itemQueue: DispatchQueue
  public let mainQueue: DispatchQueue
  public let arrayQueue: DispatchQueue

  public private(set) var status: ParallelOperationStatus<T> = .initialized
  public private(set) var temporaryResult: [T]
  public private(set) var iterationCount: Int = 0

  public var maxIterations: Int {
    let count: Float = Float(self.source.count)
    let multiplier: Float = 2.0
    let maxIterationsFloat: Float = log2f(count * multiplier)
    let maxIterationsInt: Int = Int(maxIterationsFloat)
    return maxIterationsInt
  }

  public init(
    source: [T],
    itemClosure: @escaping ParallelReduceItemClosure<T>,
    completion: @escaping ParallelCompletionClosure<T>,
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

    self.temporaryResult = source
  }

  public func begin() {
    switch self.status {
    case .initialized:
      break
    default:
      return
    }
    self.status = .running(0)
    self.mainQueue.async(execute: self.iterate)
  }

  public func iterate() {
    if self.iterationCount <= self.maxIterations && self.temporaryResult.count > 1 {
      self.iterationCount += 1
      let right = self.temporaryResult[self.temporaryResult.count / 2 ..< self.temporaryResult.count]
      let left = self.temporaryResult[0 ..< self.temporaryResult.count / 2]
      let zipValues = zip(left, right)
      var values = [T]()
      let group = DispatchGroup()
      for (left, right) in zipValues {
        group.enter()
        self.itemQueue.async {
          self.itemClosure(left, right, { reduced in
            self.arrayQueue.async(group: nil, qos: ParallelOptions.defaultQos, flags: .barrier, execute: {
              values.append(reduced)
              group.leave()
            })
          })
        }
      }
      group.notify(queue: self.itemQueue) {
        if let last = right.last, right.count != left.count {
          values.append(last)
        }
        self.temporaryResult = values
        self.status = .running(self.source.count - values.count)
        self.iterate()
      }
    } else {
      assert(self.temporaryResult.count == 1)
      let result = self.temporaryResult.first!
      self.status = .completed(result)
      self.completion(result)
    }
  }
}
