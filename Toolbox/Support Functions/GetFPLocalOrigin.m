function [p1,p2,p3] = GetFPLocalOrigin(zdata)

% extracts local origin from zdata
%
% created August 15th 2013 by Philipe C. Dixon

% - For oxford gait lab, the output of this function should be
%
% p1 = [0.0003302	0.0002286	0.04034];
% p2 = [0.001397	-0.0000254	0.03757];
% p3 = [0.0000508	-0.001473	0.03873];

p3 = [];
r =  zdata.zoosystem.Analog.FPlates.LOCALORIGIN; % c3d file contains this info

[~,cols] = size(r);

p1 = (r(:,1)/1000)';
p2 = (r(:,2)/1000)';

if cols==3
    p3 = (r(:,3)/1000)';
end

% check for Oxford switched force plate position in 2014
% 
% if isnear(p2(1),0.0003302 ,0.001)
%     
%    disp('This is a misordered OGL force plate file, switching FP info')
%   p2 = [0 0 0];
%    
% end