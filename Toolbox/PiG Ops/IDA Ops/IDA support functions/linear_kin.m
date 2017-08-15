function LKIN = linear_kin(data)

%   LINEAR_KIN returns kinematic quantities required for inverse dynamics 
%
%   ARGUMENTS
%
%   data    ...  structured array of segment data retured from c3d2zoo

%
%   RETURNS
%
%   LKIN  ... structured array containing segment joint center and segment
%             embedded axes
%
% NOTES
%
% Segment embedded axes convention follows Vaughan, not Vicon



% ---PLUGINGAIT BONES----


%  1) EXTRACT JOINT CENTER DATA------------

LKIN.RightThigh.HipJoint = data.RightFemur.prox_end;     %proximal end of femur is hip joint in meters
LKIN.LeftThigh.HipJoint   = data.LeftFemur.prox_end;
LKIN.RightShank.KneeJoint = data.RightTibia.prox_end;
LKIN.LeftShank.KneeJoint = data.LeftTibia.prox_end;
LKIN.RightFoot.AnkleJoint = data.RightTibia.dist_end;   %ankle joint is distal end of tibia (prox end of foot is heel?)
LKIN.LeftFoot.AnkleJoint = data.LeftTibia.dist_end;

%  2) SEGMENT EMBEDDED AXES---------------
%
% convention here is NOT vicon. This follows Vaugh, gait book p94. All
% calculations should still be consistent...

% ort comes in as 'A', 'L', 'P'
LKIN.Pelvis.Axes.i = makeunit(data.Pelvis.ort(:,:,3)); %proximal 
LKIN.Pelvis.Axes.j = makeunit(data.Pelvis.ort(:,:,1)); % points anterior
LKIN.Pelvis.Axes.k= makeunit(data.Pelvis.ort(:,:,2));  % ponts medio-lateral

LKIN.RightThigh.Axes.i = makeunit(data.RightFemur.ort(:,:,3));
LKIN.RightThigh.Axes.j = makeunit(data.RightFemur.ort(:,:,1));
LKIN.RightThigh.Axes.k = makeunit(data.RightFemur.ort(:,:,2));

LKIN.LeftThigh.Axes.i = makeunit(data.LeftFemur.ort(:,:,3));
LKIN.LeftThigh.Axes.j = makeunit(data.LeftFemur.ort(:,:,1));
LKIN.LeftThigh.Axes.k = makeunit(data.LeftFemur.ort(:,:,2));

LKIN.RightShank.Axes.i  = makeunit(data.RightTibia.ort(:,:,3));
LKIN.RightShank.Axes.j  = makeunit(data.RightTibia.ort(:,:,1));
LKIN.RightShank.Axes.k  = makeunit(data.RightTibia.ort(:,:,2));

LKIN.LeftShank.Axes.i = makeunit(data.LeftTibia.ort(:,:,3)); 
LKIN.LeftShank.Axes.j = makeunit(data.LeftTibia.ort(:,:,1));
LKIN.LeftShank.Axes.k = makeunit(data.LeftTibia.ort(:,:,2));

LKIN.RightFoot.Axes.i = makeunit(data.RightFoot.ort(:,:,3)); % points toward ankle
LKIN.RightFoot.Axes.j = makeunit(data.RightFoot.ort(:,:,1));
LKIN.RightFoot.Axes.k = makeunit(data.RightFoot.ort(:,:,2));

LKIN.LeftFoot.Axes.i = makeunit(data.LeftFoot.ort(:,:,3));
LKIN.LeftFoot.Axes.j = makeunit(data.LeftFoot.ort(:,:,1));
LKIN.LeftFoot.Axes.k = makeunit(data.LeftFoot.ort(:,:,2));


%------OXFORD FOOT MODEL-------

if isfield(data,'RightForeFoot')
    
    %  1) EXTRACT JOINT CENTER DATA------------
    
    LKIN.RightShankOFM.KneeJoint = data.RightTibiaOFM.prox_end;
    LKIN.LeftShankOFM.KneeJoint = data.LeftTibiaOFM.prox_end;
    LKIN.RightHindFoot.AnkleJoint = data.RightTibiaOFM.dist_end;   %ankle joint is distal end of tibia (prox end of foot is heel?)
    LKIN.LeftHindFoot.AnkleJoint = data.LeftTibiaOFM.dist_end;
    LKIN.RightForeFoot.MidFootJoint = data.RightHindFoot.dist_end;   %ankle joint is distal end of tibia (prox end of foot is heel?)
    LKIN.LeftForeFoot.MidFootJoint = data.LeftHindFoot.dist_end;
    
    
    %  2) SEGMENT EMBEDDED AXES---------------
    
    % OFM axes
    % i points distal
    % j point anterior
    % k points medio-lateral
    
    LKIN.RightShankOFM.Axes.i = makeunit(data.RightTibiaOFM.ort(:,:,3));
    LKIN.RightShankOFM.Axes.j = makeunit(data.RightTibiaOFM.ort(:,:,1));
    LKIN.RightShankOFM.Axes.k = makeunit(data.RightTibiaOFM.ort(:,:,2));
    
    LKIN.RightHindFoot.Axes.i = makeunit(-data.RightHindFoot.ort(:,:,1));
    LKIN.RightHindFoot.Axes.j = makeunit(-data.RightHindFoot.ort(:,:,2));
    LKIN.RightHindFoot.Axes.k = makeunit(data.RightHindFoot.ort(:,:,3));
    
    
    LKIN.RightForeFoot.Axes.i = makeunit(-data.RightForeFoot.ort(:,:,1));
    LKIN.RightForeFoot.Axes.j = makeunit(-data.RightForeFoot.ort(:,:,2));
    LKIN.RightForeFoot.Axes.k = makeunit(data.RightForeFoot.ort(:,:,3));
    
    LKIN.LeftShankOFM.Axes.i = makeunit(data.LeftTibiaOFM.ort(:,:,3));
    LKIN.LeftShankOFM.Axes.j = makeunit(data.LeftTibiaOFM.ort(:,:,1));
    LKIN.LeftShankOFM.Axes.k = makeunit(data.LeftTibiaOFM.ort(:,:,2));
    
    LKIN.LeftHindFoot.Axes.i = makeunit(-data.LeftHindFoot.ort(:,:,1));
    LKIN.LeftHindFoot.Axes.j = makeunit(-data.LeftHindFoot.ort(:,:,2));
    LKIN.LeftHindFoot.Axes.k = makeunit(data.LeftHindFoot.ort(:,:,3));
    
    LKIN.LeftForeFoot.Axes.i = makeunit(-data.LeftForeFoot.ort(:,:,1));
    LKIN.LeftForeFoot.Axes.j = makeunit(-data.LeftForeFoot.ort(:,:,2));
    LKIN.LeftForeFoot.Axes.k = makeunit(data.LeftForeFoot.ort(:,:,3));
    
end