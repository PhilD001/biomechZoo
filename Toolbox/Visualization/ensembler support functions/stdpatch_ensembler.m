function [vr,fc] = stdpatch_ensembler(xd,yd,st)

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

if length(xd) ~= length(nyd)
    error('data lengths inconsistent. Check that data are normalized')
end

vr = [xd,nyd,zd];
vr = [vr;[xd,pyd,zd]];
