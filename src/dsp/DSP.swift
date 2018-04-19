//
//  DSP.swift
//  demo
//
//  Created by Ben Francis on 3/30/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

// import Foundation


class DSP {
    private func theSinc(n: [Double], freqCutoff: Double) -> [Double] {
        var s = [Double](repeating: 0, count: n.count)
        for i in 0...(n.count-1) {
            let sx = freqCutoff*n[i]
            if n[i] == 0 {
                s[i] = 1
            } else {
                s[i] = _sin(Double.pi * sx) / (Double.pi * sx);
            }
        }
        return s
    }

    private func dspConv(x: [Double], h: [Double]) -> [Double] {
        // x = signal, h = filter
        // Transform the vectors x and h in new vectors with the same length
        var X = x + [Double](repeating: 0, count: h.count)
        var H = h + [Double](repeating: 0, count: x.count)

        // the length of output signal of a convolution operation
        // is the sum of the two input signal minus 1
        let len = (h.count + x.count - 1)
        var out = [Double](repeating: 0, count: len)
        for i in 0...(h.count + x.count - 2) {
            for j in 0 ... (x.count - 1) {
                if (i - j + 1) > 0 {
                    out[i] = out[i] + X[j] * H[i - j + 1]
                }
            }
        }
        return out
    }

    func highPassFilter(input: [Double]) -> [Double] {


        //define the period
        //let T = 1.0/Fsamp

        //set the time base
//        var t = Array(stride(from:0.0, to: 1.0, by: T))
//        // define signal frequency
//        let Fs = 25.0
//        // define the signal
//        let signal = t.map{ _cos(2*Double.pi*Fs*$0)}
//        // define noise frequency
//        let Fn = 5.0
//        // define noise
//        let noise = t.map{_cos(2*Double.pi*Fn*$0)}
//
//        let waveform = zip(signal, noise).map{$0 + $1}
        // cutoff frequency


        //frequency in Hertz
        let Fsamp = 125.0
        let Fc = 25.0
        let freq_cutoff = Fc/Fsamp

        // set limits
        let sLimit = 25.0
        let n = Array(stride(from: -1.0*sLimit, to: sLimit, by: 1))
        let h = theSinc(n: n, freqCutoff: freq_cutoff)
        // define the blackman window to truncate the impulse response
        // window length
        let N = sLimit*2.0;
        let bn = Array(stride(from: 0.0, to: N, by: 1.0))

        // broken up because Matt's laptop is garbage
        let firstblackmanWindow = bn.map{0.42 - 0.5*_cos(2*Double.pi*$0/(N-1))}
        let secondblackmanWindow = bn.map{0.08*_cos(4*Double.pi*$0/(N-1))}
        let blackmanWindow = zip(firstblackmanWindow, secondblackmanWindow).map{$0 + $1}

        let hBlackMan = zip(h, blackmanWindow).map{$0 * $1}
        let hBlackManSum = hBlackMan.reduce(0.0, +)
        var hNorm = hBlackMan.map{$0 / hBlackManSum}

        // Create High Pass Filter from the normalized low pass filter using spectral
        // inversion

        // Step 1: Change the sign of eav value of h
        var hN = hNorm.map{-$0}
        // Step 2: Add 1 to the value in the center of the filter
        hN[hN.count/2] = hN[hN.count/2] + 1
        // Step 3: Set the high pass filter to the filter variable
        hNorm = hN

        let result:[Double] = dspConv(x: input, h: hNorm)
//        for elem in result {
//            print(elem, terminator: "\n")
//        }

        return result
    }

    func lowPassFilter (input: [Double]) -> [Double] {
//        //define the period
//        let T = 1.0/Fsamp
//
//        //set the time base
//        var t = Array(stride(from:0.0, to: 1.0, by: T))
//
//        //define signal frequency
//        let Fs = 50.0
//
//        //define the signal
//        let signal = t.map{_cos(2*Double.pi*Fs*$0)}
//
//        //define noise frequency
//        let Fn = 5.0;
//
//        //define noise
//        let noise = t.map{_cos(2*Double.pi*Fn*$0)}
//
//        let waveform = zip(noise, signal).map{$0 + $1}

        //frequency in Hertz
        let Fsamp = 125.0

        //set the cutoff frequency
        let Fc = 12.5
        let freq_cutoff = Fc/Fsamp;

        //set the limits of the sinc even though it is infinite
        let sLimit = 25.0;
        let n = Array(stride(from: -1.0*sLimit, to: sLimit, by: 1))

        //define the impulse resonse for the filter -- for low pass
        //this is a sinc filter in the time domain
        let h = theSinc(n: n, freqCutoff: 2*freq_cutoff)

        //define the blackman window to truncate the impulse response
        //window length
        let N = sLimit*2.0;
        let bn = Array(stride(from: 0.0, to: N, by: 1.0))

        // broken into pieces because Matt's laptop sucks
        let firstblackmanWindow = bn.map{0.42 - 0.5*_cos(2*Double.pi*$0/(N-1))}
        let secondblackmanWindow = bn.map{0.08*_cos(4*Double.pi*$0/(N-1))}
        let blackmanWindow = zip(firstblackmanWindow, secondblackmanWindow).map{$0 + $1}
        //let blackmanWindow = bn.map{0.42 - 0.5*_cos(2*Double.pi*$0/(N-1)) +
        //                                  0.08*_cos(4*Double.pi*$0/(N-1))}
        let hBlackMan = zip(h, blackmanWindow).map{$0 * $1}
        let hBlackManSum = hBlackMan.reduce(0.0, +)
        let hNorm = hBlackMan.map{$0 / hBlackManSum}

        let result:[Double] = dspConv(x: input, h: hNorm)
//        for elem in result {
//            print(elem, terminator: "\n")
//        }
        return result

    }

    func movingAverageFilter (input: [Double]) -> [Double] {
//        let z = Array(repeating: 0.0, count: 200)
//        let o = Array(repeating: 1.0, count: 200)
//
//        var input = z + o + z
//        //print(input.count)
//
//        input = input.map{$0 + (-0.5 + Double(arc4random_uniform(1000))/1000.0)}
//
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

//        for elem in outputAdditon {
//            print(elem, terminator: ",")
//        }
        return outputAdditon
    }



}
