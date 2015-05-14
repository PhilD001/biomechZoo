function ndata = normalization(data,ndatalength)

% NORMALIZATION takes a column vector of any length and normalizes it
% according to ndatalength
%
% ndata = normalization(data,ndatalength)
%
% ARGUMENTS
%   data      ...  column vector
%   ndatalength   ...  perecentage to normalize to
%
% RETURNS
%   ndata     ...  normalized data containing ndatalength+1 number of points
%
% Created by Phil Dixon & JJ Loh
% McGill University Biomechanics
%
% Updated Feb 2010
% -back to original code

% 

if nargin ==1
    ndatalength =100;
end



data = makecolumn(data);

[r,c]=size(data);

stk = [];

 xdata = (((1:r)'-1)/(r-1))*ndatalength;  %% JJ code
%xdata  = linspace(1,r,r);

id = (0:ndatalength-1)';   %% JJ code
%id = linspace(0,ndatalength-1,ndatalength-1)';

for i = 1:c
    yd = data(:,i);
    nindx = find(isnan(yd));
    
    xxd = xdata;
    xxd(nindx) = [];
    yyd = yd;
    yyd(nindx) = [];
    if isempty(yyd)
        nline = [];
        return
    end
    
    nyd = interp1(xxd,yyd,id);  
    stk = [stk,nyd];
    
end

ndata = stk;


