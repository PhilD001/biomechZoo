function Tz = free_torque_global(F,M,COPg,Or)

% FREE_TORQUE_GLOBAL calculates the free torque about the z-axis with  
%
% Tz = FREE_TORQUE(F,M)
%
% ARGUMENTS
%    F   ...  forces (fx,fy,fz)
%    M   ...  moments (mx,my,mzz)
%    COP ...  cop coordinates in GLOBAL (columns x,y,z) in m
%    Or  ...  origin of force plate (GLOBAL)
%
% RETURNS
%    Tz  ... Free torque as column vector
%
% Created 2006 by Philippe C. Dixon
%
% Updated Nov 18th 2008
%
% -Finally using the right formula based on kwon3d
% http://www.kwon3d.com/theory/grf/cop.html
%
% Updated Dec 28th 2012
%
% - there is no need to transform quantities to local unless COP are in local. This might be the case if data
%   are collected directly from a force plate (no vicon system)
% - simplified code gives same results as original Nov 18th code
% - tested using Aschau data - works



%---ORIGINAL NOV 18th 2008 CODE----
% % 
% one  = ones(length(COPg(:,1)),1);
% 
% COPx = COPg(:,1) - Or(1).*one;
% COPy = COPg(:,2) - Or(2).*one;
% 
%  
% x = xy(1).*one;
% y = xy(2).*one;
% 
% Fx = F(:,1);
% Fy = F(:,2);
% Mz = M(:,3);
% 
% 
% Tz = Mz - (COPx-x).*Fy + (COPy -y).*Fx;




%---COMPUTE QUANTITIES IN GLOBAL----
% 
one  = ones(length(COPg(:,1)),1);

Fx = F(:,1);
Fy = F(:,2);
Mz = M(:,3);

COPgx = COPg(:,1);
COPgy = COPg(:,2);

ox = Or(1).*one;
oy = Or(2).*one;

Tz = Mz - (COPgx-ox).*Fy + (COPgy -oy).*Fx;





