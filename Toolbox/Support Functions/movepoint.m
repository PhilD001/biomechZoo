function [nextpt,norm] = movepoint(curpt,delta,pch,pln);

vr = get(pch,'vertices');
vn = get(pch,'vertexnormals');
fc = get(pch,'faces');
if nargin == 3
    ax = get(pch,'parent');    
    cpos = get(ax,'cameraposition');
    ctarg = get(ax,'cameratarget');
    upvec = get(ax,'cameraupvector')+cpos;
    pln = [cpos;ctarg;upvec];
end
[nextpt,norm] = chop(vr,fc,vn,pln,curpt,delta);



function [r,nvn] = chop(vr,fc,vn,pln,curpt,delta);

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
if dot(k,pln(3,:)-c)<0
    k = -k;
end
unt = makeunit([i;j;k]);

gunit = [1 0 0;0 1 0;0 0 1];

vr = ctransform(gunit,unt,vr);
vn = ctransform(gunit,unt,vn);
curpt = ctransform(gunit,unt,curpt-c);

tvn = vn;
[pt,nvn] = subchop(vr(fc(:,1),:),vr(fc(:,2),:),vn(fc(:,1),:),vn(fc(:,2),:));
[pt2,nvn2] = subchop(vr(fc(:,2),:),vr(fc(:,3),:),vn(fc(:,2),:),vn(fc(:,3),:));
[pt3,nvn3] = subchop(vr(fc(:,3),:),vr(fc(:,1),:),vn(fc(:,3),:),vn(fc(:,1),:));

pt = [pt;pt2;pt3];
nvn = [nvn;nvn2;nvn3];


indx = find(nvn(:,3)>0);
pt = pt(indx,:);

curpt(1) = curpt(1)+delta;
pt = sortrows(pt,1);
[zi,vn] = myinterp1(pt(:,1),pt(:,3),curpt(1),nvn);

npt = [curpt(1),0,zi];

npt = ctransform(unt,gunit,npt)+c;
r = npt;
nvn = ctransform(unt,gunit,vn);

function [y,vn] = myinterp1(xd,yd,ix,n);

eindx = find(xd==ix);
if ~isempty(eindx)
    y = yd(eindx(1));
    return
end
tindx = min(find(xd>ix));
bindx = max(find(xd<ix));

if isempty(tindx) | isempty(bindx)
    y = NaN;
    vn = NaN;
    return
end


   
slp = (yd(tindx)-yd(bindx))/(xd(tindx)-xd(bindx));
int = yd(tindx)-slp*xd(tindx);
y = slp*ix+int;

vn = mean([n(tindx,:);n(bindx,:)]);


            
                

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
    vn = [];
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
