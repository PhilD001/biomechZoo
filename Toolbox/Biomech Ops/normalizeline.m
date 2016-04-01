function [nline,nlength]=normalizeline(data,datalength,intmethod)

% [nline,nlength]=normalizeline(data,datalength) normalizes data to specific length 
%
% ARGUMENTS
%  data         ...   data vector to be processed
%  datalength   ...   required data length. Default is 100
%  intmethod    ...   method to interpolate data. Default 'linear'.
%                     See interp1 for more options
%
% RETURNS
%  nline        ...   new data vector
%  nlength      ...   length of new vector
%
% NOTES
% - normalization using default linear interpolation implemented. For more options, 
%   see help for 'interp1'. 


% Revision history: 
%
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon May 2015 
% - Help improved
% - default normalization to 100% implemented
% - preallocation of size of matrix stk implemented
%
% Updated by Philippe C. Dixon Jan 11th 2016
% - Interpolation can be performed using any method available in the
%  'interp1' function
%
% Updated by Philippe C. Dixon March 19th 2016
% - Fixed error with output 'nlength'



% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


% Set defaults
%
if nargin==1
    datalength = 100;
end

if nargin==2
    intmethod = 'linear';
end

data = makecolumn(data);

[r,c]=size(data);

stk = zeros(datalength+1,c);

xdata = (((1:r)'-1)/(r-1))*datalength;      % length of original signal, but from 0:datalength
id = (0:datalength)';                       % vector id = [0,1,2,...datalength]

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
   
    stk(:,i) = interp1(xxd,yyd,id,intmethod);     % interpolation using 'intmethod'      
    
end

nline = stk;
nlength = length(nline);
