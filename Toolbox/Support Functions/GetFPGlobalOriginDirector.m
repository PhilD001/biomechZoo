function [Or,C] = getFPGlobalOriginDirector(zdata)

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

% Updated Sept 2015
% -moved to structured array output for unlimited number of force plates


[~,~,plates] = size(zdata.zoosystem.Analog.FPlates.CORNERS);

Or = struct;
C = struct;

for i =1:plates
    
    C1 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,1,i));
    C2 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,2,i));
    C3 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,3,i));
    C4 = makerow(zdata.zoosystem.Analog.FPlates.CORNERS(1:2,4,i));
    
    or = intersection(C1,C3,C2,C4);
    or = [or 0]/1000;
    
    Or.(['Or',num2str(i)]) = or;
    
    y = [makeunit(C2-C3) 0];
    x = [makeunit(C4-C3) 0];
    z = cross(x,y);
    
    C.(['y',num2str(i)]) = y;
    C.(['x',num2str(i)]) = x;
    C.(['z',num2str(i)]) = z;
    
    
end




