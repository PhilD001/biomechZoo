function Fprox = F_mfoot(m,ACOM,Fdis,g,LKIN,segment,ref)

%   F_MFOOT returns the proximal force at the midfoot joint 
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



if nargin ==7
    ref = 'vicon';
end


if ~isempty(strfind(ref,'vicon'))
    i = LKIN.(segment).Axes.i;
    j = LKIN.(segment).Axes.j;
    k = LKIN.(segment).Axes.k;

else
    i = GS.i;
    j = GS.l;
    k = GS.k;
end

m = 0;
%-------Force in global coordinates XYZ-----

Fprox_X = m*(ACOM(:,1)-g(1)) - Fdis(:,1);
Fprox_Y = m*(ACOM(:,2) -g(2))- Fdis(:,2);
Fprox_Z = m*(ACOM(:,3)-g(3)) - Fdis(:,3);

Fprox_XYZ = [Fprox_X Fprox_Y Fprox_Z];

%------FORCE IN ANATOMICAL USING GROOD & SUNTAY-----

Fprox_ant_pos = -1*dot(Fprox_XYZ,j,2);
Fprox_prox_dis = -1*dot(Fprox_XYZ,i,2);
Fprox_med_lat =  dot(Fprox_XYZ,k,2);

Fprox_ANATOMICAL = [-Fprox_prox_dis Fprox_ant_pos Fprox_med_lat   ];

%--------CREATE MATRIX of XYZ and G&S---------


Fprox =[Fprox_XYZ Fprox_ANATOMICAL];

