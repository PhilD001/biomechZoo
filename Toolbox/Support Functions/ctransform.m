function vout = ctransform(c1,c2,vec)

% vout = CTRANSFORM(c1,c2,vec) will transform a vector from c1 to c2 (T2/1)
%
% ARGUMENTS
%   c1    ... initial coordinate system 3 by 3 matrix rows = i,j,k columns =X,Y,Z
%   c2    ... final coordinate system 3 by 3 matrix rows = i,j,k columns =X,Y,Z
%   vec   ... n x 3 matrix in c1 rows = samples; columns X Y Z
%
% RETURNS
%   vout  ... n x 3 matrix in c2 rows = samples; columns X Y Z 
%
%
% Example
% Let us consider two coordinate systems
% c1 = [1 0 0;  0 1 0; 0 0 1]  % in line with the global coordinate system
% c2 = [0 1 0; -1 0 0; 0 0 1]  % rotated version of c1 90deg about z axis
% 
% what would be the coordinates of a vector vec = [2 0 0] from c1 expressed in c2?
%
% vout = ctransform(c1,c2,vec)
%
% vout = [0 -2 0]
%
% see also vecrotate, gunit

% Revision History
%
% Created by JJ Loh approx 2004
%
% Notes
% - Please see Kwon3d for details http://www.kwon3d.com/theory/transform/transform.html



% unit vectors for coordinate system 1
ic1 = c1(1,:);
jc1 = c1(2,:);
kc1 = c1(3,:);

% unit vectors for coordinate system 2
ic2 = c2(1,:);
jc2 = c2(2,:);
kc2 = c2(3,:);

% Transformation matrix
t = [dot(ic1,ic2),dot(ic1,jc2),dot(ic1,kc2);...
     dot(jc1,ic2),dot(jc1,jc2),dot(jc1,kc2);...
     dot(kc1,ic2),dot(kc1,jc2),dot(kc1,kc2)];

if nargin == 3
     vout = vec*t; % orginal JJ
else
    vout = t;
end


