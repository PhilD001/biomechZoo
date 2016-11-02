function data = kinetics_data(data,settings,filt)

% data = KINETICS_DATA(data,settings,filt) will compute inverse dynamics on
% Plugingait (PiG) or Oxford Foot model (OFM) marker sets
%
% ARGUMENTS
%  data      ...  Zoo data containing all vicon 'bone' outputs
%  settings  ...  Settings control (struct) with the following fields:
%                 'segpar'(string). Default, 'segmentParameters' (currently only choice)
%                 'graph' (boolean). Default, false
%                 'city'  (string). Default, 'standard' sets grav const, see g
%                 'filt'  (boolean). Default, false. Don't filter intermediate calculations
%                 'comp'  (boolean). Default, true. Compares agains Vicon output (if available)
%  filt            Filter settings for GRF (struct). Default, see setFilt
%
% RETURN
%  data      ...  Zoo data with joint kinetics and related quantities appended
%
% NOTES
% - This function computes all force and moments based on the method proposed by
%   Vaughan (The Dynamics of Human Gait, 1999).
% - Joint Power are computed according to Kwon (eq 7)
%   http://www.kwon3d.com/theory/jtorque/jen.html
% - Joint Forces are expressed in the distal segment reference frame
%   according to Vicon and not using the Grood and Suntay axes as proposed by Vaughan.
% - Only midfoot (OFM only), ankle, knee, and hip kinetics are computed here. However,
%   pelvis segment embedded axes are included since they are required for hip power calcs
% - For best agreement of Force values with Vicon all segments were given a mass of 0kg
%   (please see force subfunctions)
%
% GENERAL ALGORITHM (see Vaughan for more details)
%  1) Calculate the forces at the proximal joint using Newton's 2nd law (linear form)
%  2) Calculate the moment arms, proximal and distal, between the force application
%     point and the segment centre of gravity.
%  3) Calculate the residual moment acting on the segment.
%  4) Calculate the rate of change of angular momentum for the segment
%  5) Calculate the resultant joint moment, first in the xyz system using
%     Newton's 2nd law (angular form), then in XYZ system.
%  6) Convert the joint force and moment from the XYZ system to a body-based system.
%
%
% See also kinematicsPiG_data, makebones, prepfp_data


% Revision History
%
% Original version created by Philippe C. Dixon and JJ Loh 2007
% - The function that started the BiomechZoo system!
%
% Updated by Philippe C. Dixon 2010
% - calcualtions can be conducted on OFM data, but these must contain OFM
% 'bones' (i.e. processed in Vicon)
%
% Updated by Philippe C. Dixon 2013
% - created many standalone functions
%
% Updated by Philippe C. Dixon January 3rd 2014
% -replaced NaNs in COP to zeros to obtain kinetics over all datapoints,
% see centreofpressure_data
%
% Updated by Philippe C. Dixon May 31st 2014
% - use of bmech_addchannel_data depreciated. Function now calls 'addchannel_data.m'
%
% Updated by Philippe C. Dixon August 2016
% - Improved functionality with BiomechZoo version 1.3
% - No backwards compatibility
%
% Updated by Philippe C. Dixon October 2016
% - improved graphical outputs



%---------------------------------------%
%                                       %
%             INITIAL SETTINGS          %
%                                       %
%                                       %
%---------------------------------------%


%--------------------------- PART 0 : DEFAULT SETTINGS -----------------------------------
%
% - Get path for function
% - Set default filter settings
% - Set other default settings

functionpath  = [fileparts(mfilename('fullpath')),filesep];     % get root directory

if nargin==0                                                    % test mode
    [data,settings,filt] = testmode;
end

if nargin==1
    filt = setFilt;
    settings.segpar = 'segments.xls';                           % see getSegmentPar
    settings.graph  = false;                                    % graph results
    settings.city   = 'standard';                               % choose g based on city
    settings.filt   = false;                                    % Filter intermediate calc
    settings.comp   = true;                                     % compare with Vicon
end

if nargin==2
    filt = setFilt;
end

if settings.graph == true
    gsettings.LineWidth = 1.5;                                  % graph line width
    gsettings.FontSize = 16;                                    % heading font size
    gsettings.FontName = 'Arial';                               % heading font name
    gsettings.vcol = 'k';                                       % color for vicon PiG
    gsettings.zcol = 'b';                                       % color for zoo PiG
    gsettings.ocol = 'r';                                       % color for zoo OFM
    gsettings.vstyle = '-';                                     % style for vicon PiG
    gsettings.zstyle = '--';                                    % style for zoo PiG
    gsettings.ostyle = '-.';                                    % style for zoo OFM
else
    gsettings = struct;
end

%---------------------------------------%
%                                       %
%             PREPARING                 %
%              THE DATA                 %
%                                       %
%---------------------------------------%


%---------------------- PART I : COLLECT AND SET BASIC INFO ------------------------------
%
% - Force plate coordinates of origin (GLOBAL) and true origin (LOCAL) in meter
% - Sampling rate (Hz)
% - Anthropometric quantites (mass,CoM,Radius Gyration)
% - Set value of g (gravitation constant)

body = struct;                                                  % build new struct
body.bodymass = getanthro(data,'Bodymass');                     % extract mass info
body.fsamp = data.zoosystem.Video.Freq;

localOr = getFPLocalOrigin(data);                               % true local FP origin
[globalOr,orientFP] = getFPGlobalOrigin(data);                  % FP global origin/orient
segmentPar = getSegmentPar([functionpath,settings.segpar]);

if ~isfield(data,'RightGroundReactionForce')  && ~isfield(data,'LeftGroundReactionForce')
    data = processGRF_data(data,filt,localOr,globalOr,orientFP);        % process GRF for IDA
end

grav = g(settings.city);                                        % extract value of gravity
grav = [0 0 grav];


%----------------------- PART II : REARANGE DATA AND COLLET INFO -------------------------
%
% - Collect bones
% - Assign COM of segments
% - Assign force plate '1' and '2' to 'right' and 'left' legs
% - Force values stored in 'data' (FXL,FYL,...FRZ) converted to Newtons
% - Moment values stored in 'data' (MXL,MYL,...MRZ)converted to Newtons*metres
% - COP values are divided by 1000 to be in meters

[pgbone,~,data,oxbone] = getbones(data);
pgbone = pgbone(2:end,:);

% set segment par for PIG (inc com)
% O is origin of bone, at distal joint
% A is an anterior vector from bone
% L is a lateral vector
% P is the proximal joint

pgdim = {'O','A','L','P'};
[data,body] = setSegmentPar(pgdim,pgbone,data,segmentPar,body);

% set segment par for OFM  (inc com)
% 0 is origin of bone (zero)
% 1 is anterior vector
% 2 is medial (right) or lateral(left) vector
% 3 is vector along long axis of bone

if ~isempty(oxbone)
    oxdim = {'0','1','2','3'};
    [data,body] = setSegmentPar(oxdim,oxbone,data,segmentPar,body);
end



%---------------------------------------%
%                                       %
%             MAIN IDA                  %
%            CALCULATIONS               %
%                                       %
%---------------------------------------%


%----------------- PART III : ANTHROPOMETRICS --------------------------------------------
%
% - Segment mass (kg)
% - Segment length (m)
% - Segment moment of inertia (kg*m^2 )

ANTHRO = anthro(body,segmentPar);


%----------------- PART IV: LINEAR KINEMATIC zdata ---------------------------------------
%
% - Joint centers (m)
% - Segment embedded axes xyz (expressed in XYZ)

LKIN = linear_kin(body);


%----------------- PART V: CENTER OF MASS ------------------------------------------------
%
% - Position of com   (m)
% - Acceleration of com (m/s^2)

COM = comass(body,settings.filt);


%--------------- PART VI : ANGULAR KINEMATICS --------------------------------------------
%
% - Segment angular velocity LOCAL (rad/s)
% - Segment angular acceleration LOCAL (rad/s^2)
% - Euler reference axes LOCAL
% - G&S reference axes LOCAL

AKIN = angular_kin(LKIN,body.fsamp,settings.filt);


%--------------- PART VII: FREE TORQUE QUANTITIES ----------------------------------------
%
% - Export Right/Left Force plate values
% - Export COP coordinates in GLOBAL
% - Compute Free torque for Right/Left force plates

[FR,FL,COPRg,COPLg,TzR,TzL] = free_torque(data,globalOr);



%---------------- PART VIII : DYNAMICS OF JOINTS -----------------------------------------
%
% - Compute Force (N) in both global and anatomical coordinates
% - Compute Moments (N*m) in both global and anatomical coordinates
% - Compute Power (W)
% - Export all quantities to existing zoo file

data = dynamics(data,body,ANTHRO,LKIN,COM,AKIN,FR,FL,COPRg,COPLg,TzR,TzL,grav);


% ------------ PART IX: COMPARE WITH VICON OUTPUT (OPTIONAL) AND DISPLAY (OPTIONAL)----
%
if settings.comp == true
    data = checkvicon(data);
end


%----------------PART X: GRAPH RESULTS AGAINST VICON (OPTIONAL) -------------------------
%
if settings.graph == true
    graphresults(data,gsettings)
end






%=========================================================================================


%---------------------------------------%
%                                       %
%             EMBEDDED                  %
%             FUNCTIONS                 %
%                                       %
%---------------------------------------%


function [zdata,settings,filt] = testmode

[f,p]=uigetfile({'*.c3d;*.zoo'});
fpath = [p,f];
cd(p)
ext = extension(fpath);

if isin(ext,'c3d');
    zdata= c3d2zoo(fpath);
elseif isin(ext,'zoo')
    zdata = zload(fpath);
else
    error('only c3d and zoo files can be input')
end

settings.segpar = 'segments.xls';                       % see getSegmentPar
settings.graph  = true;                                    % graph results
settings.city   = 'standard';                               % choose g based on city
settings.filt   = false;                                    % Filter intermediate calc
settings.comp   = true;
settings.static = 'Static';

filt = setFilt;


function [FR,FL,COPR,COPL,TzR,TzL] = free_torque(data,globalOr)

FP = data.zoosystem.Analog.FPlates.LIMBSIDES;

fUnit = data.zoosystem.Units.Forces;               % expected N/kg
cUnit = data.zoosystem.Units.CentreOfPressure;     % expected mm
mUnit = data.zoosystem.Units.Moment;               % expected Nmm

if strcmp(fUnit,'N/kg')
    mass = getanthro(data,'mass');
elseif strcmp(fUnit,'N')
    mass = 1;
else
    error('unknown Force unit')
end

if strcmp(cUnit,'mm')
    convmeter = 1000;
elseif strcmp(cUnit,'m')
    convmeter = 1;
else
    error('unknown COP unit')
end

if strcmp(mUnit,'Nmm')
    mconvmeter = 1000;
elseif strcmp(cUnit,'Mm')
    mconvmeter = 1;
else
    error('unknown Moment unit')
end

indxR = FP.Right;
if ~isin(indxR,'invalid')
    FR = data.RightGroundReactionForce.line*mass;  % N
    MR = data.RightGroundReactionMoment.line.*mass./mconvmeter;  % Nm
    COPR = data.RightCentreOfPressure.line./convmeter; % m
    TzR= free_torque_global(FR,MR,COPR,globalOr.(FP.Right));
else
    FR = NaN*data.Pelviscom.line;
    COPR = NaN*data.Pelviscom.line;
    TzR = NaN*data.Pelviscom.line(:,1);
end

indxR = FP.Left;
if ~isin(indxR,'invalid')
    FL = data.LeftGroundReactionForce.line*mass;   % N
    ML = data.LeftGroundReactionMoment.line.*mass./mconvmeter; % Nm
    COPL = data.LeftCentreOfPressure.line./convmeter; % m
    TzL= free_torque_global(FL,ML,COPL,globalOr.(FP.Left));
else
    FL = NaN*data.Pelviscom.line;
    COPL = NaN*data.Pelviscom.line;
    TzL  = NaN*data.Pelviscom.line(:,1);
end


function data = dynamics(data,body,ANTHRO,LKIN,COM,AKIN,FR,FL,COPRg,COPLg,TzR,TzL,g)

%  1) FORCE AND MOMENT CALCULATIONS


% a) ANKLE PIG
F_rankle = F_foot(ANTHRO.RightFoot.Mass, COM.RightFoot.Acc, FR, g,LKIN,AKIN.RightFoot.GSAxes,'RightFoot');  %matrix 1-3 column XYZ 4-6 column segment based
F_lankle = F_foot(ANTHRO.LeftFoot.Mass,  COM.LeftFoot.Acc,  FL,g, LKIN,AKIN.LeftFoot.GSAxes, 'LeftFoot');

M_rankle = M_foot(FR,F_rankle(:,1:3),TzR,LKIN.RightFoot.AnkleJoint,COPRg,COM,ANTHRO.RightFoot.Inertia,AKIN,LKIN,'RightFoot');
M_lankle = M_foot(FL,F_lankle(:,1:3),TzL,LKIN.LeftFoot.AnkleJoint, COPLg,COM, ANTHRO.LeftFoot.Inertia, AKIN,LKIN,'LeftFoot');


% b) KNEE PIG

F_rknee = F_segment(ANTHRO.RightShank.Mass,COM.RightShank.Acc,F_rankle(:,1:3),  g,LKIN,AKIN.RightShank.GSAxes,'RightShank');
F_lknee = F_segment(ANTHRO.LeftShank.Mass, COM.LeftShank.Acc, F_lankle(:,1:3),  g,LKIN,AKIN.LeftShank.GSAxes,'LeftShank');

M_rknee = M_segment(F_rankle(:,1:3), F_rknee(:,1:3),M_rankle(:,1:3),LKIN.RightFoot.AnkleJoint,LKIN.RightShank.KneeJoint, COM, ANTHRO.RightShank.Inertia,AKIN,LKIN,'RightShank');
M_lknee = M_segment(F_lankle(:,1:3), F_lknee(:,1:3),M_lankle(:,1:3),LKIN.LeftFoot.AnkleJoint, LKIN.LeftShank.KneeJoint,  COM, ANTHRO.LeftShank.Inertia, AKIN,LKIN,'LeftShank');

% c) HIP
F_rhip = F_segment(ANTHRO.RightThigh.Mass, COM.RightThigh.Acc,F_rknee(:,1:3),  g, LKIN,AKIN.RightThigh.GSAxes, 'RightThigh');
F_lhip= F_segment(ANTHRO.LeftThigh.Mass,   COM.LeftThigh.Acc, F_lknee(:,1:3),  g, LKIN,AKIN.LeftThigh.GSAxes, 'LeftThigh');

M_rhip = M_segment(F_rknee(:,1:3),   F_rhip(:,1:3), M_rknee(:,1:3), LKIN.RightShank.KneeJoint,LKIN.RightThigh.HipJoint, COM,  ANTHRO.RightThigh.Inertia,AKIN,LKIN,'RightThigh');
M_lhip = M_segment(F_lknee(:,1:3),   F_lhip(:,1:3), M_lknee(:,1:3), LKIN.LeftShank.KneeJoint, LKIN.LeftThigh.HipJoint,  COM,  ANTHRO.LeftThigh.Inertia, AKIN,LKIN,'LeftThigh' );


% 2) ---------------POWER CALCULATIONS --------------

[P_rankle,RightFootAngVelMag]= P_segment(M_rankle(:,1:3),AKIN.RightFoot.AngVel,AKIN.RightShank.AngVel,LKIN.RightFoot.Axes, LKIN.RightShank.Axes);
[P_lankle,LeftFootAngVelMag] = P_segment(M_lankle(:,1:3),AKIN.LeftFoot.AngVel,AKIN.LeftShank.AngVel, LKIN.LeftFoot.Axes,  LKIN.LeftShank.Axes);

[P_rknee,RightShankAngVelMag] = P_segment(M_rknee(:,1:3),AKIN.RightShank.AngVel,AKIN.RightThigh.AngVel,LKIN.RightShank.Axes, LKIN.RightThigh.Axes);
[P_lknee,LeftShankAngVelMag]= P_segment(M_lknee(:,1:3),AKIN.LeftShank.AngVel,AKIN.LeftThigh.AngVel,  LKIN.LeftShank.Axes,  LKIN.LeftThigh.Axes);

[P_rhip,RightThighAngVelMag, RightPelvisAngVelMag] = P_segment(M_rhip(:,1:3), AKIN.RightThigh.AngVel,AKIN.Pelvis.AngVel, LKIN.RightThigh.Axes, LKIN.Pelvis.Axes);
[P_lhip,LeftThighAngVelMag, LeftPelvisAngVelMag] = P_segment(M_lhip(:,1:3), AKIN.LeftThigh.AngVel, AKIN.Pelvis.AngVel, LKIN.LeftThigh.Axes,   LKIN.Pelvis.Axes);



if isfield(body,'RightForeFoot')
    
    %  ---OXFORD FOOT MODEL FORCE AND MOMENTS---
    
    % a) Midfoot joint
    
    F_rmfoot = F_foot(ANTHRO.RightForeFoot.Mass, COM.RightForeFoot.Acc, FR,  g,LKIN, AKIN.RightForeFoot.GSAxes,  'RightForeFoot');  %matrix 1-3 column XYZ 4-6 column segment based
    F_lmfoot = F_foot(ANTHRO.LeftForeFoot.Mass,  COM.LeftForeFoot.Acc,  FL,  g, LKIN, AKIN.LeftForeFoot.GSAxes,'LeftForeFoot');
    
    M_rmfoot = M_foot(FR,F_rmfoot(:,1:3),TzR,LKIN.RightForeFoot.MidFootJoint,COPRg, COM, ANTHRO.RightForeFoot.Inertia, AKIN,LKIN,'RightForeFoot');
    M_lmfoot = M_foot(FL,F_lmfoot(:,1:3),TzL,LKIN.LeftForeFoot.MidFootJoint, COPLg, COM,  ANTHRO.LeftForeFoot.Inertia,  AKIN,LKIN, 'LeftForeFoot' );
    
    % b) ANKLE OFM
    
    F_rankleOFM = F_segment(ANTHRO.RightHindFoot.Mass,COM.RightHindFoot.Acc, F_rmfoot(:,1:3),  g,LKIN,AKIN.RightHindFoot.GSAxes,'RightHindFoot');
    F_lankleOFM = F_segment(ANTHRO.LeftHindFoot.Mass, COM.LeftHindFoot.Acc,  F_lmfoot(:,1:3),  g,LKIN,AKIN.LeftHindFoot.GSAxes,'LeftHindFoot');
    
    M_rankleOFM = M_segment(F_rmfoot(:,1:3), F_rankleOFM(:,1:3),M_rmfoot(:,1:3),LKIN.RightForeFoot.MidFootJoint,LKIN.RightHindFoot.AnkleJoint, COM, ANTHRO.RightHindFoot.Inertia,AKIN,LKIN,'RightHindFoot' );
    M_lankleOFM = M_segment(F_lmfoot(:,1:3), F_lankleOFM(:,1:3),M_lmfoot(:,1:3),LKIN.LeftForeFoot.MidFootJoint, LKIN.LeftHindFoot.AnkleJoint,  COM, ANTHRO.LeftHindFoot.Inertia, AKIN,LKIN,'LeftHindFoot');
    
    % c) KNEE OFM
    
    F_rkneeOFM = F_segment(ANTHRO.RightShankOFM.Mass, COM.RightShankOFM.Acc,F_rankleOFM(:,1:3),  g, LKIN, AKIN.RightShankOFM.GSAxes, 'RightShankOFM');
    F_lkneeOFM= F_segment(ANTHRO.LeftShankOFM.Mass,   COM.LeftShankOFM.Acc, F_lankleOFM(:,1:3),  g, LKIN, AKIN.LeftShankOFM.GSAxes,'LeftShankOFM');
    
    M_rkneeOFM = M_segment(F_rankleOFM(:,1:3), F_rkneeOFM(:,1:3), M_rankleOFM(:,1:3), LKIN.RightHindFoot.AnkleJoint,LKIN.RightShankOFM.KneeJoint, COM,  ANTHRO.RightShankOFM.Inertia, AKIN,LKIN,'RightShankOFM');
    M_lkneeOFM = M_segment(F_lankleOFM(:,1:3), F_lkneeOFM(:,1:3),M_lankleOFM(:,1:3),LKIN.LeftHindFoot.AnkleJoint, LKIN.LeftShankOFM.KneeJoint,  COM,  ANTHRO.LeftShankOFM.Inertia, AKIN,LKIN,'LeftShankOFM');
    
    % d) HIP OFM
    
    F_rhipOFM = F_segment(ANTHRO.RightThigh.Mass, COM.RightThigh.Acc,F_rkneeOFM(:,1:3),  g, LKIN,AKIN.RightThigh.GSAxes, 'RightThigh');
    F_lhipOFM= F_segment(ANTHRO.LeftThigh.Mass,   COM.LeftThigh.Acc, F_lkneeOFM(:,1:3),  g, LKIN,AKIN.LeftHindFoot.GSAxes, 'LeftThigh');
    
    M_rhipOFM = M_segment(F_rkneeOFM(:,1:3),   F_rhipOFM(:,1:3), M_rkneeOFM(:,1:3), LKIN.RightShankOFM.KneeJoint,LKIN.RightThigh.HipJoint, COM, ANTHRO.RightThigh.Inertia,AKIN,LKIN,'RightThigh');
    M_lhipOFM = M_segment(F_lkneeOFM(:,1:3),   F_lhipOFM(:,1:3), M_lkneeOFM(:,1:3), LKIN.LeftShankOFM.KneeJoint, LKIN.LeftThigh.HipJoint,  COM, ANTHRO.LeftThigh.Inertia, AKIN,LKIN, 'LeftThigh' );
    
    
    %----OFM POWER----
    
    [P_rmfoot,RightForeFootAngVelMag]= P_segment(M_rmfoot(:,1:3),AKIN.RightForeFoot.AngVel,AKIN.RightHindFoot.AngVel,LKIN.RightForeFoot.Axes,LKIN.RightHindFoot.Axes,'RightForeFoot');
    [P_lmfoot,LeftForeFootAngVelMag]= P_segment(M_lmfoot(:,1:3),AKIN.LeftForeFoot.AngVel,AKIN.LeftHindFoot.AngVel,LKIN.LeftForeFoot.Axes,LKIN.LeftHindFoot.Axes,'LeftForeFoot');
    
    [P_rankleOFM,RightHindFootAngVelMag]= P_segment(M_rankleOFM(:,1:3),AKIN.RightHindFoot.AngVel,AKIN.RightShankOFM.AngVel,LKIN.RightHindFoot.Axes,LKIN.RightShankOFM.Axes);
    [P_lankleOFM, LeftHindFootAngVelMag]= P_segment(M_lankleOFM(:,1:3),AKIN.LeftHindFoot.AngVel, AKIN.LeftShankOFM.AngVel, LKIN.LeftHindFoot.Axes, LKIN.LeftShankOFM.Axes);
    
    [P_rkneeOFM,RightShankOFMAngVelMag] = P_segment(M_rkneeOFM(:,1:3),AKIN.RightShankOFM.AngVel,AKIN.RightThigh.AngVel,LKIN.RightShankOFM.Axes,LKIN.RightThigh.Axes);
    [P_lkneeOFM,LeftShankOFMAngVelMag] = P_segment(M_lkneeOFM(:,1:3),AKIN.LeftShankOFM.AngVel,AKIN.LeftThigh.AngVel,LKIN.LeftShankOFM.Axes,LKIN.LeftThigh.Axes);
    
    [P_rhipOFM,RightThighOFMAngVelMag, RightPelvisOFMAngVelMag] = P_segment(M_rhipOFM(:,1:3),AKIN.RightThigh.AngVel,AKIN.Pelvis.AngVel,LKIN.RightThigh.Axes,LKIN.Pelvis.Axes);
    [P_lhipOFM,LeftThighOFMAngVelMag, LeftPelvisOFMAngVelMag] = P_segment(M_lhipOFM(:,1:3), AKIN.LeftThigh.AngVel, AKIN.Pelvis.AngVel,LKIN.LeftThigh.Axes, LKIN.Pelvis.Axes);
end


%---- EXPORT TO ZDATA AND CONVERT UNITS------
%
%           Original   conv      converted to Vicon
%  Force:      N        /kg           N/kg
%  Moments:    N*m      x1000 /kg     N*mm/kg
%  Power:      W        /kg           W/kg
%

% CONVERSION PARAMS---------------------------
conv = 1000;
mass= body.bodymass;

% PLUGINGAIT CHANNELS-------


% ) Ground Reaction forces
if isfield(data,'RightGroundReactionForce')
    data = explode_data(data,'RightGroundReactionForce');
end

if isfield(data,'LeftGroundReactionForce')
    data = explode_data(data,'LeftGroundReactionForce');
end

% a) Joint Forces
dims = {'_x','_y','_z'};

for i = 1:length(dims)
    data = addchannel_data(data,['RightAnkleForce',dims{i}],F_rankle(:,i+3)/mass,'Video');
    data = addchannel_data(data,['RightKneeForce',dims{i}],F_rknee(:,i+3)/mass,'Video');
    data = addchannel_data(data,['RightHipForce',dims{i}],F_rhip(:,i+3)/mass,'Video');
    
    data = addchannel_data(data,['LeftAnkleForce',dims{i}],F_lankle(:,i+3)/mass,'Video');
    data = addchannel_data(data,['LeftKneeForce',dims{i}],F_lknee(:,i+3)/mass,'Video');
    data = addchannel_data(data,['LeftHipForce',dims{i}],F_lhip(:,i+3)/mass,'Video');
    
    % b) Moments
    
    data = addchannel_data(data,['RightAnkleMoment',dims{i}],M_rankle(:,i+3)/mass*conv,'Video');
    data = addchannel_data(data,['RightKneeMoment',dims{i}],M_rknee(:,i+3)/mass*conv,'Video');
    data = addchannel_data(data,['RightHipMoment',dims{i}],M_rhip(:,i+3)/mass*conv,'Video');
    
    data = addchannel_data(data,['LeftAnkleMoment',dims{i}],M_lankle(:,i+3)/mass*conv,'Video');
    data = addchannel_data(data,['LeftKneeMoment',dims{i}],M_lknee(:,i+3)/mass*conv,'Video');
    data = addchannel_data(data,['LeftHipMoment',dims{i}],M_lhip(:,i+3)/mass*conv,'Video');
end

% c) POWER

data = addchannel_data(data,'RightAnklePower',P_rankle/mass,'Video');
data = addchannel_data(data,'RightKneePower',P_rknee/mass,'Video');
data = addchannel_data(data,'RightHipPower',P_rhip/mass,'Video');

data = addchannel_data(data,'LeftAnklePower',P_lankle/mass,'Video');
data = addchannel_data(data,'LeftKneePower',P_lknee/mass,'Video');
data = addchannel_data(data,'LeftHipPower',P_lhip/mass,'Video');



% d) Other quantities

data = addchannel_data(data,'RightFootAngVelMag',RightFootAngVelMag,'Video');
data = addchannel_data(data,'LeftFootAngVelMag',LeftFootAngVelMag,'Video');

data = addchannel_data(data,'RightShankAngVelMag',RightShankAngVelMag,'Video');
data = addchannel_data(data,'LeftShankAngVelMag',LeftShankAngVelMag,'Video');

data = addchannel_data(data,'RightThighAngVelMag',RightThighAngVelMag,'Video');
data = addchannel_data(data,'LeftThighAngVelMag',LeftThighAngVelMag,'Video');

data = addchannel_data(data,'RightPelvisAngVelMag',RightPelvisAngVelMag,'Video');
data = addchannel_data(data,'LeftPelvisAngVelMag',LeftPelvisAngVelMag,'Video');


% e) Free Torque (Nm/kg)
data = addchannel_data(data,'RightTz',TzR/mass,'Video');
data = addchannel_data(data,'LeftTz',TzL/mass,'Video');


if isfield(body,'RightForeFoot')
    
    % OFM CHANNELS-------
    
    % a) Midfoot
    
    data = addchannel_data(data,'RightMidFootForce',F_rmfoot(:,4:6)/mass,'Video');
    data = addchannel_data(data,'RightMidFootMoment',M_rmfoot(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'RightMidFootPower',P_rmfoot/mass,'Video');
    
    data = addchannel_data(data,'LeftMidFootForce',F_lmfoot(:,4:6)/mass,'Video');
    data = addchannel_data(data,'LeftMidFootMoment',M_lmfoot(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'LeftMidFootPower',P_lmfoot/mass,'Video');
    
    % b) Ankle (HF/TB)
    data = addchannel_data(data,'RightAnkleForceOFM',F_rankleOFM(:,4:6)/mass,'Video');
    data = addchannel_data(data,'RightAnkleMomentOFM',M_rankleOFM(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'RightAnklePowerOFM',P_rankleOFM/mass,'Video');
    
    data = addchannel_data(data,'LeftAnkleForceOFM',F_lankleOFM(:,4:6)/mass,'Video');
    data = addchannel_data(data,'LeftAnkleMomentOFM',M_lankleOFM(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'LeftAnklePowerOFM',P_lankleOFM/mass,'Video');
    
    
    % c) Knee
    data = addchannel_data(data,'RightKneeForceOFM',F_rkneeOFM(:,4:6)/mass,'Video');
    data = addchannel_data(data,'RightKneeMomentOFM',M_rkneeOFM(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'RightKneePowerOFM',P_rkneeOFM/mass,'Video');
    
    data = addchannel_data(data,'LeftKneeForceOFM',F_lkneeOFM(:,4:6)/mass,'Video');
    data = addchannel_data(data,'LeftKneeMomentOFM',M_lkneeOFM(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'LeftKneePowerOFM',P_lkneeOFM/mass,'Video');
    
    % Hip
    data = addchannel_data(data,'RightHipForceOFM',F_rhipOFM(:,4:6)/mass,'Video');
    data = addchannel_data(data,'RightHipMomentOFM',M_rhipOFM(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'RightHipPowerOFM',P_rhipOFM/mass,'Video');
    
    data = addchannel_data(data,'LeftHipForceOFM',F_lhipOFM(:,4:6)/mass,'Video');
    data = addchannel_data(data,'LeftHipMomentOFM',M_lhipOFM(:,4:6)/mass*conv,'Video');
    data = addchannel_data(data,'LeftHipPowerOFM',P_lhipOFM/mass,'Video');
    
    % d) other useful outputs
    
    data = addchannel_data(data,'RightForeFootAngVelMag',RightForeFootAngVelMag,'Video');
    data = addchannel_data(data,'LeftForeFootAngVelMag',LeftForeFootAngVelMag,'Video');
    
    data = addchannel_data(data,'RightHindFootAngVelMag',RightHindFootAngVelMag,'Video');
    data = addchannel_data(data,'LeftHindFootAngVelMag',LeftHindFootAngVelMag,'Video');
    
    data = addchannel_data(data,'RightShankOFMAngVelMag',RightShankOFMAngVelMag,'Video');
    data = addchannel_data(data,'LeftShankOFMAngVelMag',LeftShankOFMAngVelMag,'Video');
    
    data = addchannel_data(data,'RightThighOFMAngVelMag',RightThighOFMAngVelMag,'Video');
    data = addchannel_data(data,'LeftThighOFMAngVelMag',LeftThighOFMAngVelMag,'Video');
    
    data = addchannel_data(data,'RightPelvisOFMAngVelMag',RightPelvisOFMAngVelMag,'Video');
    data = addchannel_data(data,'LeftPelvisOFMAngVelMag',LeftPelvisOFMAngVelMag,'Video');
end


function data = checkvicon(data)

RGRF = zeros(3,1);
LGRF = zeros(3,1);

RAF = zeros(3,1);
RKF = zeros(3,1);
RHF = zeros(3,1);

RAM = zeros(3,1);
RKM = zeros(3,1);
RHM = zeros(3,1);

RAP = zeros(1,1);
RKP = zeros(1,1);
RHP = zeros(1,1);

LAF = zeros(3,1);
LKF = zeros(3,1);
LHF = zeros(3,1);

LAM = zeros(3,1);
LKM = zeros(3,1);
LHM = zeros(3,1);

LAP = zeros(1,1);
LKP = zeros(1,1);
LHP = zeros(1,1);


subch = {'_x','_y','_z'}; % Ankle angle

% Right side
%
if ~isin(data.zoosystem.Analog.FPlates.LIMBSIDES.Right,'invalid')
    for k = 1:3
        RGRF(k) = nrmse(data.(['RightGroundReactionForce',subch{k}]).line, data.RGroundReactionForce.line(:,k));
        
        RAF(k) = nrmse(data.(['RightAnkleForce',subch{k}]).line, data.RAnkleForce.line(:,k));
        RKF(k) = nrmse(data.(['RightKneeForce',subch{k}]).line, data.RKneeForce.line(:,k));
        RHF(k) = nrmse(data.(['RightHipForce',subch{k}]).line, data.RHipForce.line(:,k));
        
        RAM(k) = nrmse(data.(['RightAnkleMoment',subch{k}]).line, data.RAnkleMoment.line(:,k));
        RKM(k) = nrmse(data.(['RightKneeMoment',subch{k}]).line, data.RKneeMoment.line(:,k));
        RHM(k) = nrmse(data.(['RightHipMoment',subch{k}]).line, data.RHipMoment.line(:,k));
    end
    
    RAP(1) = nrmse(data.RightAnklePower.line, data.RAnklePower.line(:,3));
    RKP(1) = nrmse(data.RightKneePower.line, data.RKneePower.line(:,3));
    RHP(1) = nrmse(data.RightHipPower.line, data.RHipPower.line(:,3));
    
    
    for k = 1:3
        data.(['RightGroundReactionForce',subch{k}]).event.NRMSE = [1 RGRF(k) 0];
        
        data.(['RightAnkleForce',subch{k}]).event.NRMSE = [1 RAF(k) 0];
        data.(['RightKneeForce',subch{k}]).event.NRMSE = [1 RKF(k) 0];
        data.(['RightHipForce',subch{k}]).event.NRMSE = [1 RHF(k) 0];
        
        data.(['RightAnkleMoment',subch{k}]).event.NRMSE = [1 RAM(k) 0];
        data.(['RightKneeMoment',subch{k}]).event.NRMSE = [1 RKM(k) 0];
        data.(['RightHipMoment',subch{k}]).event.NRMSE = [1 RHM(k) 0];
    end
    
    data.RightAnklePower.event.NRMSE = [1 RAP 0];
    data.RightKneePower.event.NRMSE = [1 RKP 0];
    data.RightHipPower.event.NRMSE = [1 RHP 0];
    
    
end

% Left side
%
if ~isin(data.zoosystem.Analog.FPlates.LIMBSIDES.Left,'invalid')
    
    for k = 1:3
        LGRF(k) = nrmse(data.(['LeftGroundReactionForce',subch{k}]).line, data.LGroundReactionForce.line(:,k));
        
        LAF(k) = nrmse(data.(['LeftAnkleForce',subch{k}]).line, data.LAnkleForce.line(:,k));
        LKF(k) = nrmse(data.(['LeftKneeForce',subch{k}]).line, data.LKneeForce.line(:,k));
        LHF(k) = nrmse(data.(['LeftHipForce',subch{k}]).line, data.LHipForce.line(:,k));
        
        LAM(k) = nrmse(data.(['LeftAnkleMoment',subch{k}]).line, data.LAnkleMoment.line(:,k));
        LKM(k) = nrmse(data.(['LeftKneeMoment',subch{k}]).line, data.LKneeMoment.line(:,k));
        LHM(k) = nrmse(data.(['LeftHipMoment',subch{k}]).line, data.LHipMoment.line(:,k));
    end
    
    LAP(1) = nrmse(data.LeftAnklePower.line, data.LAnklePower.line(:,3));
    LKP(1) = nrmse(data.LeftKneePower.line, data.LKneePower.line(:,3));
    LHP(1) = nrmse(data.LeftHipPower.line, data.LHipPower.line(:,3));
    
    
    for k = 1:3
        data.(['LeftGroundReactionForce',subch{k}]).event.NRMSE = [1 LGRF(k) 0];
        
        data.(['LeftAnkleForce',subch{k}]).event.NRMSE = [1 LAF(k) 0];
        data.(['LeftKneeForce',subch{k}]).event.NRMSE = [1 LKF(k) 0];
        data.(['LeftHipForce',subch{k}]).event.NRMSE = [1 LHF(k) 0];
        
        data.(['LeftAnkleMoment',subch{k}]).event.NRMSE = [1 LAM(k) 0];
        data.(['LeftKneeMoment',subch{k}]).event.NRMSE = [1 LKM(k) 0];
        data.(['LeftHipMoment',subch{k}]).event.NRMSE = [1 LHM(k) 0];
    end
    
    data.LeftAnklePower.event.NRMSE = [1 LAP 0];
    data.LeftKneePower.event.NRMSE = [1 LKP 0];
    data.LeftHipPower.event.NRMSE = [1 LHP 0];
    
end


function graphresults(data,gsettings)

% FP = data.zoosystem.Analog.FPlates.LIMBSIDES;
% 
% if ~isin(FP.Right,'invalid') && ~isin(FP.Left,'invalid')
%     side = {'Right','Left'};
% elseif ~isin(FP.Right,'invalid') && isin(FP.Left,'invalid')
%     side = {'Right'};
% elseif isin(FP.Right,'invalid') && ~isin(FP.Left,'invalid')
%     side = {'Left'};
% end
% 
% vcol = gsettings.vcol;                              % color for vicon PiG
% zcol = gsettings.zcol;                              % color for zoo version of PiG
% ocol = gsettings.ocol;                              % color for OFM
% 
% vstyle = gsettings.vstyle;                          % style for vicon PiG
% zstyle = gsettings.zstyle;                          % style for zoo version of PiG
% ostyle = gsettings.ostyle;                          % stylefor OFM
% 
% LineWidth = gsettings.LineWidth;
% FontSize = gsettings.FontSize;
% FontName = gsettings.FontName;


vcol = gsettings.vcol;                              % color for vicon PiG
zcol = gsettings.zcol;                              % color for zoo version of PiG

vstyle = gsettings.vstyle;                          % style for vicon PiG
zstyle = gsettings.zstyle;                          % style for zoo version of PiG

LineWidth = gsettings.LineWidth;
FontSize = gsettings.FontSize;
FontName = gsettings.FontName;

dlength = find(~isnan(data.RightAnkleMoment_x.line(:,1)),1,'last');

figure
sides = {'Right','Left'};

for i = 1:length(sides)
    side = sides{i};
    s = side(1);
    
    if strcmp(side,'Left')
        offset= 4;
    else
        offset = 1;
    end
    
    % power plots
    subplot(4,6,offset);
    plot(data.([s,'HipPower']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'HipPower']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Hip'],'FontSize',FontSize,'FontName',FontName)
    axis('square')
    set(gca,'tag','HipPower')
    
    if i==1
        ylabel({'Power','(W/kg)'},'FontSize',FontSize,'FontName',FontName)
    end

    subplot(4,6,offset+1);
    plot(data.([s,'KneePower']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'KneePower']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Knee'],'FontSize',FontSize,'FontName',FontName)
    axis('square')
    set(gca,'tag','KneePower')
    
    subplot(4,6,offset+2);
    plot(data.([s,'AnklePower']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'AnklePower']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Ankle'],'FontSize',FontSize,'FontName',FontName)
    axis('square')
    set(gca,'tag','AnklePower')
    
    
    % moment plots
    subplot(4,6,offset+6);
    plot(data.([s,'HipMoment']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'HipMoment_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','HipMomentSagittal')
    
    if i==1
        ylabel({'Sagittal','Moment','(Nmm/kg)'},'FontSize',FontSize,'FontName',FontName)
    end

    
    subplot(4,6,offset+7);
    plot(data.([s,'KneeMoment']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'KneeMoment_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','KneeMomentSagittal')

    subplot(4,6,offset+8);
    plot(data.([s,'AnkleMoment']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'AnkleMoment_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','AnkleMomentSagittal')

    subplot(4,6,offset+12);
    plot(data.([s,'HipMoment']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'HipMoment_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','HipMomentCoronal')
    
    if i==1
        ylabel({'Coronal','Moment','(Nmm/kg)'},'FontSize',FontSize,'FontName',FontName)
    end
    
    
    subplot(4,6,offset+13);
    plot(data.([s,'KneeMoment']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'KneeMoment_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','KneeMomentCoronal')

    
    %         subplot(4,6,8+offset);
    %         plot(data.([s,'AnkleMoment']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    %         hold on
    %         plot(data.([side,'AnklePGMoment_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    %         axis('square')
    %         xlim([0 dlength])
    
    subplot(4,6,offset+18);
    plot(data.([s,'HipMoment']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'HipMoment_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','HipMomentTransverse')

    if i==1
        ylabel({'Transverse','Moment','(Nmm/kg)'},'FontSize',FontSize,'FontName',FontName)
    end
    
    subplot(4,6,offset+19);
    plot(data.([s,'KneeMoment']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'KneeMoment_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','KneeMomentTransverse')

    %         subplot(4,6,14+offset);
    %         plot(data.([s,'AnkleMoment']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    %         hold on
    %         plot(data.([side,'AnklePGMoment_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    %         axis('square')
    %         xlim([0 dlength])
    
    if i==2
        legend('Vicon','BiomechZoo')
    end
    
    ax = findobj('type','axes');
    for j = 1:length(ax)
        set(ax(j),'XLim',[0 dlength]);
    end
    
end


% Also plot OFM moments if available
%
if isfield(data,[sides{1},'AnkleMomentOFM'])  % OFM is included
    
    figure

    for i = 1:length(sides)
        side = sides{i};
        s = side(1);
   
        if strcmp(side,'Left')
            offset= 3;
        else
            offset = 1;
        end
        
        subplot(4,4,offset);
        plot(data.([s,'AnklePower']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnklePowerOFM']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        title([s,'Ankle'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        
        if i==1
            ylabel({'Power','(W/kg)'},'FontSize',FontSize,'FontName',FontName)
        end
        
        if i ==1
                legend('Vicon','biomchZoo')
        end
        
        subplot(4,4,offset+1);
        plot(data.([side,'MidFootPower']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        title([s,'Midfoot'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        
       
        subplot(4,4,offset+4);
        plot(data.([s,'AnkleMoment']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnkleMomentOFM']).line(:,1),'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
         if i==1
            ylabel({'Sagittal','Moment','(Nmm/kg)'},'FontSize',FontSize,'FontName',FontName)
         end
        
        subplot(4,4,offset+5);
        plot(data.([side,'MidFootMoment']).line(:,1),'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
        
        subplot(4,4,offset+8);
        plot(data.([s,'AnkleMoment']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnkleMomentOFM']).line(:,2),'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
         if i==1
            ylabel({'Coronal','Moment', '(Nmm/kg)'},'FontSize',FontSize,'FontName',FontName)
         end
        
        subplot(4,4,offset+9);
        plot(data.([side,'MidFootMoment']).line(:,1),'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
        
        subplot(4,4,offset+12);
        plot(data.([s,'AnkleMoment']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnkleMomentOFM']).line(:,3),'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
         if i==1
            ylabel({'Transverse','Moment','(Nmm/kg)'},'FontSize',FontSize,'FontName',FontName)
         end
        
        subplot(4,4,offset+13);
        plot(data.([side,'MidFootMoment']).line(:,3),'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
    end
        
end



