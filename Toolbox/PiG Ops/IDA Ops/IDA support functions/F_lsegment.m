function F_prox = F_lsegment(m,ACOM,Fdis,G_S,g)

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





i = G_S.i;
k = G_S.k;
l = G_S.l;

%-------Force in global coordinates XYZ-----

F_prox_X = m*(ACOM(:,1)-g(1)) + Fdis(:,1);
F_prox_Y = m*(ACOM(:,2) -g(2))+ Fdis(:,2);
F_prox_Z = m*(ACOM(:,3)-g(3)) + Fdis(:,3);

F_prox_XYZ = [F_prox_X F_prox_Y F_prox_Z];

%------FORCE IN ANATOMICAL USING GROOD & SUNTAY-----

F_prox_prox_dis = dot(F_prox_XYZ,i,2);
F_prox_med_lat =  dot(-1*F_prox_XYZ,k,2);
F_prox_ant_pos = dot(F_prox_XYZ,l,2);

F_prox_ANATOMICAL = [F_prox_med_lat F_prox_ant_pos F_prox_prox_dis];

%--------CREATE MATRIX of XYZ and G&S---------


F_prox =[F_prox_XYZ F_prox_ANATOMICAL];

