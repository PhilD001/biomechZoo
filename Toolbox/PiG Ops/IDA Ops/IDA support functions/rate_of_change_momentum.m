function Ldot = rate_of_change_momentum (I, omega, alpha)

%   RATE_OF_CHANGE_MOMENTUM returns the rate of change of the angular
%   momentum (L)
%
%   ARGUMENTS:
%
%   I     ...  moment of inertia matrix calculated in ANTHRO
%              [ I_x   I_y   I_z]
%                
%   omega ...  angular velocity matrix calculated in ANG_VELOCITY
%   alpha ...   angular acceleration matrix calculated in ANG_ACC
%
%   RETURNS
%
%   Ldot ...  rate of change of angular momentum
%
% Notes: see Vaughan1999 appendix B p99

Ix = I.x;   %FlX/EXT
Iy = I.y;   %ABD/ADD
Iz = I.z;   %INT/EXT

omega_x = omega(:,1);
omega_y = omega(:,2);
omega_z = omega(:,3);

alpha_x = alpha(:,1);
alpha_y = alpha(:,2);
alpha_z = alpha(:,3);

Ldot_x = Iz.*alpha_x +(Ix-Iy).*omega_y.*omega_z;
Ldot_y = Iy.*alpha_y +(Iz-Ix).*omega_x.*omega_z;
Ldot_z = Ix.*alpha_z +(Iy-Iz).*omega_x.*omega_y;

Ldot = [Ldot_x  Ldot_y  Ldot_z];
       
