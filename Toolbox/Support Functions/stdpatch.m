function [vr,fc] = stdpatch(xd,yd,st)

% This function creates std patches for graphing purposes
%
% ARGUMENTS
%   xd    ... xaxis data range
%   yd    ... plotted ydata
%   st    ... variance of data (std, CI, etc...
%
% RETURNS
%   vr    ...  vertices of patch
%   fc    ...  faces of patch

% NOTES
% vr and fc can be used to create a patch as follows
%
% pch = patch('parent',gca,'vertices',vr,'faces',fc,'facecolor',[.8 .8 .8],'facealpha',1,'edgecolor','none'); 

% Created by JJ Loh 2006



if nargin == 2
    st = yd;
    yd = xd;
    xd = (1:length(yd));
end

indx = find(isnan(yd));
st(indx) = [];
yd(indx) = [];
xd(indx) = [];

nyd = makecolumn(yd-st);
pyd = makecolumn(yd+st);
xd = makecolumn(xd);
zd = zeros(size(xd))-.000001;
lyd = length(yd);

fc = [(1:lyd),(2*lyd:-1:lyd+1)];
vr = [xd,nyd,zd];
vr = [vr;[xd,pyd,zd]];