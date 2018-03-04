% create input signal
z = zeros(1, 200);
o = ones(1, 200);
input = [z o z];
for i = 1:length(input)
    r = -0.5 + rand();
    input(i) =input(i)+ r;
end
% plot input signal to compare wiht later output signals
plot(input, 'lineWidth', 2);
ylim([-1 2]);

% set moving average delay
delay = 25;
% create delayed input signal for computation
zDelay = zeros(1, delay);
inputDelay = [zDelay input zDelay];
% plot inputDelay signal
figure;
plot(inputDelay, 'lineWidth', 2);
ylim([-1 2]);

delayRange = 2*delay + 1;
% use MatLab filter command to compute output
% L = filter(ones(1,delayRange)/delayRange,1,[inputDelay zeros(1,delay)]);
% outputMatLab = L(delay:end);
% figure;
% % plot moving average output due to MatLab
% plot(outputMatLab, 'lineWidth', 2);
% ylim([-1 2]);

inputDelayLen = length(inputDelay);
% compute moving average filtee without MatLab via brute force additon
outputAddition = zeros(1, inputDelayLen);
ak = -delay:delay;
for i = delay+1:length(inputDelay)-(delay+1);
    for j = ak;
        outputAddition(i) = outputAddition(i) + inputDelay(i + j);
    end
    outputAddition(i) = outputAddition(i)/delayRange;
end
figure;
% plot outputAdditon
plot(outputAddition, 'lineWidth', 2);
ylim([-1 2]);

% compute moving average via recursion
accumulator = 0;
outputRecursion = zeros(1, length(inputDelay));
for i = 1: delayRange;
    accumulator = accumulator + inputDelay(i);
end
outputRecursion(delay) = accumulator / delayRange;
what = outputRecursion(delay);

% recursion
for i = delay+1:length(inputDelay)-delay;
    accumulator = accumulator + inputDelay(i + delay) - inputDelay(i - delay);
    outputRecursion(i) = accumulator;
    outputRecursion(i) = outputRecursion(i) / delayRange;
end

%plot outputRecursion
figure;
% plot outputAdditon
plot(outputRecursion, 'lineWidth', 2);
ylim([-1 2]);
