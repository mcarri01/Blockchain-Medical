func dspConv(x: [Double], h: [Double]) -> [Double] {
  // x = signal, h = filter
  // Transform the vectors x and h in new vectors with the same length
  var X = x + [Double](repeating: 0, count: h.count)
  var H = h + [Double](repeating: 0, count: x.count)

  // the length of output signal of a convolution operation
  // is the sum of the two input signal minus 1
  var len = (h.count + x.count -1)
  var out = [Double](reapeating: 0, count: len)
  for i in 0...(h.count + x.count -2) {
    for j in 0 ... (count.x - 1) {
      if (i-j+1) > 0 {
        out[i] = out[i] + X[j] * H(i-j+1)
      }
    }
  }
}


var Fsamp = 125.0;

// define the period
var T = 1/Fsamp;

// set the time base
var t = Array(stride(from:0.0 to: 1.0, by: T))


// define noise frequency
var Fn = 5;

// define noise
// var noise = 0.2*cos(2*Double.pi*Fn*t);
var noise = t.map(0.2*cos(2*Double.pi*Fn*$0))
// define signal frequency
var Fs = 50;

// define signal
// signal = cos(2*pi*Fs*t);
var signal = t.map(cos*Double.pi*Fs*$0)

var waveform = zip(noise, signal).map($0 + $1)
