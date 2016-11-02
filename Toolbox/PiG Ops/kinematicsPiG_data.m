function data = kinematicsPiG_data(data,graph)

% data = KINEMATICSPIG_DATA(data,settings) computes global pelvis and lower-limb
% joint angles based on the joint coordinate system of Grood and Suntay (1983)
%
% ARGUMENTS
%  data     ...  Zoo data 
%  graphs   ...  true or false (boolean). Graph comparisons against PiG data,
%                if available . Default: false
%
% RETURNS
%  data    ...   zoo data appended with kinemaitc channels 
%  ERR     ...   structured array containing RMS error values for each angle
%
%
% NOTES:
% - It is anatomically implausible for the vectors to flip during walking but may be
%   possible for tasks with large ranges of motion (e.g. running). A correction has been
%   implemented at the knee, but might require future updates (see 'checkflippg' function).
% - For PiG, choice of axes for angle computation based on detailed work of Vaughan
%   (Dynamics of Human Gait 1999, Appendix B p94-96). This is the Grood and Suntay method.
% - For OFM choice of axes based on trial and error.
%
% SUMMARY OF CALCULATIONS
%
% floating axis (PIG) = cross(lat_prox , long_dist)
%
% Pelvis
% flx = asind(dot(-long_dist,lat_prox,2));
% abd = asind(dot(long_dist,ant_prox,2));
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
% See also makebones, bmech_kinematicsPiG, bmech_jointcentrePiG


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


% Set defaults
%
if nargin==1
    graph   = false;
end
    
if graph == true
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



%----1 : GET BONES -----------------------------------------------------------------------
%
% collect bones into appropriate format
[bone,jnt,data] = getbones(data);



%----2: PREPARE DATA FOR GROOD AND SUNTAY CALCULATIONS -----------------------------------
%
dim = {'O','A','L','P'};
% O is origin of bone, at distal joint (letter O)
% A is an anterior vector from bone
% L is medial( right) or lateral (left) vector
% P is long axis of bone vector (pointing proximally)


for i = 1:length(bone(:,1))
    d = [];
    
    if strcmp(bone{i,1},'GLB')
        d{1} =  zeros(size(data.([bone{i+1,1},dim{1}]).line));
        d{2} =  [d{1}(:,1)+10 d{1}(:,2:3)];
        d{3} =  [d{1}(:,1) d{1}(:,2)+10 d{1}(:,3)];
        d{4} =  [d{1}(:,1:2) d{1}(:,3)+10];
    else
        
        for j = 1:4
            d{j} = data.([bone{i,1},dim{j}]).line; %#ok<AGROW>
        end
    end
    
    bn = bone{i,2};
    ort = getdata(d);
    r.(bn).ort = ort;
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
ERR=checkvicon(KIN,data,check,display);


%----7: ADD COMPUTED ANGLES TO DATA STRUCT -----------------------------------------------
%
data = addchannelsgs(data,KIN,ERR);


%----8: IMPLEMENT A GRAPHICAL CHECK AGAINST ORIGINAL VICON DATA (OPTIONAL)
%

if graph == true
    graphresults(data,gsettings)
end




%=================EMBEDDED FUNCTIONS=======================================



function ort = getdata(d)

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
        [~,ant_prox,ant_dist,lat_prox,~,~,long_dist] = makeax(pax,dax);
        
        flx = asind(dot(-long_dist,lat_prox,2));
        abd = asind(dot(long_dist,ant_prox,2));
        twix = asind( dot(ant_dist,ant_prox,2)./cosd(flx));
        twiy = asind( dot(ant_dist,lat_prox,2)./cosd(flx));
        
        [flx,abd,tw] = checkdir(flx,abd,twix,twiy,dir);
        
        
    case {'Pelvis','Femur'}  % Hip and Knee
        [floatax,~,~,lat_prox,lat_dist,long_prox,long_dist] = makeax(pax,dax);
        
        %         flx = angle(floatax,long_prox);  % this is actually incorrect but can be fixed by offset
        %         abd = angle(lat_prox,long_dist);
        %         tw  = angle(floatax,lat_dist);
        
        flx = asind(dot(floatax,long_prox,2));
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
        
        if isnear(max(abs(flx)),90,1)
            flx = checkflippg(flx,floatax,long_prox);
        end
        
    case 'Tibia'   % Ankle PG angles
        [floatax,ant_prox,~,lat_prox,lat_dist,~,long_dist] = makeax(pax,dax);
        
        flx = asind(dot(floatax,ant_prox,2)); % chosen to avoid axis flipping
        abd = asind(dot(lat_prox,long_dist,2));
        tw  = asind(dot(floatax,lat_dist,2));
        
    case 'TibiaStatic'   % Ankle PG Static angles
        [floatax,~,~,lat_prox,lat_dist,long_prox,long_dist] = makeax(pax,dax);
        
        flx = asind(dot(floatax,long_prox,2));    % beta from pyCGM
        abd = asind(dot(lat_prox,long_dist,2));   % alpha from pyCGM
        tw  = asind(dot(floatax,lat_dist,2));     % gamma from pyCGM  
end


function [phi,theta,psi] = checkdir(phi,theta,psix,psiy,dir)

switch dir
    
    case 'Jpos'
        phi = -phi;
        theta = -theta;
        psi = -psix;
        
    case 'Jneg'
        psi = psix;
        
    case 'Ipos'         % this direction was not chcked and is likely wrong
        psi = psiy;
        
    case 'Ineg'        % this direction was not chcked and is likely wrong
        psi = -psiy;
        
        
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

% 
% function [floatax,ant_prox,ant_dist,lat_prox,lat_dist,long_prox] = makeaxox(pax,dax)
% 
% ant_prox = zeros(length(pax),3);
% lat_prox = zeros(length(pax),3);
% long_prox = zeros(length(pax),3);
% 
% ant_dist = zeros(length(pax),3);
% lat_dist = zeros(length(pax),3);
% 
% floatax = zeros(length(pax),3);
% 
% 
% for i = 1:length(pax)
%     ant_prox(i,:) = pax{i}(1,:);
%     lat_prox(i,:) = pax{i}(2,:);
%     long_prox(i,:) = pax{i}(3,:);
%     
%     lat_dist(i,:) = dax{i}(2,:);
%     ant_dist(i,:) = dax{i}(1,:);
%     
%     floatax(i,:) = cross(lat_prox(i,:), ant_dist(i,:));
% end


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
    r.Pelvis.Tilt = KIN.GlobalPelvis.flx;
    r.Pelvis.Obliquity = KIN.GlobalPelvis.abd;
    r.Pelvis.IntExt = KIN.GlobalPelvis.tw;
    
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


if isfield(KIN,'RightAnkleStatic')
    r.RightAnkleStatic.PlaDor = KIN.RightAnkleStatic.flx;
    r.RightAnkleStatic.IntExt = KIN.RightAnkleStatic.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.RightAnkleStatic.InvEve = KIN.RightAnkleStatic.tw;
    
    r.LeftAnkleStatic.PlaDor  = KIN.LeftAnkleStatic.flx;
    r.LeftAnkleStatic.IntExt  = KIN.LeftAnkleStatic.abd;     % vicon int/ext is the same as IDA Abd/Add (
    r.LeftAnkleStatic.InvEve = KIN.LeftAnkleStatic.tw;
end


function data = addchannelsgs(data,KIN,ERR)

% add plugingait channels---

kch = {'Pelvis','RightHip','RightKnee','RightAnkle','LeftHip','LeftKnee','LeftAnkle'};

for i = 1:length(kch)
    
    dsub = {'x','y','z'};
    ksub = {'FlxExt','AbdAdd','IntExt'};
    asub = {'PlaDor','InvEve','IntExt'};
    psub = {'Tilt','Obliquity','IntExt'};
    for j = 1:length(dsub)
        
        if ~isempty(strfind(kch{i},'Ankle'))
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(asub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(asub{j}).RMS 0];
            end
            
        elseif ~isempty(strfind(kch{i},'Pelvis'))
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(psub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(psub{j}).RMS 0];
            end
            
            
        else
            
            
            data = addchannel_data(data,[kch{i},'Angle_',dsub{j}],KIN.(kch{i}).(ksub{j}),'Video');
            
            if ~isempty(ERR)
                data.([kch{i},'Angle_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(ksub{j}).RMS 0];
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
                data.([kch{i},'Angle_',dsub{j}]).event.rms = [1 NaN 0]; % no error possible
            end
        end
    end
    
end


%------------CHECK ACCURACY OF RESULTS--------

function ERR=checkvicon(KIN,data,check,display)

if check == false
    ERR = '';
    return
    
else
  
    if isfield(data,'RFEO')
        ERR2= pgcheck(KIN,data,display);
        ch2 = fieldnames(ERR2);
        
        for j = 1:length(ch2)
            ERR.(ch2{j}) = ERR2.(ch2{j});
        end
        
    end
    
end


function ERR= pgcheck(KIN,data,display)

Pstk  = zeros(3,1);
LHstk = zeros(3,1);
LKstk = zeros(3,1);
LAstk = zeros(3,1);
RHstk = zeros(3,1);
RKstk = zeros(3,1);
RAstk = zeros(3,1);

subch = {'FlxExt','AbdAdd','IntExt'};

for k = 1:3
    LHstk(k)=sqrt(sum(nansum((data.LHipAngles.line(:,k)-KIN.LeftHip.(subch{k})).^2))/numel(~isnan(data.LHipAngles.line(:,k))));
    LKstk(k)=sqrt(sum(nansum((data.LKneeAngles.line(:,k)-KIN.LeftKnee.(subch{k})).^2))/numel(~isnan(data.LKneeAngles.line(:,k))));
    RHstk(k)=sqrt(sum(nansum((data.RHipAngles.line(:,k)-KIN.RightHip.(subch{k})).^2))/numel(~isnan(data.RHipAngles.line(:,k))));
    RKstk(k)=sqrt(sum(nansum((data.RKneeAngles.line(:,k)-KIN.RightKnee.(subch{k})).^2))/numel(~isnan(data.RKneeAngles.line(:,k))));
end

subchp = {'Tilt','Obliquity','IntExt',};

for k = 1:3
    Pstk(k) =sqrt(sum(nansum((data.RPelvisAngles.line(:,k)-KIN.Pelvis.(subchp{k})).^2))/numel(~isnan(data.RPelvisAngles.line(:,k))));
end


subcha = {'PlaDor','InvEve','IntExt',};

for k = 1:3
    LAstk(k)=sqrt(sum(nansum((data.LAnkleAngles.line(:,k)-KIN.LeftAnkle.(subcha{k})).^2))/numel(~isnan(data.LAnkleAngles.line(:,k))));
    RAstk(k)=sqrt(sum(nansum((data.RAnkleAngles.line(:,k)-KIN.RightAnkle.(subcha{k})).^2))/numel(~isnan(data.RAnkleAngles.line(:,k))));
end

ERR.Pelvis.Tilt.RMS=Pstk(1);
ERR.Pelvis.Obliquity.RMS=Pstk(2);
ERR.Pelvis.IntExt.RMS=Pstk(3);

ERR.RightAnkle.PlaDor.RMS=RAstk(1);
ERR.RightAnkle.IntExt.RMS=RAstk(2);
ERR.RightAnkle.InvEve.RMS=RAstk(3);

ERR.RightKnee.FlxExt.RMS=RKstk(1);
ERR.RightKnee.AbdAdd.RMS=RKstk(2);
ERR.RightKnee.IntExt.RMS=RKstk(3);

ERR.RightHip.FlxExt.RMS=RHstk(1);
ERR.RightHip.AbdAdd.RMS=RHstk(2);
ERR.RightHip.IntExt.RMS=RHstk(3);

ERR.LeftAnkle.PlaDor.RMS=LAstk(1);
ERR.LeftAnkle.IntExt.RMS=LAstk(2);
ERR.LeftAnkle.InvEve.RMS=LAstk(3);

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


function graphresults(data,graph)

if graph == true
    
    vcol = 'k';
    ccol = [0.23 0.44 0.34];
    
    vstyle = '-';
    cstyle = '--';
    
    LineWidth = 1.5;
    
    FontSize = 12;
    FontName = 'Arial';
    
    sides = {'Right','Left'};
    
    dlength = find(~isnan(data.RightAnkleAngle_x.line(:,1)),1,'last');
    
    hnd = figure;
    set(hnd,'name','Comparison of Vicon PiG and Grood and Suntay Angles '); % Just having fun
    
    
    for i = 1:length(sides)
        side = sides{i};
        s = side(1);
        
        if strcmp(side,'Left')
            offset= 3;
        else
            offset = 0;
        end
        
        if i==1
            subplot(3,7,1);
            plot(data.([s,'PelvisAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.PelvisAngle_x.line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            title('Pelvis','FontSize',FontSize,'FontName',FontName)
            ylabel({'Sagittal','Angles (deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            xlim([0 dlength])
            
            subplot(3,7,8);
            plot(data.([s,'PelvisAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.PelvisAngle_y.line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            ylabel({'Coronal','Angles (deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            xlim([0 dlength])
            
            subplot(3,7,15);
            plot(data.([s,'PelvisAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
            hold on
            plot(data.PelvisAngle_z.line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
            ylabel({'Transverse','Angles (deg)'},'FontSize',FontSize,'FontName',FontName)
            axis('square')
            xlim([0 dlength])
        end
        
        subplot(3,7,2+offset);
        plot(data.([s,'HipAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth);
        hold on
        plot(data.([side,'HipAngle_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        title([s,'Hip'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        xlim([0 dlength])
        
        subplot(3,7,3+offset);
        plot(data.([s,'KneeAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'KneeAngle_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        title([s,'Knee'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        xlim([0 dlength])
        
        subplot(3,7,4+offset);
        plot(data.([s,'AnkleAngles']).line(:,1),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'AnkleAngle_x']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        title([s,'Ankle'],'FontSize',FontSize,'FontName',FontName)
        axis('square')
        xlim([0 dlength])
        
        subplot(3,7,9+offset);
        plot(data.([s,'HipAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HipAngle_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        axis('square')
        xlim([0 dlength])
        
        subplot(3,7,10+offset);
        plot(data.([s,'KneeAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'KneeAngle_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        axis('square')
        xlim([0 dlength])
        
%         subplot(3,7,11+offset);
%         plot(data.([s,'AnkleAngles']).line(:,2),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
%         hold on
%         plot(data.([side,'AnkleAngle_y']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
%         axis('square')
%         xlim([0 dlength])
        
        subplot(3,7,16+offset);
        plot(data.([s,'HipAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'HipAngle_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        axis('square')
        xlim([0 dlength])
        
        subplot(3,7,17+offset);
        plot(data.([s,'KneeAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
        hold on
        plot(data.([side,'KneeAngle_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
        axis('square')
        xlim([0 dlength])
        
%         subplot(3,7,18+offset);
%         plot(data.([s,'AnkleAngles']).line(:,3),'Color',vcol,'LineStyle',vstyle,'LineWidth',LineWidth)
%         hold on
%         plot(data.([side,'AnkleAngle_z']).line,'Color',ccol,'LineStyle',cstyle,'LineWidth',LineWidth)
%         axis('square')
%         xlim([0 dlength])
        
        if i==2
            legend('Vicon','Matlab')
        end
    end
    
   
    
end

















