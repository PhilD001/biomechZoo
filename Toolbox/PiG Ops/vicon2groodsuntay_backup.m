function [KIN,data,ERR] = vicon2groodsuntay_backup(varargin)

% This works, but the axes are defined awkwardly
% [KIN,data,ERR] = vicon2groodsuntay(data)
%
% ARGUMENTS
% data     ...  zoo data containing all oxford foot model output channels
% check    ...  check results against oxford. Default yes
% display  ...  display results. Default is 'no' 

% RETURNS
% KIN     ...   structured array containing Grood and Suntay computed channels
% data    ...   zoo data with additional Grood and Suntay computed channels
%              included
% ERR     ...   structured array containing RMS error values for each angle
%
%
%
% Created by Phil Dixon December 20th, 2010
%
%
% NOTES: 
% 
% Flipping angle problem: 
% -It is now anatomically implausible for the vectors to flip. If a 
% flip causes bad data it is due to bad labelling, usually at start or end of
% trial. This error is NOT fixed. Any data crossing +/- 90 deg in the foot is
% wrong! Or severly pathologic!
% -This error can be avoided by cutting your data to region of interest
% before running this function. Usually errors occur on the edges
% (beginning and end of data)

%---DEFAULT SETTINGS---
%
check = 'yes';
display = 'no';


%---USER DEFINED SETTINGS----

for i = 1:2:nargin
    
    switch varargin{i}
        case 'data'
            data = varargin{i+1};
            
        case 'display'
            display = varargin{i+1};
            
        case 'check'
            check = varargin{i+1};
                       
    end
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
% 3 is vector along long axis of bone

pgdim = {'O','A','L','P'};
% O is origin of bone, at distal joint (letter O)
% A is an anterior vector from bone
% L is a lateral vector
% P is the proximal joint


for i = 1:length(pgbone(:,1))
    d = [];
    
        for j = 1:4
            d{j} = data.([pgbone{i,1},pgdim{j}]).line;        
        end

    bn = pgbone{i,2};
    ort = getdatapg(d);
    r.(bn).ort = ort;
    
end


for i = 1:length(oxbone(:,1))
    d = [];
    
        for j = 1:4
            d{j} = data.([oxbone{i,1},oxdim{j}]).line;        
        end

    bn = oxbone{i,2};
    ort = getdataox(d);
    r.(bn).ort = ort;
    
end
 


%----4: COMPUTE JOINT ANGLES ACCORDING TO GROOD AND SUNTAY------------ 
%
KIN = get_grood_suntay(r,jnt,data);


%----5: FIX REFERENCE SYSTEM TO MATCH CLINICAL-------
%
% - rename channels to match the oxford names
KIN = viconref(KIN,data);


%----6: CHECK ACCURACY OF CALCULATIONS AGAINST ORIGINAL VICON DATA (DISPLAY OPTIONAL)
%
ERR=checkvicon(KIN,data,check,display);


%----7: ADD COMPUTED ANGLES TO DATA STRUCT
%
data = addchannelsgs(data,KIN,ERR);



%=================EMBEDDED FUNCTIONS============

%Original working funciton
function ort = getdataox(d)

a = (d{2}-d{1})/10;   % Anterior - Origin:          Creates anterior vector
m = (d{3}-d{1})/10;   % Medial - Origin:            Creates medial vector (right side), Lateral vector (left side)
l = (d{4}-d{1})/10;   % Distal - Origin:            Creates vector along long axis of bone

rw = size(a);
ort = [];
for i = 1:rw
       ort = [ort;{[l(i,:);a(i,:);m(i,:)]}]; %for updated grood suntay version   
end



% new problem function

% function ort = getdataox(d)
% 
% % data comes in as 0,1,2,3
% 
% z = (d{2}-d{1})/10;   % Anterior - Origin:          Creates anterior vector
% y = (d{3}-d{1})/10;   % Medial - Origin:            Creates medial vector (right side), Lateral vector (left side)
% x = (d{4}-d{1})/10;   % Distal - Origin:            Creates vector along long axis of bone
% 
% rw = size(x);
% ort = [];
% for i = 1:rw
%        ort = [ort;{[x(i,:);y(i,:);z(i,:)]}]; %for updated grood suntay version   
% end


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



function KIN = get_grood_suntay(r,jnt,data)

% alpha goes into flx
% beta goes into abd
% gamma goes into IntExt

for i = 1:length(jnt(:,1))
        [KIN.(jnt{i,1}).flx,KIN.(jnt{i,1}).abd,KIN.(jnt{i,1}).tw] = groodsuntay(r,jnt(i,1:end),data);
end




% 
% function [flx,abd,tw] = groodsuntayold(r,jnt,data)
% 
% %---SET UP VARIABLES AND CHECK FOR NANS---
% 
% pbone = jnt{2};
% dbone = jnt{3};
% 
% % disp(['calculating angles between ',pbone,' and ',dbone,' ...'])
% % disp(' ')
% 
% pax = r.(pbone).ort;  % contains xyz local axes for each frame
% dax = r.(dbone).ort;
% 
% k1 = [];
% i1 = [];
% j1 = [];
% floatax = [];  
% k2 = [];
% i2 = [];
% j2 = [];
% 
% 
% %---CREATE AXES FOR GROOD AND SUNTAY CALCULATIONS----
% 
% if ~isempty(strfind(pbone,'Tibia'))
% 
%     for i = 1:length(pax)
% 
%         p = pax{i};  
%         d = dax{i};
%         
%         ip = p(2,:);   % since axes of tibia are different, we must reorder vectors, x is the 2nd one
%         jp = p(3,:);
% 
%         id = d(1,:);
%         jd = d(3,:);
% 
%         j1 = [j1;jp];
%         i1 = [i1;ip];
% 
%         fax = cross(id,jp);
%         floatax = [floatax;fax];
% 
%         j2 = [j2;jd];
%         i2 = [i2;id];
% 
%     end
% 
% else
% 
%     for i = 1:length(pax)
% 
%         p = pax{i};  
%         d = dax{i};
% 
%         ip = p(1,:);   % long axis
%         jp = p(3,:);   % medial axis
% 
%         id = d(1,:);
%         jd = d(3,:);
% 
%         j1 = [j1;jp];
%         i1 = [i1;ip];
% 
%         fax = cross(id,jp);
%         floatax = [floatax;fax];
% 
%         j2 = [j2;jd];
%         i2 = [i2;id];
% 
%     end
% 
% end
% 
%    
% % Grood and Suntay angle calculations based on adaptation by Vaughan 'The
% % Gait Book' Appendix B, p95. Offsets made to match oxford foot model
% % outputs
% 
% flx = angle(floatax,i1)-90;        % plantar/ dorsi
% 
% if ~isempty(strfind(pbone,'Right'))    % Hindfoot / Tibia Angle
%     abd = -angle(j1,i2)+90;         % int / ext
%     tw = -angle(floatax,j2)+90;     % pro / suppination
% 
% elseif ~isempty(strfind(pbone,'Left'))  % Hindfoot / Tibia Angle
%     abd = angle(j1,i2)-90;         % int / ext
%     tw = angle(floatax,j2)-90;     % pro / suppination
% 
% elseif ~isempty(strfind(pbone,'ForeFoot'))     % Hallux / Forefoot angle
%     abd = zeros(size(flx));         % crap data
%     tw = zeros(size(flx));      % crap data
% 
% else
%     abd = angle(j1,i2)-90;         % int / ext
%     tw = angle(floatax,j2)-90;    
% 
% end
% 



function r=viconref(KIN,data)
% Change names to match vicon nomenclature

r = struct;

if isfield(KIN,'RightKnee')  % checks for plugin gait
    
r.RightHip.FlxExt = -KIN.RightHip.flx+90;
r.RightHip.AbdAdd = KIN.RightHip.abd-90;     % vicon int/ext is the same as IDA Abd/Add (
r.RightHip.IntExt = -KIN.RightHip.tw-90;

r.RightKnee.FlxExt = -KIN.RightKnee.flx-90;
r.RightKnee.AbdAdd = -KIN.RightKnee.abd-90;     % vicon int/ext is the same as IDA Abd/Add (
r.RightKnee.IntExt = KIN.RightKnee.tw-90;
    
r.RightAnklePG.PlaDor = -KIN.RightAnklePG.flx-90;
r.RightAnklePG.InvEve = -KIN.RightAnklePG.abd-90;     % vicon int/ext is the same as IDA Abd/Add (
r.RightAnklePG.IntExt = KIN.RightAnklePG.tw-90;

r.LeftHip.FlxExt = -KIN.LeftHip.flx+90;
r.LeftHip.AbdAdd = -KIN.LeftHip.abd+90;     % vicon int/ext is the same as IDA Abd/Add (
r.LeftHip.IntExt = KIN.LeftHip.tw+90;

r.LeftKnee.FlxExt = -KIN.LeftKnee.flx-90;
r.LeftKnee.AbdAdd = -KIN.LeftKnee.abd+90;     % vicon int/ext is the same as IDA Abd/Add (
r.LeftKnee.IntExt = KIN.LeftKnee.tw+90;
    
r.LeftAnklePG.PlaDor = -KIN.LeftAnklePG.flx-90;
r.LeftAnklePG.InvEve = -KIN.LeftAnklePG.abd+90;     % vicon int/ext is the same as IDA Abd/Add (
r.LeftAnklePG.IntExt = KIN.LeftAnklePG.tw+90;

end

if isfield(KIN,'RightMidFoot')  % checks for oxford

%Right Ankle HindFoot relative to Tibia
r.RightAnkleOFM.PlaDor = KIN.RightAnkleOFM.flx;
r.RightAnkleOFM.InvEve = KIN.RightAnkleOFM.abd;     % vicon int/ext is the same as IDA Abd/Add (
r.RightAnkleOFM.IntExt = KIN.RightAnkleOFM.tw;

%'RightMidFoot'   % Forefoot relative to Hindfoot
r.RightMidFoot.PlaDor = KIN.RightMidFoot.flx;  
r.RightMidFoot.SupPro = KIN.RightMidFoot.abd;
r.RightMidFoot.AbdAdd = KIN.RightMidFoot.tw;  

% 'RightMTP'
r.RightMTP.PlaDor = KIN.RightMTP.flx;   

% 'LeftAnkleOFM'   % HindFoot relative to Tibia
r.LeftAnkleOFM.PlaDor = KIN.LeftAnkleOFM.flx;
r.LeftAnkleOFM.InvEve = KIN.LeftAnkleOFM.abd;     % vicon int/ext is the same as IDA Abd/Add (
r.LeftAnkleOFM.IntExt = KIN.LeftAnkleOFM.tw;

% 'LeftMidFoot'   % Forefoot relative to Hindfoot
r.LeftMidFoot.PlaDor = KIN.LeftMidFoot.flx;  
r.LeftMidFoot.SupPro = KIN.LeftMidFoot.abd;
r.LeftMidFoot.AbdAdd = KIN.LeftMidFoot.tw;  

% 'LeftMTP'
r.LeftMTP.PlaDor = KIN.LeftMTP.flx;   % GOOD

end



function data = addchannelsgs(data,KIN,ERR)


% add plugingait channels---

dch = {'Rhip','Rknee','RanklePG','Lhip','Lknee','LanklePG'};
kch = {'RightHip','RightKnee','RightAnklePG','LeftHip','LeftKnee','LeftAnklePG'};

for i = 1:length(dch)

    dsub = {'x','y','z'};
    ksub = {'FlxExt','AbdAdd','IntExt'};
    asub = {'PlaDor','InvEve','IntExt'};

    for j = 1:length(dsub)
        if ~isempty(strfind(dch{i},'ankle'))
            data.([dch{i},'_',dsub{j}]).line = KIN.(kch{i}).(asub{j});

            if ~isempty(ERR)
                data.([dch{i},'_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(asub{j}).RMS 0];
            end

        else
            data.([dch{i},'_',dsub{j}]).line = KIN.(kch{i}).(ksub{j});

            if ~isempty(ERR)
                data.([dch{i},'_',dsub{j}]).event.rms = [1 ERR.(kch{i}).(ksub{j}).RMS 0];
            end
        end
    end
end

%--- add OFM angles
            
   
data.Rhftba_x.line = KIN.RightAnkleOFM.PlaDor;
data.Rhftba_y.line = KIN.RightAnkleOFM.InvEve;
data.Rhftba_z.line = KIN.RightAnkleOFM.IntExt;

data.Rffhfa_x.line = KIN.RightMidFoot.PlaDor;
data.Rffhfa_z.line = KIN.RightMidFoot.AbdAdd;
data.Rffhfa_y.line = KIN.RightMidFoot.SupPro;

data.Rhxffa_x.line = KIN.RightMTP.PlaDor;


%--left---

data.Lhftba_x.line = KIN.LeftAnkleOFM.PlaDor;
data.Lhftba_y.line = KIN.LeftAnkleOFM.InvEve;
data.Lhftba_z.line = KIN.LeftAnkleOFM.IntExt;

data.Lffhfa_x.line = KIN.LeftMidFoot.PlaDor;
data.Lffhfa_z.line = KIN.LeftMidFoot.AbdAdd;
data.Lffhfa_y.line = KIN.LeftMidFoot.SupPro;

data.Lhxffa_x.line = KIN.LeftMTP.PlaDor;

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

%------------CHECK ACCURACY OF RESULTS--------

function ERR=checkvicon(KIN,data,check,display)

if strcmp(check,'no')
    ERR = '';
    return
    
else

    if isfield(data,'RHDF1')   % if oxford outputs are present
        ERR1= ofxcheck(KIN,data,display);
    end

    if isfield(data,'RFEO')    
        ERR2= pgcheck(KIN,data,display);
    end

end

ch1 = fieldnames(ERR1);
ch2 = fieldnames(ERR2);
ERR = struct;

for i = 1:length(ch1)
    ERR.(ch1{i}) = ERR1.(ch1{i});
end

for j = 1:length(ch2)
    ERR.(ch2{j}) = ERR2.(ch2{j});
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

subcha = {'PlaDor','IntExt','InvEve'};

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



