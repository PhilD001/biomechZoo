function [n,point,phi,t]=screw(T,intersect);
% Calculation of the screw axis
% function [n,point,phi,t]=screw(T)
% Input:    T   matrix containing the rotation matrix and transl. vector
%               [R;[t1,t2,t3]'; 0 0 0 1]
%	    intersect	location of the screw axis where it intersects either the x=0 (intersect=1),
%                       the y=0 (intersect=2), or the z=0 (intersect=3) plane.
%			default: intersect=3
% Output:   n       unit vector with direction of helical axis
%           point   point on helical axis
%           phi     rotation angle (in deg)
%           t       amount of translation along screw axis
%
% Comments:     Note that phi is b/w 0 and 180 deg. Right handed screw
%               axis system. The "sign" of phi can be checked with direction
%               of the unit vector (n).
% References:   (1) Spoor and Veldpaus (1980) Rigid body motion calculated
%                   from spatial co-ordinates of markers. 
%                   J Biomech 13: 391-393
%               (2) Berme, Cappozzo, and Meglan. Rigid body mechanics
%                   as applied to human movement studies. In Berme and 
%                   Cappozzo: Biomechanics of human movement.
%
% Author:	 Christoph Reinschmidt, HPL, UofCalgary
% Date:          Oct. 03, 1994
% Last Changes:  Nov-20-96

if nargin==1, intersect=[3]; end

R=T(1:3,1:3);

% tmp is matrix in equ. 31 (Spoor and Veldpaus, 1980)
tmp=[R(3,2)-R(2,3);R(1,3)-R(3,1);R(2,1)-R(1,2)];

%calculating n using equ. 31 and 32 (Spoor and Veldpaus, 1980)
n=tmp/norm(tmp); 

% calculating phi either with equ. 32 or 34 (Spoor and Veldpaus, 1980)
% depending if sin(phi) smaller of bigger than 0.5*SQRT(2)
if norm(tmp) <= sqrt(2) 
      phi=rad2deg(asin(0.5*norm(tmp)));
else  phi=rad2deg(acos(0.5*(R(1,1)+R(2,2)+R(3,3)-1)));
end

%if phi approaches 180 deg it is better to use the following:
%(see Spoor and Veldpaus Eq. 35,36)
if phi>135;  
   b=[0.5*(R+R')-cos(deg2rad(phi)) * eye(3)];
   b1=[b(:,1)]; b2=[b(:,2)]; b3=[b(:,3)];
   btmp=[b1'*b1;b2'*b2;b3'*b3];
   [bmax,i]=max(btmp);
   n=b(:,i)/sqrt(bmax);
   if sign(R(3,2)-R(2,3)) ~= sign(n(1,1));  n=n.*(-1); end;
end

t=n'*T(1:3,4);

% calculate where the screw axis intersects the plane as defined in 'intersect'
Q=R-eye(3);
Q(:,intersect)=-n;
point=Q\[T(1:3,4).*[-1]];
point(intersect,1)=[0];
