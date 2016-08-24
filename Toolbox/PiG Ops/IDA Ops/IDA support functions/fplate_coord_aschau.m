function [COORD,DIS]=fplate_coord_aschau(zfilename,coord)


%   FPLATE_COORD_ASCHAU creates local coordinate system at plate 1 for both
%   conditions. Coordnates are stored in an excel file


COORD = struct;


%------------FIND REFdis: origin of fplate coord system-----

COORD.S1.Flat.REFdis = coord(1,10:12)/1000;          %bottom right fplate
COORD.S2.Flat.REFdis = coord(3,10:12)/1000;
COORD.S3.Flat.REFdis = coord(5,10:12)/1000;
COORD.S4.Flat.REFdis = coord(7,10:12)/1000;
COORD.S5.Flat.REFdis = coord(9,10:12)/1000;
COORD.S6.Flat.REFdis = coord(11,10:12)/1000;
COORD.S7.Flat.REFdis = coord(13,10:12)/1000;
COORD.S8.Flat.REFdis = coord(15,10:12)/1000;
COORD.S9.Flat.REFdis = coord(17,10:12)/1000;
COORD.S10.Flat.REFdis = coord(19,10:12)/1000;

COORD.S1.Cross.REFdis = coord(2,10:12)/1000;
COORD.S2.Cross.REFdis = coord(4,10:12)/1000;
COORD.S3.Cross.REFdis = coord(6,10:12)/1000;
COORD.S4.Cross.REFdis = coord(8,10:12)/1000;
COORD.S5.Cross.REFdis = coord(10,10:12)/1000;
COORD.S6.Cross.REFdis = coord(12,10:12)/1000;
COORD.S7.Cross.REFdis = coord(14,10:12)/1000;
COORD.S8.Cross.REFdis = coord(16,10:12)/1000;
COORD.S9.Cross.REFdis = coord(18,10:12)/1000;
COORD.S10.Cross.REFdis = coord(20,10:12)/1000;


%----------------BOTTOM LEFT----------

COORD.S1.Flat.BL = coord(1,1:3)/1000;
COORD.S2.Flat.BL = coord(3,1:3)/1000;
COORD.S3.Flat.BL = coord(5,1:3)/1000;
COORD.S4.Flat.BL = coord(7,1:3)/1000;
COORD.S5.Flat.BL = coord(9,1:3)/1000;
COORD.S6.Flat.BL = coord(11,1:3)/1000;
COORD.S7.Flat.BL = coord(13,1:3)/1000;
COORD.S8.Flat.BL = coord(15,1:3)/1000;
COORD.S9.Flat.BL = coord(17,1:3)/1000;
COORD.S10.Flat.BL = coord(19,1:3)/1000;

COORD.S1.Cross.BL = coord(2,1:3)/1000;
COORD.S2.Cross.BL = coord(4,1:3)/1000;
COORD.S3.Cross.BL = coord(6,1:3)/1000;
COORD.S4.Cross.BL = coord(8,1:3)/1000;
COORD.S5.Cross.BL = coord(10,1:3)/1000;
COORD.S6.Cross.BL = coord(12,1:3)/1000;
COORD.S7.Cross.BL = coord(14,1:3)/1000;
COORD.S8.Cross.BL = coord(16,1:3)/1000;
COORD.S9.Cross.BL = coord(18,1:3)/1000;
COORD.S10.Cross.BL = coord(20,1:3)/1000;

%----------------TOP RIGHT----------

COORD.S1.Flat.TR = coord(1,7:9)/1000;
COORD.S2.Flat.TR = coord(3,7:9)/1000;
COORD.S3.Flat.TR = coord(5,7:9)/1000;
COORD.S4.Flat.TR = coord(7,7:9)/1000;
COORD.S5.Flat.TR = coord(9,7:9)/1000;
COORD.S6.Flat.TR = coord(11,7:9)/1000;
COORD.S7.Flat.TR = coord(13,7:9)/1000;
COORD.S8.Flat.TR = coord(15,7:9)/1000;
COORD.S9.Flat.TR = coord(17,7:9)/1000;
COORD.S10.Flat.TR = coord(19,7:9)/1000;


COORD.S1.Cross.TR = coord(2,7:9)/1000;
COORD.S2.Cross.TR = coord(4,7:9)/1000;
COORD.S3.Cross.TR = coord(6,7:9)/1000;
COORD.S4.Cross.TR = coord(8,7:9)/1000;
COORD.S5.Cross.TR = coord(10,7:9)/1000;
COORD.S6.Cross.TR = coord(12,7:9)/1000;
COORD.S7.Cross.TR = coord(14,7:9)/1000;
COORD.S8.Cross.TR = coord(16,7:9)/1000;
COORD.S9.Cross.TR = coord(18,7:9)/1000;
COORD.S10.Cross.TR = coord(20,7:9)/1000;

%---------------BOTTOM RIGHT FP2------

COORD.S1.Flat.BR2= coord(1,23:25)/1000;
COORD.S2.Flat.BR2= coord(3,23:25)/1000;
COORD.S3.Flat.BR2= coord(5,23:25)/1000;
COORD.S4.Flat.BR2= coord(7,23:25)/1000;
COORD.S5.Flat.BR2= coord(9,23:25)/1000;
COORD.S6.Flat.BR2= coord(11,23:25)/1000;
COORD.S7.Flat.BR2= coord(13,23:25)/1000;
COORD.S8.Flat.BR2= coord(15,23:25)/1000;
COORD.S9.Flat.BR2= coord(17,23:25)/1000;
COORD.S10.Flat.BR2= coord(19,23:25)/1000;

COORD.S1.Cross.BR2 = coord(2,23:25)/1000;
COORD.S2.Cross.BR2 = coord(4,23:25)/1000;
COORD.S3.Cross.BR2 = coord(6,23:25)/1000;
COORD.S4.Cross.BR2 = coord(8,23:25)/1000;
COORD.S5.Cross.BR2 = coord(10,23:25)/1000;
COORD.S6.Cross.BR2 = coord(12,23:25)/1000;
COORD.S7.Cross.BR2 = coord(14,23:25)/1000;
COORD.S8.Cross.BR2 = coord(16,23:25)/1000;
COORD.S9.Cross.BR2 = coord(18,23:25)/1000;
COORD.S10.Cross.BR2 = coord(20,23:25)/1000;



%-----------DISTANCE BTW THE PLATES-----------
DIS= struct;


DIS.S1.Flat = COORD.S1.Flat.BR2 - COORD.S1.Flat.REFdis;
DIS.S2.Flat = COORD.S2.Flat.BR2 - COORD.S2.Flat.REFdis;
DIS.S3.Flat = COORD.S3.Flat.BR2 - COORD.S3.Flat.REFdis;
DIS.S4.Flat = COORD.S4.Flat.BR2 - COORD.S4.Flat.REFdis;
DIS.S5.Flat = COORD.S5.Flat.BR2 - COORD.S5.Flat.REFdis;
DIS.S6.Flat = COORD.S6.Flat.BR2 - COORD.S6.Flat.REFdis;
DIS.S7.Flat = COORD.S7.Flat.BR2 - COORD.S7.Flat.REFdis;
DIS.S8.Flat = COORD.S8.Flat.BR2 - COORD.S8.Flat.REFdis;
DIS.S9.Flat = COORD.S9.Flat.BR2 - COORD.S9.Flat.REFdis;
DIS.S10.Flat =COORD.S10.Flat.BR2 - COORD.S10.Flat.REFdis;



DIS.S1.Cross = COORD.S1.Cross.BR2 - COORD.S1.Cross.REFdis;
DIS.S2.Cross = COORD.S2.Cross.BR2 - COORD.S2.Cross.REFdis;
DIS.S3.Cross = COORD.S3.Cross.BR2 - COORD.S3.Cross.REFdis;
DIS.S4.Cross = COORD.S4.Cross.BR2 - COORD.S4.Cross.REFdis;
DIS.S5.Cross = COORD.S5.Cross.BR2 - COORD.S5.Cross.REFdis;
DIS.S6.Cross = COORD.S6.Cross.BR2 - COORD.S6.Cross.REFdis;
DIS.S7.Cross = COORD.S7.Cross.BR2 - COORD.S7.Cross.REFdis;
DIS.S8.Cross = COORD.S8.Cross.BR2 - COORD.S8.Cross.REFdis;
DIS.S9.Cross = COORD.S9.Cross.BR2 - COORD.S9.Cross.REFdis;
DIS.S10.Cross =COORD.S10.Cross.BR2 - COORD.S10.Cross.REFdis;

%------Create refence system with origin at fplate1 bottom right--


%--------FLAT--------

x = makeunit(COORD.S1.Flat.TR - COORD.S1.Flat.REFdis) ;     %S1 flat 
y = makeunit(COORD.S1.Flat.BL- COORD.S1.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S1.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S2.Flat.TR - COORD.S2.Flat.REFdis) ;   %S2 flat
y = makeunit(COORD.S2.Flat.BL - COORD.S2.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S2.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S3.Flat.TR - COORD.S3.Flat.REFdis) ;   %S3 flat
y = makeunit(COORD.S3.Flat.BL - COORD.S3.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S3.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S4.Flat.TR - COORD.S4.Flat.REFdis) ;   %S4 flat
y = makeunit(COORD.S4.Flat.BL - COORD.S4.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S4.Flat.REFort = [x ; y; z];


x = makeunit(COORD.S5.Flat.TR - COORD.S5.Flat.REFdis) ;   %S5 flat
y = makeunit(COORD.S5.Flat.BL - COORD.S5.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S5.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S6.Flat.TR - COORD.S6.Flat.REFdis) ;   %S6 flat
y = makeunit(COORD.S6.Flat.BL - COORD.S6.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S6.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S7.Flat.TR - COORD.S7.Flat.REFdis) ;   %S7 flat
y = makeunit(COORD.S7.Flat.BL - COORD.S7.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S7.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S8.Flat.TR - COORD.S8.Flat.REFdis) ;   %S8 flat
y = makeunit(COORD.S8.Flat.BL - COORD.S8.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S8.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S9.Flat.TR - COORD.S9.Flat.REFdis) ;   %S9 flat
y = makeunit(COORD.S9.Flat.BL - COORD.S9.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S9.Flat.REFort = [x ; y; z];

x = makeunit(COORD.S10.Flat.TR - COORD.S10.Flat.REFdis) ;   %S10 flat
y = makeunit(COORD.S10.Flat.BL - COORD.S10.Flat.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S10.Flat.REFort = [x ; y; z];


%--------CROSS--------

x = makeunit(COORD.S1.Cross.TR - COORD.S1.Cross.REFdis) ;     %S1 Cross 
y = makeunit(COORD.S1.Cross.BL - COORD.S1.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S1.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S2.Cross.TR - COORD.S2.Cross.REFdis) ;   %S2 Cross
y = makeunit(COORD.S2.Cross.BL - COORD.S2.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S2.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S3.Cross.TR - COORD.S3.Cross.REFdis) ;   %S3 Cross
y = makeunit(COORD.S3.Cross.BL - COORD.S3.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S3.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S4.Cross.TR - COORD.S4.Cross.REFdis) ;   %S4 Cross
y = makeunit(COORD.S4.Cross.BL - COORD.S4.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S4.Cross.REFort = [x ; y; z];


x = makeunit(COORD.S5.Cross.TR - COORD.S5.Cross.REFdis) ;   %S5 Cross
y = makeunit(COORD.S5.Cross.BL - COORD.S5.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S5.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S6.Cross.TR - COORD.S6.Cross.REFdis) ;   %S6 Cross
y = makeunit(COORD.S6.Cross.BL - COORD.S6.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S6.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S7.Cross.TR - COORD.S7.Cross.REFdis) ;   %S7 Cross
y = makeunit(COORD.S7.Cross.BL - COORD.S7.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S7.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S8.Cross.TR - COORD.S8.Cross.REFdis) ;   %S8 Cross
y = makeunit(COORD.S8.Cross.BL - COORD.S8.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S8.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S9.Cross.TR - COORD.S9.Cross.REFdis) ;   %S9 Cross
y = makeunit(COORD.S9.Cross.BL - COORD.S9.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S9.Cross.REFort = [x ; y; z];

x = makeunit(COORD.S10.Cross.TR - COORD.S10.Cross.REFdis) ;   %S10 Cross
y = makeunit(COORD.S10.Cross.BL - COORD.S10.Cross.REFdis) ;
z = cross(x,y);
y = cross(z,x);
COORD.S10.Cross.REFort = [x ; y; z];


