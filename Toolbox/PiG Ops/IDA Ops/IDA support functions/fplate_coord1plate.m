function COORD=fplate_coord1plate(data)

%   FLATE_COORD creates local coordinate system at plate 1 for both
%   conditions. Coordnates are stored in an excel file
%
%   Updated 14/12/2007 BR FP2 are correct coordinates now

COORD = struct;

%------------FIND REFdis: origin of fplate coord system-----

COORD.REFdis = average(data.LF4.line)/1000;   % bottom right fplate
COORD.BL = average(data.LF1.line)/1000;         %  bottom left
COORD.TR = average(data.LF3.line)/1000 ;        %  top right

%------Create refence system with origin at fplate1 bottom right--

x = makeunit(COORD.TR - COORD.REFdis) ;     %S1 flat 
y = makeunit(COORD.BL- COORD.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.REFort = [x ; y; z];



