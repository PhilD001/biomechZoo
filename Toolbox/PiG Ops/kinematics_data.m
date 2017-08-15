function data = kinematics_data(data,settings)

% data = KINEMATICS_DATA(data,settings) computes global and lower-limb
% joint angles based on the joint coordinate system of Grood and Suntay (1983)
%
% ARGUMENTS
%  data     ...  Zoo data
%  settings ...  Settings control (struct) with the following fields:
%                'graph' (boolean). Graph comparisons agains Vicon. Default, false
%                'comp'  (boolean). Vicon vs BiomeZoo RMS diff (if available). Default, true
%
% RETURNS
%  data    ...   zoo data appended with kinemaitc channels
%
%
% NOTES:
% - It is anatomically implausible for the vectors to flip during walking but may be
%   possible for tasks with large ranges of motion (e.g. running). A correction has been
%   implemented at the knee, but might require future updates (see 'checkflippg')
% - For PiG, choice of axes for angle computation based on work of Vaughan
%   (Dynamics of Human Gait 1999, Appendix B p94-96). This is the Grood and Suntay method.
% - For OFM, choice of axes based on trial and error.
% - Lower limb PiG outputs of this function have been validated
%   (see Fig4.dpf and Supplemental Fig2.pdf in ~\biomechZoo-samplestudy\Figures\manuscript\
% - Head angles are not offset by static posture (PiG angles use static offset)
%
% SUMMARY OF CALCULATIONS
%
% floating axis (PIG) = cross(lat_prox , long_dist)
%
% Pelvis
% flx = asind(dot(-long_dist,lat_prox,2));
% abd = asind(dot(long_dist,ant_prox,2)./cosd(flx));
% twix = asind( dot(ant_dist,ant_prox,2)./cosd(flx));
% twiy = asind( dot(ant_dist,lat_prox,2)./cosd(flx));
% * adjustments made on direction of travel
%
% Hip & Knee
% flx = asind(dot(floatax,long_prox,2));
% abd = asind(dot(lat_prox,long_dist,2));
% tw  = asind(dot(floatax,lat_dist,2));
%
% Ankle PiG
% flx = asind(dot(floatax,ant_prox,2));
% abd = asind(dot(lat_prox,long_dist,2));
% tw  = asind(dot(floatax,lat_dist,2));
%
% See also makebones_data, bmech_kinematicsPiG, bmech_jointcentrePiG


% Revision History
%
% Created by Philippe C Dixon and JJ Loh 2008
%
% Updated by Philippe C Dixon January 2011
% - tested against vicon output 100% match for both PIG and OFM
% - grood and suntay calculations occur in embedded function 'groodsuntay'
%
% Updated by Philippe C Dixon September 2012
% - possibility to graph results as a visual check
% - added abd/add of hallux segment
% - added simple demo mode
% - calculations simplified
% - only reference frame is Vicon
% - correction for axis flipping at the knee implemented using 'checkflip' function
%
% Updated by Philippe C Dixon June 2016
% - Function can run using 'raw' files, i.e. data with PiG markers only, not run
%   through Vicon modeller (see makebones.m). This functionality has not been extended
%   to the OFM data
% - Static trial is used to correctly adjust ankle offset values
% - Foot flat option matches option in Vicon
%
% Updated by Philippe C. Dixon Sept 2016
% - biomechZoo pelvis angles validated against PiG outputs for straight
%   walking see ~/biomechZoo-samplestudy/Figures/Pelvis_kinematics_Straight.pdf
% - improved graphical outputs
%
% Updated by Philippe C. Dixon June 2017
% - global head and thorax angles included
% - More testing of global angles in all directions
% - Fixed bug with graphing outputs



% Set defaults
%
if nargin==0                                                    % test mode
    [data,settings] = testmode;
end



if nargin==1
    settings.graph = false;
    settings.comp  = false;
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


%----0 : MAKE BONES ----------------------------------------------------------------------
% 
% - Uncommenting next line allows bones to be calculated from scratch
% data = makebones_data(data);                  


%----1 : GET BONES -----------------------------------------------------------------------
%
% collect bones into appropriate format


[bone,jnt,data,oxbone] = getbones_data(data);

if isempty(bone)
    error('no PiG virtual markers found')
end


%----2: PREPARE DATA FOR GROOD AND SUNTAY CALCULATIONS -----------------------------------
%
dimPiG = {'O','A','L','P'};
% O is origin of bone, at distal joint (letter O)
% A is an anterior vector from bone
% L is medial( right) or lateral (left) vector
% P is long axis of bone vector (pointing proximally)


for i = 1:length(bone(:,1))
    
    d = cell(1,length(dimPiG));
    
    if strcmp(bone{i,1},'GLB')
        d{1} =  zeros(size(data.([bone{i+1,1},dimPiG{1}]).line));
        d{2} =  [d{1}(:,1)+10 d{1}(:,2:3)];
        d{3} =  [d{1}(:,1) d{1}(:,2)+10 d{1}(:,3)];
        d{4} =  [d{1}(:,1:2) d{1}(:,3)+10];
    else
        
        for j = 1:4
            d{j} = data.([bone{i,1},dimPiG{j}]).line;
        end
    end
    
    bn = bone{i,2};
    ort = getdataPiG(d);
    r.(bn).ort = ort;
end

dimOFM = {'0','1','2','3'};
% 0 is origin of bone (zero)
% 1 is anterior vector
% 2 is medial (right) or lateral(left) vector
% 3 is long axis of bone vector (pointing distally)


if ~isempty(oxbone)
    
    for i = 1:length(oxbone(:,1))
        d = cell(1,length(dimOFM));
        
        for j = 1:4
            d{j} = data.([oxbone{i,1},dimOFM{j}]).line;
        end
        
        bn = oxbone{i,2};
        ort = getdataOFM(d);
        r.(bn).ort = ort;
    end
    
end


%----3: COMPUTE JOINT ANGLES ACCORDING TO GROOD AND SUNTAY -------------------------------
%
[~,dir] = getDir(data);
KIN = get_grood_suntay(r,jnt,dir);


%----4: FIX REFERENCE SYSTEM TO MATCH CLINICAL--------------------------------------------
%
% - rename channels to match the oxford names

KIN = refsystem(KIN);


%----6: CHECK ACCURACY OF CALCULATIONS AGAINST ORIGINAL VICON DATA (DISPLAY OPTIONAL) ----
%
if settings.comp == true
    ERR=checkvicon(KIN,data);
else
    ERR = [];
end

%----7: ADD COMPUTED ANGLES TO DATA STRUCT -----------------------------------------------
%
data = addchannelsgs(data,KIN,ERR);


%----8: IMPLEMENT A GRAPHICAL CHECK AGAINST ORIGINAL VICON DATA (OPTIONAL)
%

if settings.graph == true
    graphresults(data,gsettings)
end




%=================EMBEDDED FUNCTIONS=======================================


function [data,settings] = testmode

[f,p]=uigetfile({'*.c3d;*.zoo'});
fpath = [p,f];
cd(p)
ext = extension(fpath);

if isin(ext,'c3d')
    data= c3d2zoo(fpath);
elseif isin(ext,'zoo')
    data = zload(fpath);
else
    error('only c3d and zoo files can be input')
end

settings.graph  = true;                                    % graph results
settings.comp   = true;


function ort = getdataOFM(d)

% For HF, FF, HX these are correct axes, for TB x and z are interchanged.
% This is accounted for in groodsuntay.m

z = (d{2}-d{1})/10;   % Anterior - Origin:          Creates anterior vector
y = (d{3}-d{1})/10;   % Medial - Origin:            Creates medial vector (right side), Lateral vector (left side)
x = (d{4}-d{1})/10;   % Distal - Origin:            Creates vector along long axis of bone

% rw = size(x);
% ort = [];
% for i = 1:rw
%     ort = [ort;{[x(i,:);y(i,:);z(i,:)]}]; %for updated grood suntay version
% end

rw = length(x);
ort = cell(rw,1);
for i = 1:rw
    ort{i} = [x(i,:);y(i,:);z(i,:)];     %for updated grood suntay version
end


function ort = getdataPiG(d)

% data comes in as O,A,L,P
O = 1;
A = 2;
L = 3;
P = 4;

x = (d{A}-d{O})/10;   % Anterior - Origin:          Creates anterior vector
y = (d{L}-d{O})/10;   % Medial - Origin:            Creates medial vector (right side), Lateral vector (left side)
z = (d{P}-d{O})/10;   % Distal - Origin:            Creates vector along long axis of bone

rw = length(x);
ort = cell(rw,1);
for i = 1:rw
    ort{i} = [x(i,:);y(i,:);z(i,:)];     %for updated grood suntay version
end


function KIN = get_grood_suntay(r,jnt,dir)

% alpha goes into flx
% beta goes into abd
% gamma goes into IntExt


for i = 1:length(jnt(:,1))
    [KIN.(jnt{i,1}).flx,KIN.(jnt{i,1}).abd,KIN.(jnt{i,1}).tw] = groodsuntay(r,jnt(i,1:end),dir);
end


function [flx,abd,tw] = groodsuntay(r,jnt,dir)

% Grood and Suntay angle calculations based on adaptation by Vaughan 'The
% Gait Book' Appendix B, p95. Offsets made to match oxford foot model
% outputs

% Axis set-up follows Vicon

% Updated January 15th 2011
% - works with VICON2GROODSUNTAY

%---SET UP VARIABLES ---

pbone = jnt{2};
dbone = jnt{3};

pax = r.(pbone).ort;  % contains xyz local axes for each frame
dax = r.(dbone).ort;

if ~isempty(strfind(pbone,'Right'))
    bone = pbone(6:end);
elseif ~isempty(strfind(pbone,'Left'))
    bone = pbone(5:end);
else
    bone = pbone;
end

%---CREATE AXES FOR GROOD AND SUNTAY CALCULATIONS----

switch bone
    
    case 'Global'
        [~,ant_prox,ant_dist,lat_prox,~,~,long_dist] = makeaxPiG(pax,dax);
        
        flx = asind(dot(-long_dist,lat_prox,2));
        abdx = asind(dot(long_dist,ant_prox,2)./cosd(flx));
        twix = asind(dot(ant_dist,ant_prox,2)./cosd(flx));
        twiy = asind(dot(ant_dist,lat_prox,2)./cosd(flx));
        
        [flx,abd,tw] = checkdir(flx,abdx,twix,twiy,dir);
        
    case {'Pelvis','Femur'}  % Hip and Knee
        [floatax,~,~,lat_prox,lat_dist,long_prox,long_dist] = makeaxPiG(pax,dax);
        
        flx = asind(dot(floatax,long_prox,2));
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
        
        if isnear(max(abs(flx)),90,1)
            flx = checkflipPiG(flx,floatax,long_prox);
        end
        
    case 'Tibia'   % Ankle PG angles
        [floatax,ant_prox,~,lat_prox,lat_dist,~,long_dist] = makeaxPiG(pax,dax);
        
        flx = asind(dot(floatax,ant_prox,2)); % chosen to avoid axis flipping
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
        
    case 'TibiaStatic'   % Ankle PG Static angles
        [floatax,~,~,lat_prox,lat_dist,long_prox,long_dist] = makeaxPiG(pax,dax);
        
        flx = asind(dot(floatax,long_prox,2));    % beta from pyCGM
        abd = asind(dot(lat_prox,long_dist,2));   % alpha from pyCGM
        tw  = asind(dot(floatax,lat_dist,2));     % gamma from pyCGM
        
    case 'TibiaOFM'   % hindfoot tibia angle
        
        [floatax,~,ant_dist,lat_prox,lat_dist,long_prox] = makeaxOFM(pax,dax);
        
        flx = angle(floatax,long_prox);        % plantar/ dorsi
        abd = angle(lat_prox,ant_dist);        % inv / eve
        tw  = angle(floatax,lat_dist);         % int / ext
        
    case {'HindFoot','ForeFoot'}  % forefoot hindfoot angle
        
        [floatax,ant_prox,ant_dist,lat_prox,lat_dist] = makeaxOFM(pax,dax);
        
        flx = angle(floatax,ant_prox);        % plantar/ dorsi
        abd = angle(lat_prox,ant_dist);       % int / ext
        tw  = angle(floatax,lat_dist);        % pro / suppination
        
    otherwise
        [floatax,~,~,lat_prox,lat_dist,long_prox,long_dist] = makeaxPiG(pax,dax);
        
        flx = asind(dot(floatax,long_prox,2));
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
end


function [phi,theta,psi] = checkdir(phix,thetax,psix,psiy,dir)

switch dir
    
    case 'Jpos'                  % verified with:
        phi   = -phix;           % - Corey_SUPSTA04 (IHRG, Phil Renaud)     no upper body
        theta = -thetax;         % - HC038A11 (OGL, biomechZoo sample data) has upper body
        psi   = -psix;
        
    case 'Jneg'                  % verified with:
        phi   = phix;            % - C1605A04 (OGL lab,Andrew Lewis)           no upper body
        theta = thetax;          % - Subject 66 Right 1,3,4,5 (Matthew Taylor) has upper body
        psi   = psix;            % - HC036A10 (OGL, biomechZoo sample data)    has upper body
        
    case 'Ipos'                  % verified with
        phi   =  thetax;         % - DiCP2 (UZ leuven)   no upper body
        theta = -phix;           % - TD1a,b (UZ leuven)  no upper body
        psi   =  psiy;           % NEED TEST WITH UPPER BODY FOR HEAD AND THORAX
        
    case 'Ineg'                  % verified with:
        phi   = -thetax;         % - gait-pig-nz (c3d.org data)  no upper body
        theta =  phix;           % - DiCP3a (UZ Leuven)          no upper body
        psi   = -psiy;           % NEED TEST WITH UPPER BODY FOR HEAD AND THORAX
        
end



function [floatax,ant_prox,ant_dist,lat_prox,lat_dist,long_prox,long_dist] = makeaxPiG(pax,dax)

ant_prox = zeros(length(pax),3);
lat_prox = zeros(length(pax),3);
long_prox = zeros(length(pax),3);

ant_dist = zeros(length(pax),3);
lat_dist = zeros(length(pax),3);
long_dist = zeros(length(pax),3);

floatax = zeros(length(pax),3);

for i = 1:length(pax)
    ant_prox(i,:) = pax{i}(1,:);
    lat_prox(i,:) = pax{i}(2,:);
    long_prox(i,:) = pax{i}(3,:);
    
    ant_dist(i,:) = dax{i}(1,:);
    lat_dist(i,:) =  dax{i}(2,:);
    long_dist(i,:) = dax{i}(3,:);
    
    floatax(i,:) =cross(lat_prox(i,:),long_dist(i,:));
end


floatax = makeunit(floatax);
ant_prox = makeunit(ant_prox);
ant_dist = makeunit(ant_dist);
lat_prox = makeunit(lat_prox);
lat_dist = makeunit(lat_dist);
long_prox = makeunit(long_prox);
long_dist = makeunit(long_dist);


function [floatax,ant_prox,ant_dist,lat_prox,lat_dist,long_prox] = makeaxOFM(pax,dax)

ant_prox = zeros(length(pax),3);
lat_prox = zeros(length(pax),3);
long_prox = zeros(length(pax),3);

ant_dist = zeros(length(pax),3);
lat_dist = zeros(length(pax),3);

floatax = zeros(length(pax),3);


for i = 1:length(pax)
    ant_prox(i,:) = pax{i}(1,:);
    lat_prox(i,:) = pax{i}(2,:);
    long_prox(i,:) = pax{i}(3,:);
    
    lat_dist(i,:) = dax{i}(2,:);
    ant_dist(i,:) = dax{i}(1,:);
    
    floatax(i,:) = cross(lat_prox(i,:), ant_dist(i,:));
end


function flx = checkflipPiG(flx,float,long_prox)

one = cross(float(1,:),long_prox(1,:));   % here the calculation must be correct

if one(1) > 0
    dir ='pos';
else
    dir = 'neg';
end


flcross = zeros(size(float));
nflx = zeros(size(flx));

if isin(dir,'pos')
    
    for i = 1:length(float)
        flcross(i,:) = cross(float(i,:),long_prox(i,:));
        
        if flcross(i,1) < 0
            nflx(i) = -180-flx(i);
        else
            nflx(i) = flx(i);
        end
    end
    
else
    
    for i = 1:length(float)
        flcross(i,:) = cross(float(i,:),long_prox(i,:));
        
        if flcross(i,1) > 0
            nflx(i) = 180-flx(i);
        else
            nflx(i) = flx(i);
        end
    end
    
end

flx = nflx;


function r=refsystem(KIN)
% Change names to match vicon nomenclature

r = struct;

if isfield(KIN,'RightKnee')  % checks for plugin gait
    r.RightPelvis.Tilt      = KIN.GlobalPelvis.flx;
    r.RightPelvis.Obliquity = KIN.GlobalPelvis.abd;
    r.RightPelvis.IntExt    = KIN.GlobalPelvis.tw;
    
    r.LeftPelvis.Tilt       = KIN.GlobalPelvis.flx;
    r.LeftPelvis.Obliquity  = -KIN.GlobalPelvis.abd;
    r.LeftPelvis.IntExt     = -KIN.GlobalPelvis.tw;
    
    r.RightHip.FlxExt = KIN.RightHip.flx;
    r.RightHip.AbdAdd = -KIN.RightHip.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightHip.IntExt = -KIN.RightHip.tw;
    
    r.LeftHip.FlxExt = KIN.LeftHip.flx;
    r.LeftHip.AbdAdd = KIN.LeftHip.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftHip.IntExt = KIN.LeftHip.tw;
    
    r.RightKnee.FlxExt = -KIN.RightKnee.flx;
    r.RightKnee.AbdAdd = -KIN.RightKnee.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightKnee.IntExt = -KIN.RightKnee.tw;
    
    r.LeftKnee.FlxExt = -KIN.LeftKnee.flx;
    r.LeftKnee.AbdAdd = KIN.LeftKnee.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftKnee.IntExt = KIN.LeftKnee.tw;
    
    r.RightAnkle.PlaDor = -KIN.RightAnkle.flx;
    r.RightAnkle.IntExt = -KIN.RightAnkle.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightAnkle.InvEve = -KIN.RightAnkle.tw;
    
    r.LeftAnkle.PlaDor = -KIN.LeftAnkle.flx;
    r.LeftAnkle.IntExt = KIN.LeftAnkle.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftAnkle.InvEve = KIN.LeftAnkle.tw;
end

if isfield(KIN,'GlobalHead')  % checks for plugin gait
    r.RightHead.Tilt      = -KIN.GlobalHead.flx;
    r.RightHead.Obliquity = KIN.GlobalHead.abd;
    r.RightHead.IntExt    = KIN.GlobalHead.tw;
    
    r.LeftHead.Tilt      = -KIN.GlobalHead.flx;
    r.LeftHead.Obliquity = -KIN.GlobalHead.abd;
    r.LeftHead.IntExt    = -KIN.GlobalHead.tw;
    
end

if isfield(KIN,'GlobalThorax')  % checks for plugin gait
    r.RightThorax.Tilt      =  -KIN.GlobalThorax.flx;
    r.RightThorax.Obliquity =  -KIN.GlobalThorax.abd;
    r.RightThorax.IntExt    =  KIN.GlobalThorax.tw;
    
    r.LeftThorax.Tilt      =  -KIN.GlobalThorax.flx;
    r.LeftThorax.Obliquity =  KIN.GlobalThorax.abd;
    r.LeftThorax.IntExt    =  -KIN.GlobalThorax.tw;
    
end

if isfield(KIN,'RightAnkleStatic')
    r.RightAnkleStatic.PlaDor = KIN.RightAnkleStatic.flx;
    r.RightAnkleStatic.IntExt = KIN.RightAnkleStatic.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightAnkleStatic.InvEve = KIN.RightAnkleStatic.tw;
    
    r.LeftAnkleStatic.PlaDor  = KIN.LeftAnkleStatic.flx;
    r.LeftAnkleStatic.IntExt  = KIN.LeftAnkleStatic.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftAnkleStatic.InvEve = KIN.LeftAnkleStatic.tw;
end

if isfield(KIN,'RightMidFoot')  % checks for oxford
    
    %Right Ankle (HindFoot relative to Tibia)
    r.RightAnkleOFM.PlaDor = -KIN.RightAnkleOFM.flx+90;
    r.RightAnkleOFM.InvEve = -KIN.RightAnkleOFM.abd+90;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightAnkleOFM.IntExt = KIN.RightAnkleOFM.tw-90;
    
    % 'LeftAnkleOFM'   % HindFoot relative to Tibia
    r.LeftAnkleOFM.PlaDor = -KIN.LeftAnkleOFM.flx+90;
    r.LeftAnkleOFM.InvEve =  KIN.LeftAnkleOFM.abd-90;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftAnkleOFM.IntExt = -KIN.LeftAnkleOFM.tw+90;
    
    %'RightMidFoot'   % Forefoot relative to Hindfoot
    r.RightMidFoot.PlaDor = -KIN.RightMidFoot.flx+90;
    r.RightMidFoot.SupPro =  KIN.RightMidFoot.tw-90;
    r.RightMidFoot.AbdAdd = -KIN.RightMidFoot.abd+90;
    
    % 'LeftMidFoot'   % Forefoot relative to Hindfoot
    r.LeftMidFoot.PlaDor = -KIN.LeftMidFoot.flx+90;
    r.LeftMidFoot.SupPro = -KIN.LeftMidFoot.tw+90;
    r.LeftMidFoot.AbdAdd =  KIN.LeftMidFoot.abd-90;
    
    % 'RightMTP'       % Hallux relative to Forefoot
    r.RightMTP.PlaDor = -KIN.RightMTP.flx+90;
    r.RightMTP.AbdAdd = -KIN.RightMTP.abd+90;
    r.RightMTP.IntExt = zeros(size(KIN.RightMTP.tw));   % garbage
    
    % 'LeftMTP'          % Hallux relative to Forefoot
    r.LeftMTP.PlaDor = -KIN.LeftMTP.flx+90;
    r.LeftMTP.AbdAdd = KIN.LeftMTP.abd-90;
    r.LeftMTP.IntExt = zeros(size(KIN.LeftMTP.tw));     % garbage
end


function data = addchannelsgs(data,KIN,ERR)

% add plugingait channels---

kch = {'RightHead','RightThorax','RightPelvis','RightHip','RightKnee','RightAnkle',...
    'LeftHead', 'LeftThorax', 'LeftPelvis', 'LeftHip', 'LeftKnee', 'LeftAnkle'};                       % Vicon lower-limbs
kch = intersect(kch,fieldnames(KIN));

for i = 1:length(kch)
    
    dsub = {'x','y','z'};
    ksub = {'FlxExt','AbdAdd','IntExt'};
    asub = {'PlaDor','InvEve','IntExt'};
    gsub = {'Tilt','Obliquity','IntExt'};
    for j = 1:length(dsub)
        
        if ~isempty(strfind(kch{i},'Ankle'))
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(asub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.NRMSE = [1 ERR.(kch{i}).(asub{j}).NRMSE 0];
            end
            
        elseif ~isempty(strfind(kch{i},'Pelvis')) || ~isempty(strfind(kch{i},'Head')) ...
                || ~isempty(strfind(kch{i},'Thorax'))
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(gsub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.NRMSE = [1 ERR.(kch{i}).(gsub{j}).NRMSE 0];
            end
            
        else
            
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(ksub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.NRMSE = [1 ERR.(kch{i}).(ksub{j}).NRMSE 0];
            end
        end
    end
end

%-- add static angles

if isfield(KIN,'RightAnkleStatic')
    kch = {'RightAnkleStatic','LeftAnkleStatic'};
    
    for i = 1:length(kch)
        
        dsub = {'x','y','z'};
        asub = {'PlaDor','InvEve','IntExt'};
        
        for j = 1:length(dsub)
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(asub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.NRMSE = [1 NaN 0]; % no error possible
            end
        end
    end
    
end

if isfield(KIN,'RightAnkleOFM')
    
    sides = {'Right','Left'};
    
    for i = 1:length(sides)
        
        side =sides{i};
        
        data = addchannel_data(data,[side,'HFTBA_x'],KIN.([side,'AnkleOFM']).PlaDor,'Video');
        data = addchannel_data(data,[side,'HFTBA_y'],KIN.([side,'AnkleOFM']).InvEve,'Video');
        data = addchannel_data(data,[side,'HFTBA_z'],KIN.([side,'AnkleOFM']).IntExt,'Video');
        
        data = addchannel_data(data,[side,'FFHFA_x'],KIN.([side,'MidFoot']).PlaDor,'Video');
        data = addchannel_data(data,[side,'FFHFA_y'],KIN.([side,'MidFoot']).AbdAdd,'Video');
        data = addchannel_data(data,[side,'FFHFA_z'],KIN.([side,'MidFoot']).SupPro,'Video');
        
        data = addchannel_data(data,[side,'HXFFA_x'],KIN.([side,'MTP']).PlaDor,'Video');
        data = addchannel_data(data,[side,'HXFFA_y'],KIN.([side,'MTP']).AbdAdd,'Video');
        
        if ~isempty(ERR)
            data.([side,'HFTBA_x']).event.NRMSE = [1 ERR.([side,'AnkleOFM']).PlaDor.NRMSE 0];
            data.([side,'HFTBA_y']).event.NRMSE = [1 ERR.([side,'AnkleOFM']).InvEve.NRMSE 0];
            data.([side,'HFTBA_z']).event.NRMSE = [1 ERR.([side,'AnkleOFM']).IntExt.NRMSE 0];
            
            data.([side,'FFHFA_x']).event.NRMSE = [1 ERR.([side,'MidFoot']).PlaDor.NRMSE 0];
            data.([side,'FFHFA_z']).event.NRMSE = [1 ERR.([side,'MidFoot']).AbdAdd.NRMSE 0];
            data.([side,'FFHFA_y']).event.NRMSE = [1 ERR.([side,'MidFoot']).SupPro.NRMSE 0];
            
            data.([side,'HXFFA_x']).event.NRMSE = [1 ERR.([side,'MTP']).PlaDor.NRMSE 0];
            data.([side,'HXFFA_y']).event.NRMSE = [1 ERR.([side,'MTP']).AbdAdd.NRMSE 0];
            data.([side,'HXFFA_y']).event.NRMSE = [1 ERR.([side,'MTP']).IntExt.NRMSE 0];
            
            
        end
        
    end
end


function ERR=checkvicon(KIN,data)

ERR = struct;
chPiG = [];
chOFM = [];

if isfield(data,'RKneeAngles')
    [errPiG,chPiG]= checkPiG(KIN,data);
end


if isfield(data,'RHFTBA')
    [errOFM,chOFM]= checkOFM(KIN,data);
end


for j = 1:length(chPiG)
    ERR.(chPiG{j}) = errPiG.(chPiG{j});
end

for j = 1:length(chOFM)
    ERR.(chOFM{j}) = errOFM.(chOFM{j});
end


function [ERR,ch] = checkOFM(KIN,data)

RA = zeros(3,1);
RMF = zeros(3,1);
RMTP = zeros(3,1);

LA = zeros(3,1);
LMF = zeros(3,1);
LMTP = zeros(3,1);

subch = {'PlaDor','InvEve','IntExt'}; % Ankle angle
for k = 1:length(subch)
    RA(k) = nrmse(data.RHFTBA.line(:,k),KIN.RightAnkleOFM.(subch{k}));
    LA(k) = nrmse(data.LHFTBA.line(:,k),KIN.LeftAnkleOFM.(subch{k}));
end

subch = {'PlaDor','SupPro','AbdAdd'};  % MidFoot angle
for k = 1:length(subch)
    RMF(k) = nrmse(data.RFFHFA.line(:,k), KIN.RightMidFoot.(subch{k}));
    LMF(k) = nrmse(data.LFFHFA.line(:,k), KIN.LeftMidFoot.(subch{k}));
end

subch = {'PlaDor','AbdAdd','IntExt'};  % MTP angle
for k = 1:length(subch)
    RMTP(k) = nrmse(data.RHXFFA.line(:,k), KIN.RightMTP.(subch{k}));
    LMTP(k) = nrmse(data.LHXFFA.line(:,k), KIN.LeftMTP.(subch{k}));
end

ERR.RightAnkleOFM.PlaDor.NRMSE =RA(1);
ERR.RightAnkleOFM.InvEve.NRMSE =RA(2);
ERR.RightAnkleOFM.IntExt.NRMSE =RA(3);

ERR.RightMidFoot.PlaDor.NRMSE = RMF(1);
ERR.RightMidFoot.SupPro.NRMSE = RMF(2);
ERR.RightMidFoot.AbdAdd.NRMSE = RMF(3);

ERR.RightMTP.PlaDor.NRMSE = RMTP(1);
ERR.RightMTP.AbdAdd.NRMSE = RMTP(2);
ERR.RightMTP.IntExt.NRMSE = 999*RMTP(3);  % garbage

ERR.LeftAnkleOFM.PlaDor.NRMSE = LA(1);
ERR.LeftAnkleOFM.InvEve.NRMSE = LA(2);
ERR.LeftAnkleOFM.IntExt.NRMSE = LA(3);

ERR.LeftMidFoot.PlaDor.NRMSE = LMF(1);
ERR.LeftMidFoot.SupPro.NRMSE = LMF(2);
ERR.LeftMidFoot.AbdAdd.NRMSE = LMF(3);

ERR.LeftMTP.PlaDor.NRMSE = LMTP(1);
ERR.LeftMTP.AbdAdd.NRMSE = LMTP(2);
ERR.LeftMTP.IntExt.NRMSE = 999*LMTP(3);  % garbage


ch = fieldnames(ERR);


function [ERR,ch]= checkPiG(KIN,data)

RHdstk  = zeros(3,1);     % head (absolute)
LHdstk  = zeros(3,1);     % head (absolute)
RTstk  = zeros(3,1);     % thorax (absolute)
LTstk  = zeros(3,1);     % thorax (absolute)
RPstk = zeros(3,1);      % pelvis (absolute)
LPstk = zeros(3,1);      % pelvis (absolute)
LHstk = zeros(3,1);      % Left hip (relative)
LKstk = zeros(3,1);      % Left knee (relative)
LAstk = zeros(3,1);      % Left ankle (relative)
RHstk = zeros(3,1);      % Right hip (relative)
RKstk = zeros(3,1);      % Right knee (relative)
RAstk = zeros(3,1);      % Right ankle (relative)

subch = {'FlxExt','AbdAdd','IntExt'};
for k = 1:3
    LHstk(k) = nrmse(data.LHipAngles.line(:,k), KIN.LeftHip.(subch{k}));
    LKstk(k) = nrmse(data.LKneeAngles.line(:,k),KIN.LeftKnee.(subch{k}));
    RHstk(k) = nrmse(data.RHipAngles.line(:,k), KIN.RightHip.(subch{k}));
    RKstk(k) = nrmse(data.RKneeAngles.line(:,k),KIN.RightKnee.(subch{k}));
end

subchp = {'Tilt','Obliquity','IntExt',};
for k = 1:3
    RPstk(k)=nrmse(data.RPelvisAngles.line(:,k),KIN.RightPelvis.(subchp{k}));
    LPstk(k)=nrmse(data.LPelvisAngles.line(:,k),KIN.LeftPelvis.(subchp{k}));
end

if isfield(data,'RHeadAngles')
    subchp = {'Tilt','Obliquity','IntExt',};
    for k = 1:3
        RHdstk(k)=nrmse(data.RHeadAngles.line(:,k),KIN.RightHead.(subchp{k}));
        LHdstk(k)=nrmse(data.LHeadAngles.line(:,k),KIN.LeftHead.(subchp{k}));
    end
end

if isfield(data,'RThoraxAngles')
    subchp = {'Tilt','Obliquity','IntExt',};
    for k = 1:3
        RTstk(k)=nrmse(data.RThoraxAngles.line(:,k),KIN.RightThorax.(subchp{k}));
        LTstk(k)=nrmse(data.LThoraxAngles.line(:,k),KIN.LeftThorax.(subchp{k}));
    end
end


subcha = {'PlaDor','InvEve','IntExt',};
for k = 1:3
    LAstk(k) = nrmse(data.LAnkleAngles.line(:,k), KIN.LeftAnkle.(subcha{k}));
    RAstk(k) = nrmse(data.RAnkleAngles.line(:,k), KIN.RightAnkle.(subcha{k}));
end

ERR.RightHead.Tilt.NRMSE      = RHdstk(1);
ERR.RightHead.Obliquity.NRMSE = RHdstk(2);
ERR.RightHead.IntExt.NRMSE    = RHdstk(3);

ERR.LeftHead.Tilt.NRMSE      = LHdstk(1);
ERR.LeftHead.Obliquity.NRMSE = LHdstk(2);
ERR.LeftHead.IntExt.NRMSE    = LHdstk(3);

ERR.RightThorax.Tilt.NRMSE      = RTstk(1);
ERR.RightThorax.Obliquity.NRMSE = RTstk(2);
ERR.RightThorax.IntExt.NRMSE    = RTstk(3);

ERR.LeftThorax.Tilt.NRMSE      = LTstk(1);
ERR.LeftThorax.Obliquity.NRMSE = LTstk(2);
ERR.LeftThorax.IntExt.NRMSE    = LTstk(3);

ERR.RightPelvis.Tilt.NRMSE      = RPstk(1);
ERR.RightPelvis.Obliquity.NRMSE = RPstk(2);
ERR.RightPelvis.IntExt.NRMSE    = RPstk(3);

ERR.LeftPelvis.Tilt.NRMSE      = LPstk(1);
ERR.LeftPelvis.Obliquity.NRMSE = LPstk(2);
ERR.LeftPelvis.IntExt.NRMSE    = LPstk(3);

ERR.RightAnkle.PlaDor.NRMSE = RAstk(1);
ERR.RightAnkle.IntExt.NRMSE = RAstk(2);
ERR.RightAnkle.InvEve.NRMSE = RAstk(3);

ERR.RightKnee.FlxExt.NRMSE = RKstk(1);
ERR.RightKnee.AbdAdd.NRMSE = RKstk(2);
ERR.RightKnee.IntExt.NRMSE = RKstk(3);

ERR.RightHip.FlxExt.NRMSE = RHstk(1);
ERR.RightHip.AbdAdd.NRMSE = RHstk(2);
ERR.RightHip.IntExt.NRMSE = RHstk(3);

ERR.LeftAnkle.PlaDor.NRMSE = LAstk(1);
ERR.LeftAnkle.IntExt.NRMSE = LAstk(2);
ERR.LeftAnkle.InvEve.NRMSE = LAstk(3);

ERR.LeftKnee.FlxExt.NRMSE = LKstk(1);
ERR.LeftKnee.AbdAdd.NRMSE = LKstk(2);
ERR.LeftKnee.IntExt.NRMSE = LKstk(3);

ERR.LeftHip.FlxExt.NRMSE = LHstk(1);
ERR.LeftHip.AbdAdd.NRMSE = LHstk(2);
ERR.LeftHip.IntExt.NRMSE = LHstk(3);

ch = fieldnames(ERR);


function graphresults(data,gsettings)

vcol = gsettings.vcol;                              % color for vicon PiG
zcol = gsettings.zcol;                              % color for zoo version of PiG

vstyle = gsettings.vstyle;                          % style for vicon PiG
zstyle = gsettings.zstyle;                          % style for zoo version of PiG

LineWidth = gsettings.LineWidth;
FontSize = gsettings.FontSize;
FontName = gsettings.FontName;

dlength = find(~isnan(data.RightAnkleAngle_x.line(:,1)),1,'last');

figure('name','Lower-limbs')
sides = {'Right','Left'};

for i = 1:length(sides)
    side = sides{i};
    s = side(1);
    
    if strcmp(side,'Left')
        offset= 4;
    else
        offset = 0;
    end
    
    subplot(3,8,1+offset);
    plot(data.([s,'PelvisAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'PelvisAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Pelvis'],'FontSize',FontSize,'FontName',FontName)
    if i==1
        ylabel({'Sagittal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
    end
    axis('square')
    set(gca,'tag','RPelvisAnglesSagittal')
    
    subplot(3,8,9+offset);
    plot(data.([s,'PelvisAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'PelvisAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    if i==1
        ylabel({'Coronal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
    end
    axis('square')
    set(gca,'tag','RPelvisAnglesCoronal')
    
    subplot(3,8,17+offset);
    plot(data.([s,'PelvisAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'PelvisAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    if i==1
        ylabel({'Transverse','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
    end
    axis('square')
    set(gca,'tag','RPelvisAnglesTransverse')
    
    subplot(3,8,2+offset);
    plot(data.([s,'HipAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
    hold on
    plot(data.([side,'HipAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Hip'],'FontSize',FontSize,'FontName',FontName)
    axis('square')
    set(gca,'tag','HipAnglesSagittal')
    
    subplot(3,8,3+offset);
    plot(data.([s,'KneeAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'KneeAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Knee'],'FontSize',FontSize,'FontName',FontName)
    axis('square')
    set(gca,'tag','KneeAnglesSagittal')
    
    subplot(3,8,4+offset);
    plot(data.([s,'AnkleAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'AnkleAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    title([s,'Ankle'],'FontSize',FontSize,'FontName',FontName)
    axis('square')
    set(gca,'tag','AnkleAnglesSagittal')
    
    subplot(3,8,10+offset);
    plot(data.([s,'HipAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'HipAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','HipAnglesCoronal')
    
    subplot(3,8,11+offset);
    plot(data.([s,'KneeAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'KneeAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','KneeAnglesCoronal')
    
    
    subplot(3,8,12+offset);
    plot(data.([s,'AnkleAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'AnkleAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    xlim([0 dlength])
    
    subplot(3,8,18+offset);
    plot(data.([s,'HipAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'HipAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','HipAnglesTransverse')
    
    subplot(3,8,19+offset);
    plot(data.([s,'KneeAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'KneeAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    set(gca,'tag','KneeAnglesTransverse')
    
    subplot(3,8,20+offset);
    plot(data.([s,'AnkleAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
    hold on
    plot(data.([side,'AnkleAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
    axis('square')
    xlim([0 dlength])
    
    if i==2
        legend('Vicon','BiomechZoo')
    end
    
    ax = findobj('type','axes');
    for j = 1:length(ax)
        set(ax(j),'XLim',[0 dlength]);
    end
    
end


if ismember('RThoraxAngles',fieldnames(data)) ||...
        ismember('RHeadAngles',fieldnames(data))
    figure('name','Upperbody')
    
    for i = 1:length(sides)
        side = sides{i};
        s = side(1);
        
        if strcmp(side,'Left')
            offset= 3;
        else
            offset = 0;
        end
        
        % for upper body angles
        
        subplot(3,6,1+offset);
        plot(data.([s,'PelvisAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
        hold on
        plot(data.([side,'PelvisAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        title([s,'Pelvis'],'FontSize',FontSize,'FontName',FontName)
        ylabel({'Sagittal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
        axis('square')
        set(gca,'tag',[side,'PelvisAnglesSagittal'])
        
        subplot(3,6,7+offset);
        plot(data.([s,'PelvisAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
        hold on
        plot(data.([side,'PelvisAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        ylabel({'Coronal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
        axis('square')
        set(gca,'tag',[side,'PelvisAnglesCoronal'])
        
        
        subplot(3,6,13+offset);
        plot(data.([s,'PelvisAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
        hold on
        plot(data.([side,'PelvisAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        ylabel({'Transverse','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
        axis('square')
        set(gca,'tag',[side,'PelvisAnglesTransverse'])
        
        if isfield(data,[s,'ThoraxAngles'])
            subplot(3,6,2+offset);
            plot(data.([s,'ThoraxAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.([side,'ThoraxAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
            title([s,'Thorax'],'FontSize',FontSize,'FontName',FontName)
            axis('square')
            set(gca,'tag','ThoraxAnglesSagittal')
            
            subplot(3,6,8+offset);
            plot(data.([s,'ThoraxAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.([side,'ThoraxAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
            ylabel({'Coronal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            set(gca,'tag',[side,'ThoraxAnglesCoronal'])
            
            subplot(3,6,14+offset);
            plot(data.([s,'ThoraxAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.([side,'ThoraxAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
            ylabel({'Transverse','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            set(gca,'tag',[side,'ThoraxAnglesTransverse'])
        end
        
        if isfield(data,[s,'HeadAngles'])
            subplot(3,6,3+offset);
            plot(data.([s,'HeadAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.([side,'HeadAngle_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
            title([s,'Head'],'FontSize',FontSize,'FontName',FontName)
            axis('square')
            set(gca,'tag',[side,'HeadAnglesSagittal'])
            
            subplot(3,6,9+offset);
            plot(data.([s,'HeadAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.([side,'HeadAngle_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
            ylabel({'Coronal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            set(gca,'tag',[side,'HeadAnglesCoronal'])
            
            subplot(3,6,15+offset);
            plot(data.([s,'HeadAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.([side,'HeadAngle_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
            ylabel({'Transverse','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            set(gca,'tag',[side,'HeadAnglesTransverse'])
        end
        
        if i==2
            legend('Vicon','BiomechZoo')
        end
        
        ax = findobj('type','axes');
        for j = 1:length(ax)
            set(ax(j),'XLim',[0 dlength]);
        end
        
    end
    
end


if isfield(data,[side(1),'HFTBA'])  % OFM is included
    
    figure('name','multi-segment foot OFM')
    
    sides = {'Right','Left'};
    for i = 1:length(sides)
        side = sides{i};
        s = side(1);
        
        if strcmp(side,'Left')
            offset= 3;
        else
            offset = 0;
        end
        
        subplot(3,6,offset+1);
        plot(data.([s,'HFTBA']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HFTBA_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        title([s,'HF/TB'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        
        if i==1
            ylabel({'Sagittal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
        end
        
        
        subplot(3,6,offset+2);
        plot(data.([s,'FFHFA']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'FFHFA_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        title([s,'FF/HF'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        
        subplot(3,6,offset+3);
        plot(data.([s,'HXFFA']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HXFFA_x']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        title([s,'HX/FF'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        
        
        subplot(3,6,offset+7);
        plot(data.([s,'HFTBA']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HFTBA_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
        if i==1
            ylabel({'Coronal','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
        end
        
        
        subplot(3,6,offset+8);
        plot(data.([s,'FFHFA']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'FFHFA_z']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
        subplot(3,6,offset+9);
        plot(data.([s,'HXFFA']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HXFFA_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
        subplot(3,6,offset+13);
        plot(data.([s,'HFTBA']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HFTBA_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
        if i==1
            ylabel({'Transverse','Angles','(deg)'},'FontSize',FontSize,'FontName',FontName)
        end
        
        subplot(3,6,offset+14);
        plot(data.([s,'FFHFA']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'FFHFA_y']).line,'Color',zcol,'LineStyle',zstyle,'LineWidth',LineWidth)
        axis('square')
        
    end
    
    legend('ViconOFM','biomechZoo')
    
end




