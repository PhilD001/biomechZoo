function omega = ang_velocity(Euler,fsamp,f)

%   ANG_VELOCITY calculates angular velocity of segments
%
%  ARGUMENTS
%
%   phi      ...  column vector of euler angles (rot. about K)
%   theta    ...  column vector of euler angles (rot. about line of nodes)
%   psi      ...  column vecto of euler angles (rot. about k)
%   fsamp    ...  sampling rate
%
%   RETURNS
%
%   omega   ...  angular velocity matrix in LOCAL (xyz)
% 
% Updated Jan 13th 2008
% -acceps any sampling rate
%
% Updated Jan 22 2011
%
% - Changed the order of some of the Euler outputs to match Vaughan data
% 
% Updated Jan 27th
%  - Order change was incorrect. Data matches Vaughan. All data is in Local
% vuaghan local is !SegmentAngleLeftThighVelocity
%
% Updated August 2013
% - user has control over choice of filtering

theta = Euler(:,1);
phi = Euler(:,2);
psi = Euler(:,3);

omega_x = deriv_line(phi,fsamp,f).*sin(theta).*sin(psi)+deriv_line(theta, fsamp,f).*cos(psi);
omega_y = deriv_line(phi,fsamp,f).*sin(theta).*cos(psi)-deriv_line(theta, fsamp,f).*sin(psi);
omega_z = deriv_line(phi,fsamp,f).*cos(theta)+deriv_line(psi,fsamp,f);


omega = [omega_x omega_y omega_z];


