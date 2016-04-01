function [KIN,data,ERR] = vicon2groodsuntay(varargin)

% [KIN,data,ERR] = vicon2groodsuntay(varargin) computes lower-limb joint angles
% based on Grood and Suntay method
%
%
% ARGUMENTS
% data     ...  zoo data containing all oxford foot model output channels
% check    ...  check results against oxford. Default 'yes'
% display  ...  display results. Default is 'no'
% graph    ...  graph results as visual check
% demo     ...  runs in demo mode. choose 'Aschau','McGill','OGL' e.g. vicon2groodsuntay('demo','Aschau')
%
%
% RETURNS
% KIN     ...   structured array containing Grood and Suntay computed channels
% data    ...   zoo data with additional Grood and Suntay computed channels
%              included
% ERR     ...   structured array containing RMS error values for each angle
%
%
% NOTES:
%
% - It is now anatomically implausible for the vectors to flip during
%   walking but may be possible for running - A correction has been implemented at the knee, but might require future update
% - For PiG choice of axes for angle computation based on detailed work of
%   Vaughan (Dynamics of Human Gait Appendix B p94-96). This is the Grood
%   and Suntay method.
% - For OFM choice based on trial and error. Find out what rotation matrix
%   is used for OFM
%
%
%
%
% SUMMARY OF CALCULATIONS
%
% floating axis (PIG) = cross(lat_prox , long_dist)
% floating axis (OFM) = cross(ant_dist , lat_prox );
%
% Hip & Knee
% flx = asind(dot(floatax,long_prox,2));
% abd = asind(dot(lat_prox,long_dist,2));
% tw  = asind(dot(floatax,lat_dist,2));
%
% Ankle PiG
% flx = asind(dot(floatax,ant_prox,2)); % chosen to avoid axis flipping
% abd = asind(dot(lat_prox,long_dist,2));
% tw  = asind(dot(floatax,lat_dist,2));
%
% HF/TB (OFM)
% flx = angle(floatax,long_prox);
% abd = angle(lat_prox,ant_dist);
% tw  = angle(floatax,lat_dist);
%
% FF/HF and HLX/FF (OFM)
% flx = angle(floatax,ant_prox);        % plantar/ dorsi
% abd = angle(lat_prox,ant_dist);         % int / ext
% tw  = angle(floatax,lat_dist);     % pro / suppination
%
%
%
% REFERENCE SYSTEM
% - angles are then flipped to match outpout of Vicon
%
%
%
%
%
% Created by Phil Dixon 2008
%
% Updated January 2011
% - tested against vicon output 100% match for both PIG and OFM
% - grood and suntay calculations occur in embedded function 'groodsuntay'
%
% Updated September 2012
% - possibility to graph results as a visual check
% - added abd/add of hallux segment
% - added simple demo mode
% - calculations simplified
% - only reference frame is Vicon
% - correction for axis flipping at the knee implemented
%
%
%
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008-2012
% Philippe C. Dixon




%---DEFAULT SETTINGS---
%
demo = [];
check = 'yes';
display = 'no';
ref = 'vicon';
graph = 'no';

%---USER DEFINED SETTINGS----

for i = 1:2:nargin
    
    switch varargin{i}
        case 'data'
            data = varargin{i+1};
            
        case 'display'
            display = varargin{i+1};
            
        case 'check'
            check = varargin{i+1};
            
        case 'ref'
            ref = varargin{i+1};
            
        case 'graph'
            graph = varargin{i+1};
            
        case 'demo'
            demo  = varargin{i+1};
            
    end
end


if  ~isempty(demo);
    check = 'yes';
    display = 'yes';
    graph = 'yes';
    
    p = which('vicon2groodsuntay');
    s = slash;
    indx = strfind(p,s);
    p = p(1:indx(end));
    
    switch demo
        
        case 'Aschau'
            f = 'aschau';
            
        case 'McGill'
            disp('this trial shows possible axis flipping during running')
            f = 'mcgill';
            
        case 'OGL'
            disp('this trial shows error based on different processing at OGL')
            f = 'ogl';
    end
    
    data = zload([p,f,'.zoo']);
end

if ~isempty(strfind(display,'yes'))
    check = 'yes';
end


if ~isempty(strfind(check,'no')) && ~isempty(strfind(display,'yes'))
    disp('you cannot display results of comparisions if you have opted not to check the error')
end


%----1 : MAKE BONES FROM MARKER COORDINATES-------------
%
% - This function uses marker data to create new channels defining joint centers (incomplete)
% - If the OFM model was run, you can use the outputted virtual markers instead
%
% data=makebones(data);


%----2 : GET BONES---------------------
%
% collect bones into appropriate format
[pgbone,oxbone,jnt,data] = getbones(data);



%----3: PREPARE DATA FOR GROOD AND SUNTAY CALCULATIONS
%
oxdim = {'0','1','2','3'};
% 0 is origin of bone (zero)
% 1 is anterior vector
% 2 is medial (right) or lateral(left) vector
% 3 is long axis of bone vector (pointing distally)

pgdim = {'O','A','L','P'};
% O is origin of bone, at distal joint (letter O)
% A is an anterior vector from bone
% L is medial( right) or lateral (left) vector
% P is long axis of bone vector (pointing proximally)


for i = 1:length(pgbone(:,1))
    d = [];
    
    for j = 1:4
        d{j} = data.([pgbone{i,1},pgdim{j}]).line;
    end
    
    bn = pgbone{i,2};
    ort = getdatapg(d);
    r.(bn).ort = ort;
end


if ~isempty(oxbone)
    
    for i = 1:length(oxbone(:,1))
        d = [];
        
        for j = 1:4
            d{j} = data.([oxbone{i,1},oxdim{j}]).line;
        end
        
        bn = oxbone{i,2};
        ort = getdataox(d);
        r.(bn).ort = ort;
    end
    
end

%----4: COMPUTE JOINT ANGLES ACCORDING TO GROOD AND SUNTAY------------
%
KIN = get_grood_suntay(r,jnt);


%----5: FIX REFERENCE SYSTEM TO MATCH CLINICAL-------
%
% - rename channels to match the oxford names
KIN = refsystem(KIN);


%----6: CHECK ACCURACY OF CALCULATIONS AGAINST ORIGINAL VICON DATA (DISPLAY OPTIONAL)
%
ERR=checkvicon(KIN,data,check,display);


%----7: ADD COMPUTED ANGLES TO DATA STRUCT
%
data = addchannelsgs(data,KIN,ERR);

%----8: IMPLEMENT A GRAPHICAL CHECK AGAINST ORIGINAL VICON DATA (OPTIONAL)
%
graphresults(data,graph)


%=================EMBEDDED FUNCTIONS============


function ort = getdataox(d)

% For HF, FF, HX these are correct axes, for TB x and z are interchanged.
% This is accounted for in groodsuntay.m

z = (d{2}-d{1})/10;   % Anterior - Origin:          Creates anterior vector
y = (d{3}-d{1})/10;   % Medial - Origin:            Creates medial vector (right side), Lateral vector (left side)
x = (d{4}-d{1})/10;   % Distal - Origin:            Creates vector along long axis of bone

rw = size(x);
ort = [];
for i = 1:rw
    ort = [ort;{[x(i,:);y(i,:);z(i,:)]}]; %for updated grood suntay version
end



function ort = getdatapg(d)

% data comes in as O,A,L,P
O = 1;
A = 2;
L = 3;
P = 4;

x = (d{A}-d{O})/10;   % Anterior - Origin:          Creates anterior vector
y = (d{L}-d{O})/10;   % Medial - Origin:            Creates medial vector (right side), Lateral vector (left side)
z = (d{P}-d{O})/10;   % Distal - Origin:            Creates vector along long axis of bone

rw = size(x);
ort = [];
for i = 1:rw
    ort = [ort;{[x(i,:);y(i,:);z(i,:)]}]; %for updated grood suntay version
end



% function KIN = get_grood_suntay(r,jnt,data)
function KIN = get_grood_suntay(r,jnt)


% alpha goes into flx
% beta goes into abd
% gamma goes into IntExt

for i = 1:length(jnt(:,1))
    [KIN.(jnt{i,1}).flx,KIN.(jnt{i,1}).abd,KIN.(jnt{i,1}).tw] = groodsuntay(r,jnt(i,1:end));
end


function [flx,abd,tw] = groodsuntay(r,jnt)


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
    
    
    case {'Pelvis','Femur'}  % Hip and Knee
        
        [floatax,~,~,lat_prox,lat_dist,long_prox,long_dist] = makeax(pax,dax);
        
        %         flx = angle(floatax,long_prox);  % this is actually incorrect but can be fixed by offset
        %         abd = angle(lat_prox,long_dist);
        %         tw  = angle(floatax,lat_dist);
        
        flx = asind(dot(floatax,long_prox,2));
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
        
        flx = checkflippg(flx,floatax,long_prox);
        
    case 'TibiaPG'    % Ankle PG angles
        
        [floatax,ant_prox,~,lat_prox,lat_dist,~,long_dist] = makeax(pax,dax);
        
        flx = asind(dot(floatax,ant_prox,2)); % chosen to avoid axis flipping
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
        
    case {'TibiaOFM'}   % hindfoot tibia angle
        
        [floatax,~,ant_dist,lat_prox,lat_dist,long_prox] = makeaxox(pax,dax);
        
        flx = angle(floatax,long_prox);        % plantar/ dorsi
        abd = angle(lat_prox,ant_dist);        % inv / eve
        tw  = angle(floatax,lat_dist);         % int / ext
        
    case {'HindFoot','ForeFoot'}  % forefoot hindfoot angle
        
        [floatax,ant_prox,ant_dist,lat_prox,lat_dist] = makeaxox(pax,dax);
        
        flx = angle(floatax,ant_prox);        % plantar/ dorsi
        abd = angle(lat_prox,ant_dist);       % int / ext
        tw  = angle(floatax,lat_dist);        % pro / suppination
        
end



function [floatax,ant_prox,ant_dist,lat_prox,lat_dist,long_prox,long_dist] = makeax(pax,dax)

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


function [floatax,ant_prox,ant_dist,lat_prox,lat_dist,long_prox] = makeaxox(pax,dax)

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



function flx = checkflippg(flx,float,long_prox)

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
    
    
    r.RightAnklePG.PlaDor = -KIN.RightAnklePG.flx;
    r.RightAnklePG.IntExt = -KIN.RightAnklePG.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightAnklePG.InvEve = -KIN.RightAnklePG.tw;
    
    r.LeftAnklePG.PlaDor = -KIN.LeftAnklePG.flx;
    r.LeftAnklePG.IntExt = KIN.LeftAnklePG.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftAnklePG.InvEve = KIN.LeftAnklePG.tw;
    
    
end


if isfield(KIN,'RightMidFoot')  % checks for oxford
    
    %Right Ankle (HindFoot relative to Tibia)
    r.RightAnkleOFM.PlaDor = -KIN.RightAnkleOFM.flx+90;
    r.RightAnkleOFM.InvEve = -KIN.RightAnkleOFM.abd+90;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightAnkleOFM.IntExt = KIN.RightAnkleOFM.tw-90;
    
    % 'LeftAnkleOFM'   % HindFoot relative to Tibia
    r.LeftAnkleOFM.PlaDor = -KIN.LeftAnkleOFM.flx+90;
    r.LeftAnkleOFM.InvEve = KIN.LeftAnkleOFM.abd-90;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftAnkleOFM.IntExt = -KIN.LeftAnkleOFM.tw+90;
    
    %'RightMidFoot'   % Forefoot relative to Hindfoot
    r.RightMidFoot.PlaDor = -KIN.RightMidFoot.flx+90;
    r.RightMidFoot.SupPro = -KIN.RightMidFoot.abd+90;
    r.RightMidFoot.AbdAdd = KIN.RightMidFoot.tw-90;
    
    % 'LeftMidFoot'   % Forefoot relative to Hindfoot
    r.LeftMidFoot.PlaDor = -KIN.LeftMidFoot.flx+90;
    r.LeftMidFoot.SupPro = KIN.LeftMidFoot.abd-90;
    r.LeftMidFoot.AbdAdd = -KIN.LeftMidFoot.tw+90;
    
    % 'RightMTP'       % Hallux relative to Forefoot
    r.RightMTP.PlaDor = -KIN.RightMTP.flx+90;
    r.RightMTP.AbdAdd = -KIN.RightMTP.abd+90;
    
    % 'LeftMTP'          % Hallux relative to Forefoot
    r.LeftMTP.PlaDor = -KIN.LeftMTP.flx+90;
    r.LeftMTP.AbdAdd = KIN.LeftMTP.abd-90;
    
end



function data = addchannelsgs(data,KIN,ERR)


% add plugingait channels---

% dch = {'Rhip','Rknee','RanklePG','Lhip','Lknee','LanklePG'};
kch = {'RightHip','RightKnee','RightAnklePG','LeftHip','LeftKnee','LeftAnklePG'};

for i = 1:length(kch)
    
    dsub = {'x','y','z'};
    ksub = {'FlxExt','AbdAdd','IntExt'};
    asub = {'PlaDor','InvEve','IntExt'};
    
    for j = 1:length(dsub)
        
        if ~isempty(strfind(kch{i},'Ankle'))
            data.([kch{i},'_',dsub{j}]).line = KIN.(kch{i}).(asub{j});
            data.([kch{i},'_',dsub{j}]).event = struct;
            
            if ~isempty(ERR)
                data.([kch{i},'_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(asub{j}).RMS 0];
            end
            
        else
            data.([kch{i},'_',dsub{j}]).line = KIN.(kch{i}).(ksub{j});
            data.([kch{i},'_',dsub{j}]).event = struct;
            
            if ~isempty(ERR)
                data.([kch{i},'_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(ksub{j}).RMS 0];
            end
        end
    end
end

%--- add OFM angles


if isfield(KIN,'RightAnkleOFM')
    
    data.Rhftba_x.line = KIN.RightAnkleOFM.PlaDor;
    data.Rhftba_x.event = struct;
    
    data.Rhftba_y.line = KIN.RightAnkleOFM.InvEve;
    data.Rhftba_y.event = struct;
    
    data.Rhftba_z.line = KIN.RightAnkleOFM.IntExt;
    data.Rhftba_z.event = struct;
    
    data.Rffhfa_x.line = KIN.RightMidFoot.PlaDor;
    data.Rffhfa_x.event = struct;
    
    data.Rffhfa_z.line = KIN.RightMidFoot.AbdAdd;
    data.Rffhfa_z.event = struct;
    
    data.Rffhfa_y.line = KIN.RightMidFoot.SupPro;
    data.Rffhfa_y.event = struct;
    
    data.Rhxffa_x.line = KIN.RightMTP.PlaDor;
    data.Rhxffa_x.event = struct;
    
    data.Rhxffa_y.line = KIN.RightMTP.AbdAdd;
    data.Rhxffa_y.event = struct;
    
    %--left---
    
    data.Lhftba_x.line = KIN.LeftAnkleOFM.PlaDor;
    data.Lhftba_x.event = struct;
    
    data.Lhftba_y.line = KIN.LeftAnkleOFM.InvEve;
    data.Lhftba_y.event = struct;
    
    data.Lhftba_z.line = KIN.LeftAnkleOFM.IntExt;
    data.Lhftba_z.event = struct;
    
    data.Lffhfa_x.line = KIN.LeftMidFoot.PlaDor;
    data.Lffhfa_x.event = struct;
    
    data.Lffhfa_z.line = KIN.LeftMidFoot.AbdAdd;
    data.Lffhfa_z.event = struct;
    
    data.Lffhfa_y.line = KIN.LeftMidFoot.SupPro;
    data.Lffhfa_y.event = struct;
    
    data.Lhxffa_x.line = KIN.LeftMTP.PlaDor;
    data.Lhxffa_x.event = struct;
    
    data.Lhxffa_y.line = KIN.LeftMTP.AbdAdd;
    data.Lhxffa_y.event = struct;
    
    if ~isempty(ERR)
        
        data.Rhftba_x.event.rms = [1 ERR.RightAnkleOFM.PlaDor.RMS 0];
        data.Rhftba_y.event.rms = [1 ERR.RightAnkleOFM.InvEve.RMS 0];
        data.Rhftba_z.event.rms = [1 ERR.RightAnkleOFM.IntExt.RMS 0];
        
        data.Rffhfa_x.event.rms = [1 ERR.RightMidFoot.PlaDor.RMS 0];
        data.Rffhfa_z.event.rms = [1 ERR.RightMidFoot.AbdAdd.RMS 0];
        data.Rffhfa_y.event.rms = [1 ERR.RightMidFoot.SupPro.RMS 0];
        
        data.Rhxffa_x.event.rms = [1 ERR.RightMTP.PlaDor.RMS 0];
        
        data.Lhftba_x.event.rms = [1 ERR.LeftAnkleOFM.PlaDor.RMS 0];
        data.Lhftba_y.event.rms = [1 ERR.LeftAnkleOFM.InvEve.RMS 0];
        data.Lhftba_z.event.rms = [1 ERR.LeftAnkleOFM.IntExt.RMS 0];
        
        data.Lffhfa_x.event.rms = [1 ERR.LeftMidFoot.PlaDor.RMS 0];
        data.Lffhfa_z.event.rms = [1 ERR.LeftMidFoot.AbdAdd.RMS 0];
        data.Lffhfa_y.event.rms = [1 ERR.LeftMidFoot.SupPro.RMS 0];
        
        data.Lhxffa_x.event.rms = [1 ERR.LeftMTP.PlaDor.RMS 0];
        
    end
    
    
end
%------------CHECK ACCURACY OF RESULTS--------

function ERR=checkvicon(KIN,data,check,display)



if strcmp(check,'no')
    ERR = '';
    return
    
else
    
    if isfield(data,'RHDF1')   % if oxford outputs are present
        ERR1= ofxcheck(KIN,data,display);
        ch1 = fieldnames(ERR1);
        for i = 1:length(ch1)
            ERR.(ch1{i}) = ERR1.(ch1{i});
        end
        
    end
    
    if isfield(data,'RFEO')
        ERR2= pgcheck(KIN,data,display);
        ch2 = fieldnames(ERR2);
        
        for j = 1:length(ch2)
            ERR.(ch2{j}) = ERR2.(ch2{j});
        end
        
    end
    
end










function ERR= ofxcheck(KIN,data,display)

RMFstk = [];
RMTPstk = [];
RAstk = [];

LMFstk = [];
LMTPstk = [];
LAstk = [];

subch = {'PlaDor','InvEve','IntExt'}; % Ankle angle

for k = 1:3
    RAplate=sqrt(sum(nansum((data.RHFTBA.line(:,k)-KIN.RightAnkleOFM.(subch{k})).^2))/numel(~isnan(data.RHFTBA.line(:,k))));
    RAstk = [RAstk RAplate];
    
    LAplate=sqrt(sum(nansum((data.LHFTBA.line(:,k)-KIN.LeftAnkleOFM.(subch{k})).^2))/numel(~isnan(data.LHFTBA.line(:,k))));
    LAstk = [LAstk LAplate];
end

subcha = {'PlaDor','SupPro','AbdAdd'};  % MidFoot angle

for k = 1:3
    RMFplate=sqrt(sum(nansum((data.RFFHFA.line(:,k)-KIN.RightMidFoot.(subcha{k})).^2))/numel(~isnan(data.RFFHFA.line(:,k))));
    RMFstk = [RMFstk RMFplate];
    
    LMFplate=sqrt(sum(nansum((data.LFFHFA.line(:,k)-KIN.LeftMidFoot.(subcha{k})).^2))/numel(~isnan(data.LFFHFA.line(:,k))));
    LMFstk = [LMFstk LMFplate];
end

subcha = {'PlaDor'};  % MTP angle
k=1;

RMTPplate=sqrt(sum(nansum((data.RHXFFA.line(:,k)-KIN.RightMTP.(subcha{k})).^2))/numel(~isnan(data.RHXFFA.line(:,k))));
RMTPstk = [RMTPstk RMTPplate];

LMTPplate=sqrt(sum(nansum((data.LHXFFA.line(:,k)-KIN.LeftMTP.(subcha{k})).^2))/numel(~isnan(data.LHXFFA.line(:,k))));
LMTPstk = [LMTPstk LMTPplate];



ERR.RightAnkleOFM.PlaDor.RMS=RAstk(1);
ERR.RightAnkleOFM.InvEve.RMS=RAstk(2);
ERR.RightAnkleOFM.IntExt.RMS=RAstk(3);

ERR.RightMidFoot.PlaDor.RMS=RMFstk(1);
ERR.RightMidFoot.SupPro.RMS=RMFstk(2);
ERR.RightMidFoot.AbdAdd.RMS=RMFstk(3);

ERR.RightMTP.PlaDor.RMS=RMTPstk;

ERR.LeftAnkleOFM.PlaDor.RMS=LAstk(1);
ERR.LeftAnkleOFM.InvEve.RMS=LAstk(2);
ERR.LeftAnkleOFM.IntExt.RMS=LAstk(3);

ERR.LeftMidFoot.PlaDor.RMS=LMFstk(1);
ERR.LeftMidFoot.SupPro.RMS=LMFstk(2);
ERR.LeftMidFoot.AbdAdd.RMS=LMFstk(3);

ERR.LeftMTP.PlaDor.RMS=LMTPstk;


if strcmp(display,'yes')
    
    %------------DISP RESULTS-------------------
    
    disp('Root Mean Square Error Table (RMSE) for comparison of Vicon and Grood and Suntay OFM angles')
    fprintf('---------------------------------------------------------------------------\n');
    disp('Angle                         RMSE')
    fprintf('---------------------------------------------------------------------------\n');
    
    fprintf('RightAnkleOFMPlaDor   %11.3f%10i%15.3f\n\n',RAstk(1));
    fprintf('\n')
    fprintf('RightAnkleOFMInvEve   %11.3f%10i%15.3f\n\n',RAstk(2));
    fprintf('\n')
    fprintf('RightAnkleOFMIntExt   %11.3f%10i%15.3f\n\n',RAstk(3));
    fprintf('\n')
    
    fprintf('RightMidFootFlxExt    %11.3f%10i%15.3f\n\n',RMFstk(1));
    fprintf('\n')
    fprintf('RightMidFootSupPro    %11.3f%10i%15.3f\n\n',RMFstk(2));
    fprintf('\n')
    fprintf('RightMidFootAbdAdd    %11.3f%10i%15.3f\n\n',RMFstk(3));
    fprintf('\n')
    
    fprintf('RightMTPPlaDor        %11.3f%10i%15.3f\n\n',RMTPstk(1));
    fprintf('\n')
    
    disp(' ')
    
    fprintf('LeftAnkleOFMPlaDor    %11.3f%10i%15.3f\n\n',LAstk(1));
    fprintf('\n')
    fprintf('LeftAnkleOFMInvEve    %11.3f%10i%15.3f\n\n',LAstk(2));
    fprintf('\n')
    fprintf('LeftAnkleOFMIntExt    %11.3f%10i%15.3f\n\n',LAstk(3));
    fprintf('\n')
    
    
    fprintf('LeftMidFootPlaDor     %11.3f%10i%15.3f\n\n',LMFstk(1));
    fprintf('\n')
    fprintf('LeftMidFootSupPro     %11.3f%10i%15.3f\n\n',LMFstk(2));
    fprintf('\n')
    fprintf('LeftMidFootAbdAdd     %11.3f%10i%15.3f\n\n',LMFstk(3));
    fprintf('\n')
    
    fprintf('LeftMTPPlaDor         %11.3f%10i%15.3f\n\n',LMTPstk(1));
    fprintf('\n')
    
    disp(' ')
    disp('Note: MTP joint only contains sagittal plane motion')
    
end



function ERR= pgcheck(KIN,data,display)

LHstk = [];
LKstk = [];
LAstk = [];
RHstk = [];
RKstk = [];
RAstk = [];

subch = {'FlxExt','AbdAdd','IntExt'};

for k = 1:3
    LHPlate=sqrt(sum(nansum((data.LHipAngles.line(:,k)-KIN.LeftHip.(subch{k})).^2))/numel(~isnan(data.LHipAngles.line(:,k))));
    LKPlate=sqrt(sum(nansum((data.LKneeAngles.line(:,k)-KIN.LeftKnee.(subch{k})).^2))/numel(~isnan(data.LKneeAngles.line(:,k))));
    RHPlate=sqrt(sum(nansum((data.RHipAngles.line(:,k)-KIN.RightHip.(subch{k})).^2))/numel(~isnan(data.RHipAngles.line(:,k))));
    RKPlate=sqrt(sum(nansum((data.RKneeAngles.line(:,k)-KIN.RightKnee.(subch{k})).^2))/numel(~isnan(data.RKneeAngles.line(:,k))));
    LHstk = [LHstk LHPlate];
    LKstk = [LKstk LKPlate];
    RHstk = [RHstk RHPlate];
    RKstk = [RKstk RKPlate];
end

subcha = {'PlaDor','InvEve','IntExt',};

for k = 1:3
    LAPlate=sqrt(sum(nansum((data.LAnkleAngles.line(:,k)-KIN.LeftAnklePG.(subcha{k})).^2))/numel(~isnan(data.LAnkleAngles.line(:,k))));
    RAPlate=sqrt(sum(nansum((data.RAnkleAngles.line(:,k)-KIN.RightAnklePG.(subcha{k})).^2))/numel(~isnan(data.RAnkleAngles.line(:,k))));
    LAstk = [LAstk LAPlate];
    RAstk = [RAstk RAPlate];
end


ERR.RightAnklePG.PlaDor.RMS=RAstk(1);
ERR.RightAnklePG.IntExt.RMS=RAstk(2);
ERR.RightAnklePG.InvEve.RMS=RAstk(3);

ERR.RightKnee.FlxExt.RMS=RKstk(1);
ERR.RightKnee.AbdAdd.RMS=RKstk(2);
ERR.RightKnee.IntExt.RMS=RKstk(3);

ERR.RightHip.FlxExt.RMS=RHstk(1);
ERR.RightHip.AbdAdd.RMS=RHstk(2);
ERR.RightHip.IntExt.RMS=RHstk(3);

ERR.LeftAnklePG.PlaDor.RMS=LAstk(1);
ERR.LeftAnklePG.IntExt.RMS=LAstk(2);
ERR.LeftAnklePG.InvEve.RMS=LAstk(3);

ERR.LeftKnee.FlxExt.RMS=LKstk(1);
ERR.LeftKnee.AbdAdd.RMS=LKstk(2);
ERR.LeftKnee.IntExt.RMS=LKstk(3);

ERR.LeftHip.FlxExt.RMS=LHstk(1);
ERR.LeftHip.AbdAdd.RMS=LHstk(2);
ERR.LeftHip.IntExt.RMS=LHstk(3);


if strcmp(display,'yes')
    
    %------------DISP RESULTS-------------------
    disp(' ')
    disp(' ')
    disp(' ')
    disp(' ')
    disp(' ')
    
    disp('Root Mean Square Error Table (RMSE) for comparison of Vicon and Grood and Suntay PIG angles')
    fprintf('---------------------------------------------------------------------------\n');
    disp('Angle                         RMSE')
    fprintf('---------------------------------------------------------------------------\n');
    
    fprintf('RightHipFlxExt        %11.3f%10i%15.3f\n\n',RHstk(1));
    fprintf('\n')
    fprintf('RightHipAbdAdd        %11.3f%10i%15.3f\n\n',RHstk(2));
    fprintf('\n')
    fprintf('RightHipIntExt        %11.3f%10i%15.3f\n\n',RHstk(3));
    fprintf('\n')
    
    fprintf('RightKneeFlxExt       %11.3f%10i%15.3f\n\n',RKstk(1));
    fprintf('\n')
    fprintf('RightKneeAbdAdd       %11.3f%10i%15.3f\n\n',RKstk(2));
    fprintf('\n')
    fprintf('RightKneeIntExt       %11.3f%10i%15.3f\n\n',RKstk(3));
    fprintf('\n')
    
    
    fprintf('RightAnklePlaDor      %11.3f%10i%15.3f\n\n',RAstk(1));
    fprintf('\n')
    fprintf('RightAnkleIntExt      %11.3f%10i%15.3f\n\n',RAstk(2));
    fprintf('\n')
    fprintf('RightAnkleInvEve      %11.3f%10i%15.3f\n\n',RAstk(3));
    fprintf('\n')
    
    disp(' ')
    
    fprintf('LeftHipFlxExt         %11.3f%10i%15.3f\n\n',LHstk(1));
    fprintf('\n')
    fprintf('LeftHipAbdAdd         %11.3f%10i%15.3f\n\n',LHstk(2));
    fprintf('\n')
    fprintf('LeftHipIntExt         %11.3f%10i%15.3f\n\n',LHstk(3));
    fprintf('\n')
    
    
    fprintf('LeftKneeFlxExt        %11.3f%10i%15.3f\n\n',LKstk(1));
    fprintf('\n')
    fprintf('LeftKneeAbdAdd        %11.3f%10i%15.3f\n\n',LKstk(2));
    fprintf('\n')
    fprintf('LeftKneeIntExt        %11.3f%10i%15.3f\n\n',LKstk(3));
    fprintf('\n')
    
    
    fprintf('LeftAnklePlaDor       %11.3f%10i%15.3f\n\n',LAstk(1));
    fprintf('\n')
    fprintf('LeftAnkleIntExt       %11.3f%10i%15.3f\n\n',LAstk(2));
    fprintf('\n')
    fprintf('LeftAnkleInvEve       %11.3f%10i%15.3f\n\n',LAstk(3));
    fprintf('\n')
    
    
    
    
    
    
    
end



%
%
% if strcmp(displaywrong,'yes')
%
%     v = 0.0001;
%     %------------DISP RESULTS-------------------
%     if RHstk(1) > v
%         fprintf('RightHipFlxExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RHstk(1));
%         fprintf('\n')
%
%     elseif RHstk(2) >v
%         fprintf('RightHipAbdAdd differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RHstk(2));
%         fprintf('\n')
%
%     elseif RHstk(3) >v
%         fprintf('RightHipIntExt differs from vicon, RMS difference =%11.3f%10i%15.3f\n\n',RHstk(3));
%         fprintf('\n')
%
%     elseif RKstk(1) >v
%         fprintf('RightKneeFlxExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RKstk(1));
%         fprintf('\n')
%     elseif RKstk(2) >v
%         fprintf('RightKneeAbdAdd differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RKstk(2));
%         fprintf('\n')
%     elseif RKstk(3) >v
%         fprintf('RightKneeIntExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RKstk(3));
%         fprintf('\n')
%
%     elseif RAstk(1) >v
%
%         fprintf('RightAnklePlaDor differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RAstk(1));
%         fprintf('\n')
%
%     elseif RAstk(2) >v
%         fprintf('RightAnkleIntExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',RAstk(2));
%         fprintf('\n')
%     elseif RAstk(3) >v
%         fprintf('RightAnkleInvEve differs from vicon, RMS difference =  %11.3f%10i%15.3f\n\n',RAstk(3));
%         fprintf('\n')
%
%     elseif LHstk(1) > v
%         fprintf('LeftHipFlxExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LHstk(1));
%         fprintf('\n')
%
%     elseif LHstk(2) >v
%         fprintf('LeftHipAbdAdd differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LHstk(2));
%         fprintf('\n')
%
%     elseif LHstk(3) >v
%         fprintf('LeftHipIntExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LHstk(3));
%         fprintf('\n')
%
%     elseif LKstk(1) >v
%         fprintf('LeftKneeFlxExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LKstk(1));
%         fprintf('\n')
%     elseif LKstk(2) >v
%         fprintf('LeftKneeAbdAdd differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LKstk(2));
%         fprintf('\n')
%     elseif LKstk(3) >v
%         fprintf('LeftKneeIntExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LKstk(3));
%         fprintf('\n')
%
%     elseif LAstk(1) >v
%
%         fprintf('LeftAnklePlaDor differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LAstk(1));
%         fprintf('\n')
%
%     elseif LAstk(2) >v
%         fprintf('LeftAnkleIntExt differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LAstk(2));
%         fprintf('\n')
%     elseif LAstk(3) >v
%         fprintf('LeftAnkleInvEve differs from vicon, RMS difference = %11.3f%10i%15.3f\n\n',LAstk(3));
%         fprintf('\n')
%
%     end
%
% end



function graphresults(data,graph)

if isin(graph,'yes')
    close all
    sz = get(0,'ScreenSize');
    w = sz(3);
    h = sz(4);
    
    sw = 0.1;  % width of subfigue
    sh = 0.1;
    
    row1 = 0.1; % shift all row 1 up 0.2 in ydir
    row2 = 0.25;
    row3 = 0.4;
    
    vcol = 'k';
    ccol = [0.23 0.44 0.34];
    
    vstyle = '-';
    cstyle = '--';
    LineWidth = 1.5;
    
    FontSize = 16;
    FontName = 'Arial';
    
    sides = {'Right','Left'};
    
    for i = 1:length(sides)
        side = sides{i};
        s = side(1);
        
        hnd = figure('Position',[200,50,0.6*w, 0.8*h]);  % Left Ankle Force, Moments, and Power
        set(hnd,'name',['Comparison of Vicon PiG and Grood and Suntay Angles ( ',side,')']); % Just having fun
        
        ax=subplot(3,6,1);
        plot(data.([s,'HipAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
        hold on
        plot(data.([side,'Hip_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        title([s,'Hip'],'FontSize',FontSize,'FontName',FontName)
        ylabel({'Sagittal','Angles (deg)'},'FontSize',FontSize,'FontName',FontName)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row1 sw sh]);
        
        
        ax=subplot(3,6,2);
        plot(data.([s,'KneeAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'Knee_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        title([s,'Knee'],'FontSize',FontSize,'FontName',FontName)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row1 sw sh]);
        
        ax=subplot(3,6,3);
        plot(data.([s,'AnkleAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnklePG_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        title([s,'Ankle'],'FontSize',FontSize,'FontName',FontName)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row1 sw sh]);
        
        ax=subplot(3,6,7);
        plot(data.([s,'HipAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'Hip_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        ylabel({'Coronal','Angles (deg)'},'FontSize',FontSize,'FontName',FontName)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row2 sw sh]);
        
        
        ax=subplot(3,6,8);
        plot(data.([s,'KneeAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'Knee_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row2 sw sh]);
        
        
        ax=subplot(3,6,9);
        plot(data.([s,'AnkleAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnklePG_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row2 sw sh]);
        
        ax=subplot(3,6,13);
        plot(data.([s,'HipAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'Hip_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        ylabel({'Transverse','Angles (deg)'},'FontSize',FontSize,'FontName',FontName)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row3 sw sh]);
        
        
        ax=subplot(3,6,14);
        plot(data.([s,'KneeAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'Knee_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row3 sw sh]);
        
        
        ax=subplot(3,6,15);
        plot(data.([s,'AnkleAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnklePG_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        p = get(ax,'position');
        set(ax,'position',[p(1) p(2)+row3 sw sh]);
        
        
        if isfield(data,[side(1),'HFTBA'])  % OFM is included
            
            ax=subplot(3,6,4);
            plot(data.([s,'HFTBA']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'hftba_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            title([s,'HF/TB'],'FontSize',FontSize,'FontName',FontName)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row1 sw sh]);
            
            
            ax=subplot(3,6,5);
            plot(data.([s,'FFHFA']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'ffhfa_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            title([s,'FF/HF'],'FontSize',FontSize,'FontName',FontName)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row1 sw sh]);
            
            ax=subplot(3,6,6);
            plot(data.([s,'HXFFA']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'hxffa_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            title([s,'HX/FF'],'FontSize',FontSize,'FontName',FontName)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row1 sw sh]);
            
            
            ax=subplot(3,6,10);
            plot(data.([s,'HFTBA']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'hftba_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row2 sw sh]);
            
            ax=subplot(3,6,11);
            plot(data.([s,'FFHFA']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'ffhfa_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row2 sw sh]);
            
            ax=subplot(3,6,12);
            plot(data.([s,'HXFFA']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'hxffa_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row2 sw sh]);
            
            ax=subplot(3,6,16);
            plot(data.([s,'HFTBA']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'hftba_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row3 sw sh]);
            
            ax=subplot(3,6,17);
            plot(data.([s,'FFHFA']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
            hold on
            plot(data.([s,'ffhfa_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            p = get(ax,'position');
            set(ax,'position',[p(1) p(2)+row3 sw sh]);
            
                       
        end
        
        ax = findobj(hnd,'type','axes');
        ln = findobj(hnd,'type','line');
        ln1 = get(ln(1),'XData');
%         XLim = [0 length(ln1)];
%         XLim = [72 176];  % for HC015A07
        

        for j = 1:length(ax)
            set(ax(j),'XLim',XLim,'FontSize',FontSize,'FontName',FontName,...
                      'XTick',80:40:160)          
            axes(ax(j))
            hline(0,'k')
        end
        
        
        legend('Vicon','custom')
        
    end
    
    
    
end

















