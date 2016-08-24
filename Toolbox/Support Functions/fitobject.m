function [zdis,ort,pdis] = fitobject(objvr,fitvr)
%this function will displace and rotate objvr to fit the fitvr
%there are three operations (intial displacement, rotation, final
%displacement


nindx = find(isnan(objvr(:,1)));
objvr(nindx,:) = [];
fitvr(nindx,:) = [];

nindx = find(isnan(fitvr(:,1)));
objvr(nindx,:) = [];
fitvr(nindx,:) = [];

if length(fitvr(:,1))< 3 || length(objvr(:,1)) ~= length(fitvr(:,1))
    zdis = [0 0 0];
    ort = [1 0 0;0 1 0;0 0 1]*NaN;
    pdis = [0 0 0];
    return
   % error('fit not done');
end

%indx = maxdelta(objvr,fitvr);
%indx1 = indx(1);
indx1 = 1;
zdis = -objvr(indx1,:); %zero to one of the vertices.  zdis is the initial displacement
objvr = displace(objvr,zdis);

%zeros the fitvr with the same vertex this displacement will be added later
pdis =fitvr(indx1,:);
fitvr = displace(fitvr,-pdis);  %pdis is the final displacement

pt0 = objvr(indx1,:);  %pt0 should be [0 0 0] for fitvr and objvr


%indx2 = maxdelta(objvr,fitvr,indx1); %finding the maxpoint from the object
%indx2 = indx2(1);
indx2 = 2;
opt1 = objvr(indx2,:);
fpt1 = fitvr(indx2,:);


oi = opt1;
fi = fpt1;

j = -cross(oi,fi);

ok = cross(oi,j);
fk = cross(fi,j);

ounit = makeunit([oi;j;ok]);
funit = makeunit([fi;j;fk]);
gunit = [1 0 0;0 1 0;0 0 1];

objvr = ctransform(funit,gunit,ctransform(gunit,ounit,objvr));
ort = ctransform(funit,gunit,ctransform(gunit,ounit,gunit));

indx3 = maxdelta(objvr,fitvr,[indx1;indx2]);

opt1 = objvr(indx3,:);
fpt1 = fitvr(indx3,:);

i = fi;

ok = cross(opt1,i);
fk = cross(fpt1,i);

oj = -cross(i,ok);
fj = -cross(i,fk);
ounit = makeunit([i;oj;ok]);
funit = makeunit([i;fj;fk]);

ort = ctransform(funit,gunit,ctransform(gunit,ounit,ort));
objvr = ctransform(funit,gunit,ctransform(gunit,ounit,objvr));

delta = fitvr-objvr;
delta = mean(delta);
pdis = pdis+delta;







function r = magnitude(vec)

r = sqrt(diag(vec*vec'));

function indx = maxdelta(objvr,fitvr,varargin)

sz = size(objvr);
if sz(1) == 1
    delta = displace(fitvr,-objvr);
else    
    delta = fitvr-objvr;
end
if nargin == 3
    delta(varargin{1},:) = NaN;
end
mdelta = magnitude(delta);
mdelta(find(isnan(mdelta))) = -inf;
indx = find(mdelta==max(mdelta));
indx = indx(1);
