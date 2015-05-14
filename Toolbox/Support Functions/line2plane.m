function r = line2plane(ln,plane)
%ln is represented by two points
%plane is represented by: row1 = point on plane, row2 = normal unit vector;
p3 = plane(1,:);
n = plane(2,:);

p1 = ln(1,:);
p2 = ln(2,:);

u = dot(n,p3-p1)/dot(n,p2-p1);

r = p1+u*(p2-p1);