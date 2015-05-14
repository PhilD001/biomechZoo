function [Or1,Or2,Or3,x1,y1,z1,x2,y2,z2,x3,y3,z3] = GetFPGlobalOrigin(zdata)

% GetFPGlobalOrigin extracts the coordinates of the centre of each force
% plate in GCS
%
%
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

Or3 = [];
x3 = [];
y3 = [];
z3 = [];

[~,~,plates] = size(zdata.zoosystem.Analog.FPlates.CORNERS);

C1_1 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,1,1));
C2_1 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,2,1));
C3_1 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,3,1));
C4_1 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,4,1));

Or1 = intersection(C1_1,C3_1,C2_1,C4_1);
Or1 = [Or1 0]/1000;

y1 = [makeunit(C2_1-C3_1) 0];
x1 = [makeunit(C4_1-C3_1) 0];
z1 = cross(x1,y1);



C1_2 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,1,2));
C2_2 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,2,2));
C3_2 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,3,2));
C4_2 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,4,2));

Or2 = intersection(C1_2,C3_2,C2_2,C4_2);
Or2 = [Or2 0]/1000;

y2 = [makeunit(C2_2-C3_2) 0];
x2 = [makeunit(C4_2-C3_2) 0];
z2 = cross(x2,y2);


if plates==3
    C1_3 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,1,3));
    C2_3 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,2,3));
    C3_3 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,3,3));
    C4_3 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,4,3));
    
    Or3 = intersection(C1_3,C3_3,C2_3,C4_3);
    Or3 = [Or3 0]/1000;
    
    y3 = [makeunit(C2_3-C3_3) 0];
    x3 = [makeunit(C4_3-C3_3) 0];
    z3 = cross(x3,y3);
    
end

