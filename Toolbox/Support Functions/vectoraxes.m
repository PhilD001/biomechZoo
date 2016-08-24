function [x,y,z,cdata] = vectoraxes
x = [];
y = [];
z = [];
cdata = [];

for i = 1:3
    clr = zeros(1,3);
    clr(i) = 1;    
    [xd,yd,zd] = arrow([0 0 0],clr,5);

    
    c(:,:,1) = ones(size(xd))*clr(1);
    c(:,:,2) = ones(size(xd))*clr(2);
    c(:,:,3) = ones(size(xd))*clr(3);

    x = [x;xd];
    y = [y;yd];
    z = [z;zd];
    cdata = [cdata;c];
end
  
function [x,y,z] = arrow(trn,vec,res);

ax = findk2obj('axes');

m = [0        0         0;...
        0   -0.0277         0;...
        0   -0.0346    0.0180;...         
        0   -0.0346    0.7387;...
        0   -0.1000    0.7477;...
        0   -0.0104    1];

mg = sqrt(vec*vec');
m = m*mg;

[x,y,z] = makesurface(m,res);

gunt = [1 0 0;0 1 0;0 0 1];

if vec(1:2) == [0 0]
    x = x+trn(1);
    y = y+trn(2);
    z = z+trn(3);
    return
end
i = cross(vec,[0 0 1]);
k = vec;
j = cross(i,k);
ort = [i;j;k];
mg = sqrt(diag(ort*ort'));
ort = ort./[mg,mg,mg];
[x,y,z] = mtransform(ort,gunt,x,y,z);
x = x+trn(1);
y = y+trn(2);
z = z+trn(3);

function [x,y,z] = makesurface(m,lnum);

degstep = 360/lnum;

xstk = m(:,1);
ystk = m(:,2);
zstk = m(:,3);

tvec = [1 0 0];
for i = 1:lnum-1;
    tm = [xstk(:,end),ystk(:,end),zstk(:,end)];
    nm = vecrotate(tm,degstep,'z');
    xstk = [xstk,nm(:,1)];
    ystk = [ystk,nm(:,2)];
    zstk = [zstk,nm(:,3)];
end
x = [xstk,xstk(:,1)];
y = [ystk,ystk(:,1)];
z = [zstk,zstk(:,1)];
