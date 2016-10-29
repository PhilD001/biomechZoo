function pt = pointonline(p1,p2,pos)

% pt = POINTONLINE(p1,p2,pos) returns a point on a line a distance pos from p1
%
% ARGUMENTS
%  p1  ...  first point m x 3 matrix
%  p2  ...  second point m x 3 matrix
%  pos ...  distance from p1
%
% RETURN
%  pt  ...  point on line between p1 and p2, a distance pos from p1
%
% ex find the midpoint between v1 = [8 3 2], v2 = [23 4 1];
%
% pt = pointonline(v1,v2,0.5)
%
% Created by Phil Dixon January 2011
%
% Updated October 2012
% - function can handle nx3 matrices

l = p2-p1;

[r,~] = size(l);

if r ==1    
    pt(1) = p1(1)+l(1)*pos;
    pt(2) = p1(2)+l(2)*pos;
    pt(3) = p1(3)+l(3)*pos;
else
    pt = zeros(size(l));
    pt(:,1) = p1(:,1)+l(:,1).*pos;
    pt(:,2) = p1(:,2)+l(:,2).*pos;
    pt(:,3) = p1(:,3)+l(:,3).*pos;
end