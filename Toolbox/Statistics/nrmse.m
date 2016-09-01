function r = nrmse(a,b)

% r = NRMSE(a,b) computes the  root mean squared error between two vectors
% normalised to the range of signal a
%
% ARGUMENTS
%  a   ...  1st vector of data
%  b   ...  2nd vector of data
%
% RETURN
%  r   ...  NRMSE between a and b
%
% NOTES
% - NaN removal assumes NaNs can only exist and start and end with
%   continuous data in the middle e.g. NaN NaN NaN 1 2 54 65 765 34 NaN NaN NaN
%
% See also rmse


% Revision History
%
% Created by Philippe Dixon  Feb 2012 


r = rmse(a,b);

r = r/abs(range(a));


