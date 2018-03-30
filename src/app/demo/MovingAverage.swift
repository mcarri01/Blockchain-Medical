import Foundation

// create input signal

let z = Array(repeating: 0.0, count: 200)
let o = Array(repeating: 1.0, count: 200)

var input = z + o + z
//print(input.count)

input = input.map{$0 + (-0.5 + Double(arc4random_uniform(1000))/1000.0)}

// set moving average delay
let delay = 25.0
// create delayed input signal for computation
let zDelay = Array(repeating: 0.0, count: Int(delay))
let inputDelay = zDelay + input + zDelay
let delayRange = 2.0*delay + 1.0

// compute moving average filter without Matlab via brute force addition
var outputAdditon = Array(repeating: 0.0, count: inputDelay.count)
let ak = Array(stride(from: -delay, to: delay, by: 1))

for i in Int(delay)...(inputDelay.count - Int(delay)) {
  for j in ak {
    outputAdditon[i] = outputAdditon[i] + inputDelay[i + Int(j)]
  }
  outputAdditon[i] = outputAdditon[i] / delayRange
}

for elem in outputAdditon {
  print(elem, terminator: ",")
}
// // compute moving average via recursion (????)
// var accumulator = 0.0
// var outputRecursion = Array(repeating: 0.0, count: inputDelay.count)
//
// for i in 0...delayRange {
//   accumulator += inputDelay[i]
// }
// outputRecursion[delay] = accumulator / delayRange
//
// // recursion (????)
// for i in delay...inputDelay.count - delay {
//   accumulator += inputDelay[i + delay] - inputDelay[i - delay]
//   outputRecursion[i] = accumulator
//   outputRecursion[i] = outputRecursion[i] / delayRange
// }
