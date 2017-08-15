function F_prox = F_segment(m,ACOM,Fdis,g,LKIN,GS,segment,ref)

% F_SEGMENT returns the proximal force at the joint 
%
% ARGUMENTS
%
%  m       ...  mass
%  ACOM    ...  acceleraion of center of mass
%  Fdis    ...  force distal 
%  g       ...  gravity expressed in the local coordinate system 
%  LKIN    ...  Struct containing segment axes for vicon coordinate system
%  G_S     ...  Struct containing Grood and suntay angles (i,k,l)
%  segment ...  name of distal segment
%  ref     ...  reference frame. Default Vicon.
%
% RETURNS
%
% F_prox  ...   Force at aproximal joint matrix column 1:3 in XYZ column 4:6 in anatomical




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





%  m = 0; % compuations compare well with vicon when mass is 0

%-------Force in global coordinates XYZ-----

F_prox_X = m*(ACOM(:,1) + g(1)) + Fdis(:,1);
F_prox_Y = m*(ACOM(:,2) + g(2))+ Fdis(:,2);
F_prox_Z = m*(ACOM(:,3) + g(3)) + Fdis(:,3);

F_prox_XYZ = [F_prox_X F_prox_Y F_prox_Z];

%------FORCE IN ANATOMICAL USING PROX SEGMENT-----

F_prox_prox_dis = dot(F_prox_XYZ,i,2);
F_prox_med_lat  = dot(F_prox_XYZ,k,2);
F_prox_ant_pos  = dot(F_prox_XYZ,j,2);


switch segment

    case {'LeftHindFoot','RightHindFoot'}

        F_prox_ANATOMICAL =  [F_prox_prox_dis -F_prox_ant_pos   F_prox_med_lat  ];

    case {'RightShankPG','LeftShankPG'}
        
        F_prox_ANATOMICAL = [F_prox_ant_pos    F_prox_med_lat   F_prox_prox_dis ];
        
    otherwise

        F_prox_ANATOMICAL = [F_prox_ant_pos    F_prox_med_lat   F_prox_prox_dis ];

end
%--------CREATE MATRIX of XYZ and G&S---------


F_prox =[F_prox_XYZ F_prox_ANATOMICAL];


