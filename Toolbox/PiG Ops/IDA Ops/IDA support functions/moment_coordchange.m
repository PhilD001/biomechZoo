function nfpdata = moment_coordchange(rfpdata,coord)


% This function will convert the raw moments outputted from the force plate
% (expressed avout the shear center) to moments expressed about the true
% center based on coordinates of true center
%
% data = moment_coordchange(data,coord)
%
% ARGUMENTS 
%   rfpdata    ...   raw force plate data as matrix. rows: samples, 
%                    columns Fx, Fy, Fz,Mx, My, Mz
%   coord      ...   coordindates of true center of plate (supplied by manufacturer)              
%
% RETURNS
%   nfdata     ...   new force plate data with moments expressed about
%                    centre of plate
%
%
%
%
% Created by Phil Dixon Dec 2008 
%
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008, 
% Phil Dixon, Montreal, Qc, CANADA





%======DO NOT EDIT==============




% -- coordinates of true center---
x0 = coord(1);
y0 = coord(2);
z0 = coord(3);


%----split raw fp data into components----

Fx = rfpdata(:,1);
Fy = rfpdata(:,2);
Fz = rfpdata(:,3);
Mx0 = rfpdata(:,4);
My0 = rfpdata(:,5);
Mz0 = rfpdata(:,6);


% ----modify moment channels------

Mx = Mx0 - Fy*z0 - Fz*y0;
My = My0 + Fx*z0 + Fz*x0;
Mz = Mz0 - Fx*y0 - Fy*x0;


%-----create new fp data--------

nfpdata = [Fx Fy Fz Mx My Mz];