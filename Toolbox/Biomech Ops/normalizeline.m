function [nline,nlength]=normalizeline(data,datalength)

% [nline,nlength]=normalizeline(data,datalength) normalizes data to specific length 
%
% ARGUMENTS
%  data         ...   data vector to be processed
%  datalength   ...   required data length. Default is 100
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
% Updated May 2015 by Philippe C. Dixon
% - Help improved
% - default normalization to 100% implemented
% - preallocation of size of matrix stk implemented


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 


% Set defaults
%
if nargin==1
    datalength = 100;
end

data = makecolumn(data);

[r,c]=size(data);
nlength = r;

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
   
    stk(:,i) = interp1(xxd,yyd,id);         % interpolation using default linear interpolation      
    
end

nline = stk;