function r = makerow(s)

%   MAKEROW forces a column vector to be a row vector

sz = size(s);

if sz(1) > sz(2)
    if length(sz) == 2
        r = s';
    elseif length(sz) == 3
        r = permute(s,[2 1 3]);
    end
else
    r = s;
end
