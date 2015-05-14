function nfc = rotatefaces(vr,fc,outside)

lfc = length(fc(:,1));
intpt = mean(vr);
for findx = 1:lfc
    fplate = fc(findx,:);
    a = vr(fplate(1),:);
    b = vr(fplate(2),:);
    c = vr(fplate(3),:);
    
    cnt = mean([a;b;c]);
    
    k = cross(a,b)+cross(b,c)+cross(c,a);
    % make sure the k vector is pointing outside
    vec = outside-mean([a;b;c]);
    if dot(vec,k)<0
        k = -k;
    end
    i = a-cnt;
    j = cross(i,k);
    unt = makeunit([i;j;k]);
    gunit = [1 0 0;0 1 0;0 0 1];
    m = [a;b;c];
    m(:,1) = m(:,1)-cnt(1);
    m(:,2) = m(:,2)-cnt(2);
    m(:,3) = m(:,3)-cnt(3);
    
    m = ctransform(gunit,unt,m);
    ang = calcangle(m);
    indx = order(ang);
    fplate = fplate(indx);
    fc(findx,:) = fplate;
end
nfc = fc;

function r = calcangle(vr)
lvr = length(vr(:,1));
vr2(1:lvr,1)= 1;
vr2(1:lvr,2) = 0;
vr2(1:lvr,3) = 0;

a = angle(vr,vr2);
for i = 1:length(a)
    q = quadrant(vr(i,:));
    switch q
        case 3
            a(i) = 360-a(i);
        case 4
            a(i) = 360-a(i);
    end
end
r = a;
            

function r = angle(m1,m2)

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));

r = r*180;
r = r/pi;

function r = quadrant(pt);

if pt(1) >=0 & pt(2)>=0
    r = 1;
elseif pt(1)<0 & pt(2)>=0
    r = 2;
elseif pt(1)<0 & pt(2)<0
    r = 3;
else
    r = 4;
end

function r = order(index);
uindx = unique(index);
r = [];
for i = 1:length(index)
    r = [r,find(index==uindx(i))];
end