function [vr,fc] = fan(dis,vec)

coeff = max(sqrt(diag(vec*vec')));
vec = makeunit(vec)*coeff;

ang = angle(vec(1,:),vec(2,:));
i = vec(1,:);
k = cross(vec(1,:),vec(2,:));
j = -cross(i,k);

%the orientation is xaxis is along vec(1,:) yaxis is a positive projection of  vec(2,:)

nang = (0:10:ang);
if nang(end) ~= ang
    nang(end+1) = ang;
end

nvec = vecrotate([coeff 0 0],nang,'z');
unt = makeunit([i;j;k]);

nvec = ctransform(unt,gunit,nvec);
nvec = [0 0 0;nvec];
nvec = displace(nvec,dis);

vr = nvec;
[rw,cl] = size(nvec);
fc = ones(rw-2,1);
fc(:,2) = (2:rw-1);
fc(:,3) = fc(:,2)+1;



function r = angle(m1,m2)

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));

r = r*180;
r = r/pi;
