function Fprox = F_foot(m,ACOM,Fdis,g,LKIN,segment)

%   F_FOOT returns the proximal force at ankle 
%
%   ARGUMENTS
%
%   m      ... mass
%   ACOM   ... acceleraion of center of mass
%   Fdis   ... force distal (at COP)
%   G_S   ...  Struc containing Grood and suntay angles (i,k,l)
%   g     ...  gravity expressed in the local coordinate system 
%
%   RETURNS
%
%   Fankle  ...Force at ankle matrix column 1 in XYZ column 2 in anatomical



i = LKIN.Segment.(segment).Axes.i;
j = LKIN.Segment.(segment).Axes.j;
k = LKIN.Segment.(segment).Axes.k;

m = 0;
%-------Force in global coordinates XYZ-----

Fprox_X = m*(ACOM(:,1)-g(1)) - Fdis(:,1);
Fprox_Y = m*(ACOM(:,2) -g(2))- Fdis(:,2);
Fprox_Z = m*(ACOM(:,3)-g(3)) - Fdis(:,3);

Fprox_XYZ = [Fprox_X Fprox_Y Fprox_Z];

%------FORCE IN ANATOMICAL USING GROOD & SUNTAY-----

Fprox_prox_dis = -1*dot(Fprox_XYZ,i,2);
Fprox_med_lat =  dot(Fprox_XYZ,k,2);
Fprox_ant_pos = dot(Fprox_XYZ,j,2);

Fprox_ANATOMICAL = [Fprox_med_lat  Fprox_ant_pos Fprox_prox_dis];

%--------CREATE MATRIX of XYZ and G&S---------


Fprox =[Fprox_XYZ Fprox_ANATOMICAL];

