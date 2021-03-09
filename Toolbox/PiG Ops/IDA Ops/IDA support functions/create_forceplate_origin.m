function [p1,p2,p3,Or1,Or2,Or3] = create_forceplate_origin

% NOTES
%- this function is untested!
% created August 2013 

s = filesep;

b = which('vicon2ida.m');
indx = strfind(b,s);
base = b(1:indx(end));  % this is where sample files are

fpfile = [base,'forceplatecoordinates_examplefile.xls'];

fdata = xlsread(fpfile);
p1 = fdata(1,:);
p2 = fdata(2,:);
p3 = fdata(3,:);
Or1 = fdata(5,:);
Or2 = fdata(6,:);
Or3 = fdata(7,:);