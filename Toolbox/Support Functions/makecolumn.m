function r = makecolumn(s)

%   MAKECOLUMN forces row vector to be a column vector
%
% Updated March 3rd 2015 by Philippe C. Dixon
% - works with cell arrays


if iscell(s)
    
    [~,cols] = size(s);
    
    if cols~=1
        r = s';
        
    else
        r = s;
    end
    
    
else
        
    sz = size(s);
    
    if sz(1) < sz(2)
        if length(sz) == 2
            r = s';
        elseif length(sz) == 3
            r = permute(s,[2 1 3]);
        end
    else
        r = s;
    end
    
    
end