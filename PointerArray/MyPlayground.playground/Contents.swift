import Cocoa

let numbersPointer = UnsafeMutableBufferPointer<Int>.allocate(capacity: 12)

for (index, value) in (1 ... 12).enumerated() {
  numbersPointer[index] = value
}

let values = [Int](numbersPointer)
