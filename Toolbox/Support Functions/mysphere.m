function varargout = mysphere(res);

[x,y,z] = sphere(res);

[varargout{1},varargout{2}] = surface2patch(x,y,z);


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
    