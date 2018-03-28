
sLimit = 25;
n = -sLimit:sLimit;
freqCutoff = 0.1;

theSinc(n, freqCutoff)

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