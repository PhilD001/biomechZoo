function [nr,nlength]=normalize_line(r,datalength,method)

% [nline,nlength] = NORMALIZE_LINE(r,datalength,method) normalizes data to specific length
%
% ARGUMENTS
%  r          ... Matrix data (n x 1 or n x3)
%  datalength ... Normalize data to a specific length. Data will have datalength+1 frames.
%                 Default: 100 (101 frames)
%  method     ... method to interpolate data. Default 'linear'.
%                 See interp1 for more options
%
% RETURNS
%  nr         ... Normalized matrix
%  nlength    ... New length matrix data
%
% See also interp1, bmech_normalize, normalize_data


%
% Revision history:
%
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon May 2015
% - Help improved
% - default normalization to 100% implemented
% - preallocation of size of matrix stk implemented
%
% Updated by Philippe C. Dixon  2016
% - Interpolation can be performed using any method available in the
%  'interp1' function
% - Fixed error with output 'nlength'
%
% Updated by Philippe C. Dixon Oct 2017
% - Default setting bug fix for users running this function directly with a 
%   single argument 
%
% Updated by Philippe C. Dixon Dec 2017
% - Bug fix for data that contains all NaN. Now NaN data will remain, but
%   will be returned of length datalength-1

% Set defaults
%
if nargin==0
    runDemo
    return
end

if nargin==1
    datalength = 100;
    method = 'linear';
end

if nargin==2
    method = 'linear';
end

[rows,cols]=size(r);

nr = zeros(datalength+1,cols);

xdata = (((1:rows)'-1)/(rows-1))*datalength;      % length of original signal, but from 0:datalength
id = (0:datalength)';                       % vector id = [0,1,2,...datalength]

for i = 1:cols
    yd = r(:,i);
    nindx = find(isnan(yd));
    
    xxd = xdata;
    xxd(nindx) = [];
    yyd = yd;
    yyd(nindx) = [];
 
    if isempty(yyd)
        nr = NaN*ones(datalength+1,1);            % new code PD
        % nr = [];                                % JJ original code
    else
        nr(:,i) = interp1(xxd,yyd,id,method);     % interpolation using default linear interpolation
    end
   
    
end
nlength = length(nr);


function runDemo

disp('running demo mode')
dlength = 387;
datalength = 100;   % e.g. 0-100% of the gait cycle
t = (1:1:dlength)';
x = sin(2*pi/dlength*t);
x = [x 2*x 3*x];
x([30:32,38:50],1) = NaN;
[nx,nt] = normalize_line(x,datalength);
nt = (1:1:nt);
subplot(2,1,1)
plot(t,x)
ylim([-4 4])
text(round(mean(t)),3,['number of frames = ',num2str(dlength)])
subplot(2,1,2)
plot(nt,nx)
text(round(mean(nt)),3,['normalization chosen = ',num2str(datalength),'%'])
text(round(mean(nt)),2,['number of frames = ',num2str(length(nx))])
ylim([-4 4])
disp('demo completed')
