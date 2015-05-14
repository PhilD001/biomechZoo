function index = point2line(pt,ln)

%this function returns the row index of the matrix of points (pt) closest
%to the tail and to the line
%line defined by ln (tail to head)

tl = ln(1,:);
hd = ln(2,:);

k = [0 0 1];
i = hd-tl;
j = cross(i,k);
k = cross(i,j);
unt = makeunit([i;j;k]);

%creating vectors from tail to each point
pt(:,1) = pt(:,1)-tl(1);
pt(:,2) = pt(:,2)-tl(2);
pt(:,3) = pt(:,3)-tl(3);

%transform the vectors into the domain i,j,k
pt = ctransform([1 0 0;0 1 0;0 0 1],unt,pt);

%taking out the i component which is distance along the line from the tail
%to the perpendicular vector from the line to the point;

pt(:,1) =0;
dev = sqrt(diag(pt*pt'));


%finding the minimum
r = find(dev==min(dev));
index = r(1);