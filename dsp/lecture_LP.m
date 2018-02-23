% create time-based signal
% define sampling frequency
% frequency in Hertz
Fsamp = 125;

%define the period
T = 1/Fsamp;

%set the time base
t = 0:T:1;

% define signal frequency
Fs = 50;

% define signal
signal = cos(2*pi*Fs*t);

figure;
plot(t, signal);
%xlim([0 250]);
ylim([-1.1 1.15]);
title("signal");

% define noise frequency
Fn = 5;

% define noise
noise = 0.2*cos(2*pi*Fn*t);

figure;
plot(t, noise);
%xlim([0 500]);
ylim([-1.1 1.15]);
title("noise");

waveform = signal + noise;
figure;
plot(t, waveform);
title("waveform");
%xlim([0 50]);
ylim([-1.25 1.25]);



% cutoff frequency is defined with respect to normalized nyquist frequency
% if sampling is Fs then normalized is 1
% then normalized nyquist is 0.5
% this means that highest frequency in signal cannot exceed 0.5*Fs
% 
% set the cutoff frequency
Fc = 12.5;
freq_cutoff = Fc/Fsamp;

% set the limits of the sinc even though it is infinite
sLimit = 25;
n = -sLimit:sLimit;

%{
y = sinc(n*freq_cutoff);
figure;
stem(n,  y);
ylim([-0.4 1.1]);
%}

% define the impluse response fo the filter -- for low pass
% this is a sinc filter in the time domain
h = theSinc(n, 2*freq_cutoff);
figure;
stem(n,  h);
ylim([-0.4 1.1]);
title("theSinc");

% define the blackman window to truncate the impulse response
% window length
N = sLimit*2;
bn = 0:N;
blackmanWindow = 0.42 - 0.5*cos(2*pi*bn/(N-1)) + 0.08*cos(4*pi*bn/(N-1));
figure;
stem(bn, blackmanWindow);
ylim([-0.4 1.1]);
title("blackmanWindow");

hBlackman = h.*blackmanWindow;
figure;
stem(n, hBlackman);
ylim([-0.4 1.1]);
title("hBlackman");

% create normalized impulse response
hNorm = hBlackman/theSum(hBlackman);
figure;
stem(bn,  hNorm);
title("hNorm");

HN = fft(hNorm);
HNs = fftshift(HN);
figure;
plot(abs(HN));
%xlim([0 25]);
title("Norm freq spectrum");
figure;
semilogy(abs(HN));
%xlim([0 500]);
title("Norm freq spectrum dB");

% generate output by convolving waveform and filter

output = dspConv(waveform, hNorm);
%ouput = conv(waveform, hNorm);
figure;
to = 1: length(output);
plot(to, output);
title("output");
%xlim([0 500]);
ylim([-1.25 1.25]);

% ==========
% MARK: dsp functions
function s = theSinc(n, freqCutoff)
for i = 1:length(n);
        sx = freqCutoff*n(i);
        if n(i) == 0
            s(i) = 1;
        else
            s(i) = sin(pi*sx) / (pi*sx);
        end
end
end

function s = theSum(f)
    n = length(f);
    s = 0;
        for i = 1:n
            s = s + f(i);
        end
end

% convolution of filter and input (x), filter (h) -> output (out)
% two signals result in new vector from convolution operation
function out = dspConv(x, h)
    % x = signal, h = filter
    % Transform the vectors x and h in new vectors with the same length
    X = [x,zeros(1,length(h))];
    H = [h,zeros(1,length(x))];
    % the length of output signal of a convolution operation
    % is the sum of the two input signal minus 1
    for i = 1:length(h)+length(x)-1;
        % Create ouput signal out
        out(i) = 0;
        % FOR Loop to walk through the vector F ang G
        for j = 1:length(x);
            if( i- j + 1 > 0)
            out(i) = out(i) + X(j) * H(i - j + 1);
            else
            end
        end
    end
end
    
%{
for d = 1:10;
    x = 0:pi/d:2*pi;
    y = cos(x);
    figure;
    stem(x, y);
    hold on;
    plot(x, y);
    hold off;
end
%}
