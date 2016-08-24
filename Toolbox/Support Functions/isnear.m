function r  = isnear(a,b,prox)


% ISNEAR determines if two numbers are near each other as defined by prox
%
% ARGUMENTS
%  a        ... first value
%  b        ... 2nd value
%  prox     ... proximity value 
%
% RETURNS
% r         ... 0 if no, 1 if yes
%
% Created by Phil Dixon April 19th 2012

if abs(a-b) < prox
    r=1;
else
    r=0;
end