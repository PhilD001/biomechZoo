function r = findzeromin(v)

% finds the last 0 in a vector using an algorithm starting from max
%
% 
% created Jan 7th 2013

v = (makecolumn(v))';

[~,a] = min(v);
b =  fliplr(v(1:a));
c = find(b==0,1,'first');
r = a-c+1; % first non-zero element
