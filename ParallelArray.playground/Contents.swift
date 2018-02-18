import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
let numbers = Array(1...200)


var count = 0
func pairAndSum<T>(numbers : Array<T>,
                   itemClosure: @escaping (T,T,(T)->Void)->Void,
                   completion: @escaping (Array<T>) -> Void) {
  count += 1
  let right = numbers[numbers.count/2..<numbers.count]
  let left = numbers[0..<numbers.count/2]
  let group = DispatchGroup()
  let queue = DispatchQueue.global()
  let arrayQueue = DispatchQueue(label: "arrayQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
  let zipValues = zip(left, right)
  var values = Array<T>()
  for (left, right) in zipValues {
    group.enter()
    queue.async {
      itemClosure(left, right, {pairedValue in
        arrayQueue.async(group: nil, qos: .default, flags: .barrier, execute: {
          values.append(pairedValue)
          group.leave()
        })
        
      })
    }
    
  }
  
  group.notify(queue: queue) {
    if let last = right.last, right.count != left.count {
      values.append(last)
    }
    completion(values)
  }
}

func onCompletion (result : Array<Int>) {
  print(result)
  guard result.count > 1 else {
    print(numbers.reduce(0, +))
    print(count)
    print(ceil(log2(Double(numbers.count))))
    PlaygroundPage.current.finishExecution()
  }
  pairAndSum(numbers: result, itemClosure: {$2($0 + $1)}, completion: onCompletion)
}
pairAndSum(numbers: numbers, itemClosure: {$2($0 + $1)}, completion: onCompletion)
