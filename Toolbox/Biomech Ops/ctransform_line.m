function vout = ctransform_line(vin,c1,c2)

% vout = CTRANSFORM_LINE(vin,c1,c2) will transform a vector from c1 to c2 (T2/1)
%
% ARGUMENTS
%   vin ... n by 3 matrix in c1 rows = samples; columns X Y Z
%   c1  ... initial coordinate system 3 by 3 matrix rows = i,j,k columns =X,Y,Z
%   c2  ... final coordinate system 3 by 3 matrix rows = i,j,k columns =X,Y,Z
%
% Notes
% - see Kwon3d for details http://www.kwon3d.com/theory/transform/transform.html
%
% See also bmech_ctransform, ctransform_data, ctransform, vecrotate


% Revision History
%
% Created by JJ Loh 2006 or earlier




% unit vectors for coordinate system 1
%
ic1 = c1(1,:);
jc1 = c1(2,:);
kc1 = c1(3,:);

% unit vectors for coordinate system 2
%
ic2 = c2(1,:);
jc2 = c2(2,:);
kc2 = c2(3,:);

% Transformation matrix
%s
t = [dot(ic1,ic2),dot(ic1,jc2),dot(ic1,kc2);...
     dot(jc1,ic2),dot(jc1,jc2),dot(jc1,kc2);...
     dot(kc1,ic2),dot(kc1,jc2),dot(kc1,kc2)];

vout = vin*t; 


