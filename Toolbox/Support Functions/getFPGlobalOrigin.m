function [globalOr,orient] = getFPGlobalOrigin(data)

% GetFPGlobalOrigin extracts the coordinates of the centre of each force
% plate in GCS
%
% Notes
% - corners start in top right corner and go counter clockwise
% - For oxford gait lab, the output of this function should be
%
% Or1 = [0.232	0.254	0];
% Or2 = [0.232	-0.324	0];
% Or3 = [0.233	0.916	0];
%
% - values are in mm
%
% Updated by Philippe C. Dixon July 2017
% - Adds height of force plates for situations where force plates are not 
%   on the ground. E.g. stair case study


% compute global origin
%
globalOr = struct;
nplates = data.zoosystem.Analog.FPlates.NUMUSED;

for i = 1:nplates
    C1 = makerow(data.zoosystem.Analog.FPlates.CORNERS(1:2,1,i));
    C2 = makerow(data.zoosystem.Analog.FPlates.CORNERS(1:2,2,i));
    C3 = makerow(data.zoosystem.Analog.FPlates.CORNERS(1:2,3,i));
    C4 = makerow(data.zoosystem.Analog.FPlates.CORNERS(1:2,4,i));
    height = makerow(data.zoosystem.Analog.FPlates.CORNERS(3,1,i));
    Or = intersection(C1,C3,C2,C4);
    Or = [Or height]/1000;
    
    y = [makeunit(C2-C3) 0];  
    x = [makeunit(C4-C3) 0];
    z = cross(x,y);
    
    globalOr.(['FP',num2str(i)]) = Or; 
    orient.(['FP',num2str(i)]) = [x;y;z]; 
end






