function alpha = ang_acc(Euler,fsamp,f)

%   ANG_ACC calculates angular acc of segments
%
%  ARGUMENTS
%
%   Euler   ...  theta, phi, psi angles  
%   fsamp   ...  sampling rate
%   f       ...  choice to filter. f = 0 no, f=1 yes
%   cut     ... cut-off frequency for filter 
%
%   RETURNS
%   alpha   ...  angular acceleration matrix (xyz)
%
% Updated Jan 13th 2008
% -acceps any sampling rate
%
% Updated August 2013
% - user has more control over filtering choice 
% - walk deriv replaced by deriv_line


theta = Euler(:,1);
phi = Euler(:,2);
psi = Euler(:,3);

alpha_x = deriv_line(deriv_line(phi,fsamp,f),fsamp,f).*sin(theta).*sin(psi)+deriv_line(phi, fsamp,f).*deriv_line(theta, fsamp,f).*cos(theta).*sin(psi)...
          +deriv_line(phi,fsamp,f).*deriv_line(psi, fsamp,f).*sin(theta).*cos(psi)+deriv_line(deriv_line(theta,fsamp,f),fsamp,f).*cos(psi)...
          -deriv_line(theta, fsamp,f).*deriv_line(psi, fsamp,f).*sin(psi);
      
alpha_y = deriv_line(deriv_line(phi,fsamp,f),fsamp,f).*sin(theta).*cos(psi)+ deriv_line(phi,fsamp,f).*deriv_line(theta,fsamp,f).*cos(theta).*cos(psi)...
          -deriv_line(phi,fsamp,f).*deriv_line(psi, fsamp,f).*sin(theta).*sin(psi)-deriv_line(deriv_line(theta,fsamp,f),fsamp,f).*sin(psi)...
          -deriv_line(theta, fsamp,f).*deriv_line(psi, fsamp,f).*cos(psi);

alpha_z = deriv_line(deriv_line(phi,fsamp,f),fsamp,f).*cos(theta) -deriv_line(phi,fsamp,f).*deriv_line(theta, fsamp,f).*sin(theta)...
          +deriv_line(deriv_line(psi,fsamp,f),fsamp,f);
      

alpha = [alpha_x alpha_y alpha_z];
