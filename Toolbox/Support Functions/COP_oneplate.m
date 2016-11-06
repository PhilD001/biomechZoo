function COP = COP_oneplate(F,M,a,b,c,cutoff)

% COP = COP_ONEPLATE(F,M,a,b,c,cutoff) calculats COP of force plates 
%
%
% ARGUMENTS
%  F      ...  n x 3 matrix w/ columns Fx, Fy, Fz. Directly from FP data
%  M      ...  n x 3 matrix w/ columns Mx, My, Mz, moments of force plate
%  a,b,c  ...  true coordinates from manufacturer (metres) centre of plate
%  cutoff ...  Threshold from which to start computing COP. Default 20N
%
% RETURNS
%  COP  ...  struct containing COP info for both plates 
%
% Updated Jan 14th 2008
%   -replace NaN with first and last values of array
%   -cutoff is back to 60N to be consistent with the rest of thesis
%
% Updated Jan 4th 2013
%  - cutoff magnitude default is 20N to match vicon output
%
% Updated Jan 7th 2013
% - fix removal of NaNs at start and end of data
%
% NOTES
%  -COP coordinates are outputted in the original FP coordinate system, ie
%  origin in is center of FPlate
%  - Moments must be expressed about the true center of the plate.
%    moment adjustment calculations (based on AMTI) not done here...use
%   moment_coordchange.m
%  Mx = Mxo - Fy*zo - Fz*yo
%  My = Myo + Fx*zo + Fz*xo
%  Mz = Mzo - Fx*yo - Fy*xo
%
% Current McGill Biomechanics Lab FP AMTI OR6-5-1000 s.n. 3403
%
% 
% x = -0.778/1000; %mm to m
% y =  0.459/1000;
% z = -37.635/1000;


%-------------------create column matrices for each dimension-------


if nargin ==5
    cutoff = 20;
end

mag = sqrt(diag(F*F'));         % this one can cause a memory error if too much data


s = find(mag>cutoff,1,'first');
e = find(mag>cutoff,1,'last');

Fx = F(:,1);
Fy = F(:,2);
Fz = F(:,3);

Mx = M(:,1);
My = M(:,2);


%-------------------FORCE PLATE 1---------------

%----2007 version-----
x_cop =  ( ( My+(c.*Fx) )./ Fz ).*(-1) +a ;
y_cop =     (( Mx - (c.*Fy) )./ Fz )+b ;
z_cop = zeros(length(x_cop),1);


%--------AMTI version----
% 
% x_cop =  ( ( My+(z.*Fx) )./ Fz ).*(-1)  ;
% y_cop =     (( Mx - (z.*Fy) )./ Fz ) ;

% x_cop(indx) = NaN;
% y_cop(indx) = NaN;

% 
% x_cop(1:s-1) = x_cop(s);
% x_cop(e+1:end) = x_cop(e);

x_cop(1:s-1) = NaN;
x_cop(e+1:end) = NaN;


y_cop(1:s-1) = NaN;
y_cop(e+1:end) = NaN;


z_cop(1:s-1) = NaN;
z_cop(e+1:end) = NaN;


COP = [x_cop y_cop z_cop];
