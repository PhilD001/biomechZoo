function r = rmse(a,b)

% r = RMSE(a,b) computes the root mean squared error between two vectors
%
% ARGUMENTS
%  a   ...  1st vector of data
%  b   ...  2nd vector of data
%
% RETURN
%  r   ...  RMSE between a and b
%
% NOTES
% - NaN removal assumes NaNs can only exist and start and end with
%   continuous data in the middle e.g. NaN NaN NaN 1 2 54 65 765 34 NaN NaN NaN


% Revision History
%
% Created by Philippe Dixon  Feb 2012 




a = makecolumn(a);
b = makecolumn(b);

[rows,~] = size(a);
diffs = (a-b).^2;

r = sqrt(nansum(diffs)./rows);


