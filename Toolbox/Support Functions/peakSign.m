function sign = peakSign(r)

% sign = PEAKSIGN(r) determines if the max peak is negative or positive

maxVal = max(r);
minVal = min(r);

if abs(maxVal) > abs(minVal)
    sign = 1;
else
    sign = -1;
end