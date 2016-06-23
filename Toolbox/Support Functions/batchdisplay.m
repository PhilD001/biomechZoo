function batchdisplay(fl,type)

% batchdisplay(fl,type) produces a shortened display of file path 
%
% ARGUMENTS
% fl    ... name of file being processed
% type  ... message specifyer. Default 'processing'
%
%
% Created June 2013 by Philippe C. Dixon
%
% Updated January 9th 2014 by Philippe C. Dixon
% - simplification of algorithm
%
% Updated Sept 23rd 2014 by Philippe C. Dixon
% - fixed bug when length(indx)==4

if nargin==1
    type = 'processing';
end

s = slash; 
indx = strfind(fl,s);

if length(indx)<=4
    fl_cat = fl;
else
    fl_cat = fl(indx(end-4):end);
end

disp([type,' for: ',fl_cat])
