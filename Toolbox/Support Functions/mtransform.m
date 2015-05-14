function [x,y,z] = mtransform(unt1,unt2,xdata,ydata,zdata);

[r,c] = size(xdata);

x = [];
y = [];
z = [];

for i = 1:c
    vec = [xdata(:,i),ydata(:,i),zdata(:,i)];
    vec = ctransform(unt1,unt2,vec);
    x = [x,vec(:,1)];
    y = [y,vec(:,2)];
    z = [z,vec(:,3)];
end
