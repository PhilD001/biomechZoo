function Tz = free_torque(F,M,COP,x,y)

% FREE_TORQUE calculates the free torque about the z-axis 
%
% Tz = FREE_TORQUE(F,M)
%
% ARGUMENTS
%    F   ...  forces (fx,fy,fz)
%    M   ...  moments (mx,my,mzz)
%    COP ... cop coordinates (columns x,y,z)
%
% RETURNS
%    Tz  ... Free torque as column vector

% Updated Nov 18th 2008
%
% -Finally using the right formula based on kwon3d
% http://www.kwon3d.com/theory/grf/cop.html
%
% Updated January 2011
% - we do not need the x and y if we have COP output from Vicon
error('should not be used')

if nargin ==3
    x = 0;
    y = 0; 
end

Fx = F(:,1);
Fy = F(:,2);

Mz = M(:,3);

COPx = COP(:,1);
COPy = COP(:,2);

one  = ones(length(COPx),1);
x = x.*one;

one  = ones(length(COPy),1);
y = y.*one;

Tz = Mz - (COPx-x).*Fy + (COPy -y).*Fx;
