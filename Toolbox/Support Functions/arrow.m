function [x,y,z] = arrow(trn,vec,res,mmg)


% trn  ... origin of vector
% vec  ... head of vector
% res  ... thickness of vector

m = [0        0         0;...
    0   -0.0277         0;...
    0   -0.0346    0.0180;...
    0   -0.0346    0.7387;...
    0   -0.1000    0.7477;...
    0   -0.0104    1];

mg = sqrt(vec*vec');
if nargin <4
    mmg = min(mg,50);
end

m(:,3) = m(:,3)*mg;
m(:,2) = m(:,2)*mmg;
m(:,1) = m(:,1)*mmg;

[x,y,z] = makesurface(m,res);

gunt = [1 0 0;0 1 0;0 0 1];


if vec(1:2) == [0 0]
    if nargout == 3
        x = x+trn(1);
        y = y+trn(2);
        z = z+trn(3);
        return
    else
        x = x+trn(1);
        y = y+trn(2);
        z = z+trn(3);
        [x,y] = surface2patch(x,y,z);
        return
    end
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
if nargout == 2
    [x,y] = surface2patch(x,y,z);
end


function [x,y,z] = makesurface(m,lnum)

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


function [vr,fc] = surface2patch(x,y,z)

[rw,cl] = size(x);
vr = [];
fc = [];
findx = [];
for i = 1:cl
    vplate = [x(:,i),y(:,i),z(:,i)];
    vr = [vr;vplate];
    findx = [findx;length(vr(:,1))];
    
end

findx = [0;findx];
for i = 1:length(findx)-1;
    vec1 = (findx(i)+1:findx(i+1))';    
    if i+1 == length(findx);
        vec2 = (findx(1)+1:findx(2))';
    else
        vec2 = (findx(i+1)+1:findx(i+2))';
    end
    lvec = length(vec1);
    fplate = [vec1(1:lvec-1),vec1(2:lvec),vec2(2:lvec),vec2(1:lvec-1)];
    fc = [fc;fplate];
end
    

    
    
    
    
    
    