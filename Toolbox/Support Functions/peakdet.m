function [maxtab, mintab]=peakdet(v, delta)

% [maxtab, mintab] = PEAKDET(v,delta) detects peaks in a vector
%
%   ARGUMENTS
%   v     ...  vector to search.
%   delta ...  threshold value for detemining peak
%
%   RETURNS
%   maxtab ...  2 column vector c1: indices, c2: values
%   mintab ... consists of two columns. Column 1
%        
%    ALGORITHM
%    A point is considered a maximum peak if it has the maximal
%    value, and was preceded (to the left) by a value lower by
%    DELTA. 
%
% Created by Eli Billauer, 3.4.05 (Explicitly not copyrighted).
% This function is released to the public domain; Any use is allowed.

maxtab = [];
mintab = [];

v = v(:); % Just in case this wasn't a proper vector

if (length(delta(:)))>1
  error('Input argument DELTA must be a scalar');
end

if delta <= 0
  error('Input argument DELTA must be positive');
end

mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;

lookformax = 1;

for i=1:length(v)
  this = v(i);
  if this > mx, mx = this; mxpos = i; end
  if this < mn, mn = this; mnpos = i; end
  
  if lookformax
    if this < mx-delta
      maxtab = [maxtab ; mxpos mx];
      mn = this; mnpos = i;
      lookformax = 0;
    end  
  else
    if this > mn+delta
      mintab = [mintab ; mnpos mn];
      mx = this; mxpos = i;
      lookformax = 1;
    end
  end
end