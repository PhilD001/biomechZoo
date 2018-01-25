function [vr,fc] = surface2patch(x,y,z)

% [vr,fc] = SURFACE2PATCH(x,y,z) converts surface orientation data to patch
% vertices format
%
% ARGUMENTS
% x,y,z      ...  surface data
%
% RETURNS
% vr         ...  vertices for patch object
% fc         ...  faces for patch object 
%
% Example
% [x,y,z] = cylinder(10,1);
% [vr,fc] = surface2patch(x,y,z);

% Created by JJ Loh 

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
for i = 1:length(findx)-1
    vec1 = (findx(i)+1:findx(i+1))';    
    if i+1 == length(findx)
        vec2 = (findx(1)+1:findx(2))';
    else
        vec2 = (findx(i+1)+1:findx(i+2))';
    end
    lvec = length(vec1);
    fplate = [vec1(1:lvec-1),vec1(2:lvec),vec2(2:lvec),vec2(1:lvec-1)];
    fc = [fc;fplate];
end