function data = segmentCOM_data(data)

% data = SEGMENTCOM_DATA(data) computes segmental COM positions for Plug-in Gait marker set

if nargin==0
    [data,fl] = testmode;
    test = true;
else
    fl = [];
    test = false;
end

% Set defaults
%
settings.segpar = 'segments.xls';                                % list of ratios from PiG                 
functionpath  = [fileparts(which('kinetics_data.m')),filesep];   % get root directory


% Extract relevant markers
%
if ~isfield(data,'LHipJC')
    LHJC = data.LHJC.line;
    RHJC = data.RHJC.line;
else
    LHJC = data.LHipJC.line;
    RHJC = data.RHipJC.line;
end

C7 = data.C7.line;
LFHD = data.LFHD.line;
RFHD = data.RFHD.line;
LBHD = data.LBHD.line;
RBHD = data.RBHD.line;
PELO = data.PELO.line;

% Head: "The centre of mass of the head is defined as being 0.52 * the distance from the front
% to the back of the head along the X axis from the head origin (the midpoint of the front 
% head markers). 
%
FrontHead = (LFHD + RFHD)/2;
BackHead = (LBHD + RBHD)/2;
HeadCOM = pointonline(FrontHead, BackHead, 0.52);


% L5: "The L5 position is estimated as (LHJC + RHJC)/2 + (0.0, 0.0, 0.828) * Length(LHJC - RHJC)"
%
pelvisWidth = nanmean(0.828* magnitude(LHJC - RHJC));
L5 = (LHJC + RHJC)/2;
L5(:,3) = L5(:,3) + pelvisWidth;


% Thorax: "The thorax length is taken as the distance between an approximation to the C7 
% vertebra and the L5 vertebra in the Thorax reference frame. C7 is estimated from the C7 
% marker, and offset by half a marker diameter in the direction of the X axis. L5 is estimated
% from the L5 provided from the pelvis segment, but localised to the thorax, rather than the 
% pelvis. The positions are calculated for all frames in the trial, and averaged to give the 
% mean length. The Centre of mass is deemed to lie at a proportion of 0.63 along this line.
%
C7(:,1) = C7(:,1)+data.zoosystem.Anthro.MarkerDiameter;
thoraxCOM = pointonline(L5, C7, 1-0.63);


% Pelvis: "The centre of mass is defined along a line from the midpoint of the hip joint 
% centers, to the centre of the top surface of the Lumbar 5 vertebra. For simplified scaling, 
% this distance is defined as 0.925 times the distance between the hip joint centers, and the
% Lumbar5 is defined as lying directly on the Z axis (derived by inspection from the bone mesh
% used in Polygon).
%
midPelvis = (LHJC + RHJC)/2;
% dist = mean(magnitude(L5-midPelvis));
% rHip2L5dist = magnitude(RHJC-L5);
% lHip2L5dist = magnitude(LHJC-L5);
% Hip2L5dist = mean([rHip2L5dist; lHip2L5dist]);
% scale = 0.925*Hip2L5dist;
pelvisCOM = pointonline(midPelvis,L5,0.895);           % i'm using the PiG table here


% Hands: "The length of the hand in this model is defined as the distance from the wrist joint
% centre to the finger tip. An estimate of 0.75 is taken as the proportion of this length to 
% the "Knuckle II" reference point referred to in the Dempster data.
%



% COM for the lower-limbs (this is same method used in kinetics_data.m)
%
body = struct;                                                  % build new struct
body.bodymass = getanthro(data,'Bodymass');                     % extract mass info
body.fsamp = data.zoosystem.Video.Freq;

[pgbone,~,data] = getbones_data(data);
pgbone = pgbone(2:end,:);
pgdim = {'O','A','L','P'};

SegmentPar = getSegmentPar([functionpath,settings.segpar]);

data = setSegmentPar(pgdim,pgbone,data,SegmentPar,body);



% rename channels computed in setSegmentPar
%
och = {'Pelviscom','RightFemurcom','RightTibiacom','RightFootcom','RightRadiuscom',...
       'RightHumeruscom','RightHandcom','LeftFemurcom','LeftTibiacom','LeftFootcom',...
       'LeftRadiuscom','LeftHumeruscom','LeftHandcom'};
nch = strrep(och,'com','COM');
data = renamechannel_data(data,och,nch);



% Add channels to data
%
data = addchannel_data(data,'HeadCOM',HeadCOM,'video');
data = addchannel_data(data,'L5',L5,'video');
data = addchannel_data(data,'TrunkCOM',thoraxCOM,'video');
data = addchannel_data(data,'PelvisCOM',pelvisCOM,'video');
data = addchannel_data(data,'midPelvis',midPelvis,'video');


if ~isempty(fl)
   [fpath,fname] = fileparts(fl);
   fname = [fname,'_testCOM']; 
   file = [fpath,filesep,fname,'.zoo'];
   zsave(file,data)
end


function [data,file] = testmode

pth = fileparts(which('segmentCOM_data.m'));
indx = strfind(pth,'my biomechZoo add-ons');
root = pth(1:indx+20);
file = [root,filesep,'HC002D25.zoo'];

if ~exist(file,'file')
    error('no sample data available for testing')
else
    data = zload(file);
end
