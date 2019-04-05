function [data,rKW,lKW,rAW,lAW] = jointwidthPiG_data(data,markerDiam)

% [data,rKW,lKW,rAW,lAW] = JOINTWIDTHPIG_DATA(data,markerDiam) computes
% knee and ankle joint widths for PiG data
%
% ARGUMENTS
%  data        ... Zoo structure
%  markerDiam  ... Diameter of marker in mm
%
% RETURNS
%  data        ... Zoo structure with joint widths appended
%  rKW         ... right knee width (mm)
%  lKW         ... left knee width (mm)
%  rAW         ... right ankle width (mm)
%  lAW         ... left ankle width (mm)
%
% NOTES
% - This method is only used when anthropometric information is missing
%   from anthro branch

error('not implemented')