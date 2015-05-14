function [r,nvn] = chop(vr,fc,vn,pln,top);

%pln consists of 3 points that make the plane

lvr = length(vr(:,1));
lfc = length(fc(:,1));

c = pln(1,:);
vr(:,1) = vr(:,1)-c(1);
vr(:,2) = vr(:,2)-c(2);
vr(:,3) = vr(:,3)-c(3);

i = pln(2,:)-c;
j = cross(i,pln(3,:)-c);
k = cross(i,j);
if dot(k,pln(3,:))<0
    k = -k;
end
unt = makeunit([i;j;k]);

gunit = [1 0 0;0 1 0;0 0 1];

vr = ctransform(gunit,unt,vr);
vn = makeunit(ctransform(gunit,unt,vn));

[pt,nvn] = subchop(vr(fc(:,1),:),vr(fc(:,2),:),vn(fc(:,1),:),vn(fc(:,2),:));
[pt2,nvn2] = subchop(vr(fc(:,2),:),vr(fc(:,3),:),vn(fc(:,2),:),vn(fc(:,3),:));
[pt3,nvn3] = subchop(vr(fc(:,3),:),vr(fc(:,1),:),vn(fc(:,3),:),vn(fc(:,1),:));

pt = [pt;pt2;pt3];
nvn = [nvn;nvn2;nvn3];
r = ctransform(unt,gunit,pt);

r(:,1) = r(:,1)+c(1);
r(:,2) = r(:,2)+c(2);
r(:,3) = r(:,3)+c(3);

if nargin == 5
    switch top
        case 'top'
            indx = find(nvn(:,3)>0);                        
        otherwise
            indx = find(nvn(:,3)<0);
    end
    r = r(indx,:);
    nvn = nvn(indx,:);
end
            
                

function [r,vn] = subchop(avr,bvr,avn,bvn)

%finding those vertices that cross j = 0 plane
LHaindx = find(avr(:,2)<0);
LHbindx = find(bvr(:,2)<0);
RHaindx = find(avr(:,2)>=0);
RHbindx = find(bvr(:,2)>=0);

crsindx = union(intersect(LHaindx,RHbindx),intersect(LHbindx,RHaindx));

avr = avr(crsindx,:);
bvr = bvr(crsindx,:);
avn = avn(crsindx,:);
bvn = bvn(crsindx,:);

if isempty(avr) | isempty(bvr)
    r = [];
    vindex = [];
    return
end


%yz plane to get z coordinate

ayz = avr(:,[2,3]);
byz = bvr(:,[2,3]);

slp = ayz-byz;
slp = slp(:,2)./slp(:,1);

zd = ayz(:,2)-(ayz(:,1).*slp);


%yx plane to get x coordinate

ayx = avr(:,[2,1]);
byx = bvr(:,[2,1]);

slp = ayx-byx;
slp = slp(:,2)./slp(:,1);

xd = ayx(:,2)-(ayx(:,1).*slp);



r = xd;
r(:,2) = 0;
r(:,3) = zd;


%getting vertex normals

vn = makeunit((avn+bvn)/2);
