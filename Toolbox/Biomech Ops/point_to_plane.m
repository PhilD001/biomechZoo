function [proj_p1] = point_to_plane(p1,p2,p3,p4)

% proj_p1 = POINT_TO_PLANE(p1,p2,p3,p4) projects marker p1 into a plane defined by p2, p3, p4
%
% ARGUMENTS
%     p1         : n x 3 array
%                  Point to be projected onto a plane
%     p2, p3, p4 : n x 3 arrays defining a plane    
% 
% RETURNS
%     proj_p     : p1 projected orthogonally onto the plane of p2, p3, and p4


% create a vector from a point on the plane that points to p1
w = p1 - p2;

% create vector normal to the plane
n = cross(p2-p4,p3-p4);

% make each row of n a unit vector and calculate t
t = zeros(size(n));
for i = 1:size(n,1)
    n(i,:) = n(i,:)/magnitude(n(i,:));
    t(i,:) = dot(w(i,:),n(i,:))*n(i,:);
end

% subtract t from w and add back p2 to get coordinates of projected point
proj_p1 = (w-t) + p2;