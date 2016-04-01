function data = makebones(sdata,data)

% DATA = MAKEBONES(data,sdata) creates segment axes for use in vicon2groodsuntay
%
% ARGUMENTS
%
% sdata   ... static trial data
% data    ... dynamic trial data with PiG 'bone' channels (suff
%             'O','A','L','P') for pelvis, R/L femur, R/L tibia, R/L foot
%             as well as R/L Hip (HJC), Knee (KJC), ankle (AJC) joint centers
%
% NOTES
% - requires further testing before use

% Revision history: 
%
% Created by Yannick Michaud-Paqutte 2008
%
% Updated by Philippe C. Dixon March 17th 2016
% - User can input static trial data with medial knee and ankle markers to improve
%  joint center estimates. If static trial is not included (and dynamic
%  trial does not include these markers) offset from KNEE and ANK markers
%  in global Y will be used to locate joint center


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



% Set defaults
%


% Load file for testing purposes
%
if nargin==0
    
    f = 'HC021A01.zoo';
    p = ['/Users/phildixon/Dropbox/Current Work/my public m-files and datasets/'...
        'the zoosystem/Sample Study/Data/1-c3d2zoo/HC021A/Static/'];
    sdata = zload([p,f]);
    
    f = 'HC021A23.zoo';
    p = ['/Users/phildixon/Dropbox/Current Work/my public m-files and datasets/'...
        'the zoosystem/Sample Study/Data/1-c3d2zoo/HC021A/Turn/'];
    data = zload([p,f]);
    test = 1;
else
    test = 0;
end




% Get anthropometric parameters
%
anthro = getAnthro(data);

RAsisTrocDist = 0;
LAsisTrocDist = 0;

LLegLength = anthro.LLegLength;
RLegLength = anthro.RLegLength;

markerdiameter = anthro.MarkerDiameter;
mm = markerdiameter/2 ;

lkneewidth = anthro.LKneeWidth;
rkneewidth = anthro.RKneeWidth;

lanklewidth = anthro.LAnkleWidth;
ranklewidth = anthro.RAnkleWidth;



% Get markers for comparison
%
SACR = data.SACR.line;
LASI = data.LASI.line;
RASI = data.RASI.line;

LKNE = data.LKNE.line;
RKNE = data.RKNE.line;
LANK = data.LANK.line;
RANK = data.RANK.line;

RTHI = data.RTHI.line;
LTHI = data.LTHI.line;

LFEO = data.LFEO.line; % PiG computed Knee joint Center


% Pelvis
%
pelo = (LASI + RASI)/2;         % origin (O)
pelx = LASI-pelo;               % lateral vector (L)
peltemp = SACR - pelo;          % temp anterior 
pelz = cross(pelx,peltemp);     % proximal (P)
pely = cross(pelx,pelz);        % final anterior (A)

data = addchannel(data,'mPELO',pelo);      
data = addchannel(data,'mPELP',pelz);
data = addchannel(data,'mPELL',pelx);
data = addchannel(data,'mPEA',pely);

% plot(pelx.*10)
% hold on
% plot(data.PELL.line)

% dim = {'O','A','L','P'};
% for i = 1:length(dim)
%     subplot(1,4,i)
%     plot(data.(['mPEL',dim{i}]).line)
%     hold on
%     plot(data.(['PEL',dim{i}]).line)
%     xlim([0,length(data.(['PEL',dim{i}]).line)])
% end


% Left Hip joint center
%
if RAsisTrocDist == 0 && LAsisTrocDist == 0
    RAsisTrocDist = (0.1288*RLegLength)-48.56; % distance estimated following (Davis, Ounpuu, Tyburski and Gage, 1991) linear regression analysis
    LAsisTrocDist = (0.1288*LLegLength)-48.56;
end

InterAsis = magnitude(LASI - RASI);
InterAsis = mean(InterAsis);

Cl = (LLegLength*0.115) - 15.3; % Distance between the greater trochanter's head and the ASIS (see Davis et al, 1991)

COSBETA  = cos(0.314);
SINBETA  = sin(0.314);
COSTHETA = cos(0.5);
SINTHETA = sin(0.5);

LHipOSx = Cl*COSTHETA*SINBETA - (LAsisTrocDist + mm)*COSBETA;
LHipOSy = -(Cl*SINTHETA - (InterAsis/2));
LHipOSz = -Cl*COSTHETA*COSBETA - (LAsisTrocDist + mm)*SINBETA;

LHJC=zeros(size(LASI));
for i =1:length(LASI)
    LHJC(i,:) = LASI(i,:) + [LHipOSx,LHipOSy,LHipOSz];
end



% Left Knee joint center 
%
if isfield(sdata,'LMFE')   % if a medial knee marker is available
    disp('not yet coded')
end

% tic
% syms u
% solve(1-0.99-(u+1)*exp(-u),'Real',true)
% toc
% double(ans)


LKJC = GetKneeJointCentreLeitch(LHJC,LTHI,LKNE,lkneewidth,markerdiameter);


% data = addchannel(data,'mLKJC',LKJC);



% Left Femur bones

LKJC = data.LFEO.line; % use for testing
LHJC = data.LHJC.line; % use for testing

LFEMo = LKJC;
LFEMz = LHJC - LKJC;
LFEMtemp = LTHI - LKJC;
LFEMx = cross(LFEMz,LFEMtemp);
LFEMy = cross(LFEMx,LFEMz);

test = LFEMo-LFEMz;

data = addchannel(data,'mLFEO',LFEMo);
data = addchannel(data,'mLFEP',LFEMy);
data = addchannel(data,'mLFEA',LFEMx);
data = addchannel(data,'mLFEL',LFEMz);


% subplot(1,4,1)
% plot(data.mLFEO.line)
% hold on
% plot(data.LFEO.line)
% ylabel('LFEO')
% 
% subplot(1,4,2)
% plot(data.mLFEA.line);
% hold on
% plot(data.LFEA.line);
% ylabel('LFEA')
% 
% subplot(1,4,3)
% plot(data.mLFEL.line);
% hold on
% plot(data.LFEL.line);
% ylabel('LFEL')
% 
% subplot(1,4,4)
% plot(data.mLFEP.line);
% hold on
% plot(data.LFEP.line);
% ylabel('LFEP')




% Right Hip joint center
%
InterAsis = magnitude(LASI - RASI);
InterAsis = InterAsis(1,1);

Cr = (RLegLength*0.115) - 15.3;

COSBETA = 0.951;
SINBETA = 0.309;
COSTHETA = 0.880;
SINTHETA = 0.476;

RHipOSx = Cr*COSTHETA*SINBETA - (RAsisTrocDist + mm)*COSBETA;
RHipOSy = Cr*SINTHETA - (InterAsis/2);
RHipOSz = -Cr*COSTHETA*COSBETA - (RAsisTrocDist + mm)*SINBETA;

RHJC=zeros(size(RASI));
for i = 1:length(RASI)
    RHJC(i,:) = RASI(i,:) + [RHipOSx,RHipOSy,RHipOSz];
end

data = addchannel(data,'mRHJC',RHJC);


% Right knee joint center
%

KneeOSx = 0;
RKneeOSy = (mm + 0.5*rkneewidth);
KneeOSz = 0;

RKJC = zeros(size(RASI));
for i = 1:length(RKNE)
    RKJC(i,:) = RKNE(i,:) + [KneeOSx,RKneeOSy,KneeOSz];
end

data = addchannel(data,'mRKJC',RKJC);


% Right Femur bones
%
RFEMo = RKJC;
RFEMz = RHJC - RKJC;
RFEMtemp = RTHI - RKJC;
RFEMx = cross(RFEMz,RFEMtemp);
RFEMy = cross(RFEMx,RFEMz);

data = addchannel(data,'mRFEO',RFEMo);
data = addchannel(data,'mRFEP',RFEMy);
data = addchannel(data,'mRFEA',RFEMx);
data = addchannel(data,'mRFEL',RFEMz);



% Left Ankle joint centers calculation
%

LKJC = data.LFEO.line;
LAJC = GetKneeJointCentreLeitch(LKJC,data.LTIB.line,LANK,lanklewidth,markerdiameter);


% Left Tibia bones

LTIBo = LAJC;
LTIBz = LKJC - LAJC;
LTIBtemp = LTIBo - LAJC;
LTIBx = cross(LTIBz,LTIBtemp);
LTIBy = cross(LTIBx,LTIBz);

data = addchannel(data,'mLTIO',LTIBo);
data = addchannel(data,'mLTIP',LTIBy);
data = addchannel(data,'mLTIA',LTIBx);
data = addchannel(data,'mLTIL',LTIBz);





% Right ankle joint center
%
sRANK = sdata.RANK.line;
sRMMA = sdata.RMMA.line;

ank_offset = mean((sRANK - sRMMA)/2);   

RAJC = zeros(size(data.RANK.line));
RAJC(:,1) = data.RANK.line(:,1)+ank_offset(1);
RAJC(:,2) = data.RANK.line(:,2)+ank_offset(2);
RAJC(:,3) = data.RANK.line(:,3)+ank_offset(3);



% Right Tibia bones
%
RTIBo = RAJC;
RTIBz = RKJC - RAJC;
RTIBtemp = RTIBo - RAJC;
RTIBx = cross(RTIBz,RTIBtemp);
RTIBy = cross(RTIBx,RTIBz);







%  
% dis =  magnitude(data.RMMA.line - data.RANK.line)/2; % points laterally
% one = ones(length(RTI0),1);
% zero = zeros(length(RTI0),1);
% 
% RTI2 = RTI0 - [dis zero  zero];     % points proximally
% % RTI3 = data.RTIB3.line/100;
% % RTI2 = data.RTIB2.line/100; % cheating
% 


data = addchannel(data,'mRTIO',RTIBo);
data = addchannel(data,'mRTIP',RTIBy);
data = addchannel(data,'mRTIA',RTIBx);
data = addchannel(data,'mRTIL',RTIBz);



% Left Foot bone
%
LFOOz = LTOE - LAJC;
LFOOtemp = LKJC - LAJC;
LFOOy = cross(LFOOz,LFOOtemp);
LFOOx = cross(LFOOz,LFOOy);
LFOOo = LTOE;


data = addchannel(data,'mLFOO',LFOOo);
data = addchannel(data,'mLFOP',LFOOy);
data = addchannel(data,'mLFOA',LFOOx);
data = addchannel(data,'mLFOL',LFOOz);





% Right Foot bone
%
RFOOz = RTOE - RAJC;
RFOOtemp = RKJC - RAJC;
RFOOy = cross(RFOOz,RFOOtemp);
RFOOx = cross(RFOOz,RFOOy);
RFOOo = RTOE;






data = addchannel(data,'mRFOO',RFOOo);
data = addchannel(data,'mRFOP',RFOOy);
data = addchannel(data,'mRFOA',RFOOx);
data = addchannel(data,'mRFOL',RFOOz);




% test segment axes
%
segment = {'PEL','RFE'};
ax = {'O','A','L','P'};

count = 1;

for i = 1:length(segment)
    
    for j = 1:length(ax);
        
        subplot(length(segment),length(ax),count)
        plot(data.([segment{i},ax{j}]).line)
        hold on
        plot(data.(['m',segment{i},ax{j}]).line)
        ylabel([segment{i},ax{j}])
        xlim([0,length(data.([segment{i},ax{j}]).line)])
        
        count = count+1;
    end
    
end


% UPPER BODY (NOT TESTED)
%
% Trunk bones calculation
%-------------------------------------------------------------------------
%_________________________________________________________________________


%-------------------------------------------------------------------------
% Head bone
% if ismember({'LFHD','LBHD','RFHD','RBHD'},chlist)
%     HEAo = (LFHD + RFHD)/2;
%     HEAx = ((LBHD + RBHD)/2) - HEAo;
%     HEAtemp = LBHD - HEAo ;
%     HEAz = cross(HEAx,HEAtemp);
%     HEAy = cross(HEAx,HEAz);
%     HEAx = cross(HEAy,HEAz);
%
%     data.HEDO.line = HEAo;
%     data.HEDP.line = HEAy;
%     data.HEDA.line = HEAx;
%     data.HEDL.line = HEAz;
%
% end
% %__________________________________________________________________________
% %-------------------------------------------------------------------------
% % Thorax bone
% % Note: Z-axis is pointing downward and Y-Axis pointing rightward
%
% if ismember({'STRN','CLAV','C7'},chlist)
%
%     TRXz = STRN - CLAV;
%     TRXtemp = C7 - CLAV;
%     TRXy =  cross(TRXz,TRXtemp);
%     TRXx = cross(TRXy,TRXz);
%
%     TRXo =[];
%     for i =1:length(CLAV)
%         TRXo =[TRXo;CLAV(i,:) - [mm,0,0]];
%     end
%
%     data.TRXO.line = TRXo;
%     data.TRXP.line = TRXy;
%     data.TRXA.line = TRXx;
%     data.TRXL.line = TRXz;
%
% end
% %__________________________________________________________________________
% %-------------------------------------------------------------------------
% % Shoulder joint centers
% % Note : Using the assumption that the clavicules are lying between the
% % thorax origin and the shoulder joint center and therefore the shoulder
% % joint centers are defined as the clavicules' origins
% if ismember({'LSHO','RSHO'},chlist)
%     ISHO = magnitude(LSHO - RSHO);
%     ISHO = ISHO(1,1);
%
%     LSJC =[];
%     RSJC = [];
%     for i = 1:length(LSHO)
%         LSJC = [LSJC;LSHO(i,:) + [0,-LShoulderOffset,0]+ ISHO*[0,0,0.2]];
%         RSJC = [RSJC;RSHO(i,:) + [0,RShoulderOffset,0]+ ISHO*[0,0,0.2]];
%     end
%
%     %-------------------------------------------------------------------------
%     % Clavicule bones %
%
%
%     LCLo = LSJC;
%     LCLz = TRXo - LSJC;
%     LCLtemp = LSHO - LSJC;
%     LCLx = cross(LCLz,LCLtemp);
%     LCLy = cross(LCLx,LCLz);
%
%     data.LCLO.line = LCLo;
%     data.LCLP.line = LCLy;
%     data.LCLA.line = LCLx;
%     data.LCLL.line = LCLz;
%
%     RCLo = RSJC;
%     RCLz = TRXo - RSJC;
%     RCLtemp = RSHO - RSJC;
%     RCLx = cross(RCLtemp,RCLz);
%     RCLy = cross(RCLx,RCLz);
%
%     data.RCLO.line = RCLo;
%     data.RCLP.line = RCLy;
%     data.RCLA.line = RCLx;
%     data.RCLL.line = RCLz;
%
% end
% %__________________________________________________________________________
% %-------------------------------------------------------------------------
% % Temporary Left humerus bones %
% if ismember({'LWRA','LWRB','LELB','LSHO'},chlist)
%
%     LWR = ((LWRA + LWRB)/2);
%
%     if ~ismember('RSHO',chlist)
%         LSJC = LSHO;
%     end
%
%     LHUo = LSJC;
%     LHUz = LSJC - LELB;
%     LHUtemp = LWR - LELB;
%     LHUy = cross(LHUz,LHUtemp);
%     LHUx = cross(LHUy,LHUz);
%
%     %-------------------------------------------------------------------------
%     % Left Elbow joint centers %
%
%     ElbowOSx = 0;
%     LELBOSy = (mm + 0.5*lelbowwidth);
%     ElbowOSz = 0;
%
%     LEJC = [];
%
%     for i = 1:length(LELB)
%         LEJC = [LEJC;LELB(i,:) + [ElbowOSx,LELBOSy,ElbowOSz]];
%     end
%     %-------------------------------------------------------------------------
%     % Left Humerus bones %
%
%     LHUz = LSJC - LEJC;
%     LHUtemp = LUPA - LEJC;
%     LHUy = cross(LHUz,LHUtemp);
%     LHUx = cross(LHUy,LHUz);
%     LHUo = LEJC;
%
%     data.LHUO.line = LHUo;
%     data.LHUP.line = LHUy;
%     data.LHUA.line = LHUx;
%     data.LHUL.line = LHUz;
%
% end
% %__________________________________________________________________________
% % Temporary right humerus bone
% if ismember({'RWRA','RWRB','RELB','RSHO'},chlist)
%
%
%     RWR = ((RWRA + RWRB)/2);
%
%     if ~ismember('LSHO',chlist)
%         RSJC = RSHO;
%     end
%
%     RHUo = RSJC;
%     RHUz = RSJC - RELB;
%     RHUtemp = RWR - RELB;
%     RHUy = cross(RHUz,RHUtemp);
%     RHUx = cross(RHUy,RHUz);
%
%     %-------------------------------------------------------------------------
%     % Right Elbow joint centers %
%
%     ElbowOSx = 0;
%     RELBOSy = (mm + 0.5*relbowwidth);
%     ElbowOSz = 0;
%
%     REJC = [];
%     for i = 1:length(RELB)
%         REJC = [REJC;RELB(i,:) + [ElbowOSx,RELBOSy,ElbowOSz]];
%     end
%     %-------------------------------------------------------------------------
%     % Right Humerus bones %
%
%     RHUz = RSJC - REJC;
%     RHUtemp = RUPA - REJC;
%     RHUy = cross(RHUz,RHUtemp);
%     RHUx = cross(RHUy,RHUz);
%     RHUo = REJC;
%
%     data.RHUO.line = RHUo;
%     data.RHUP.line = RHUy;
%     data.RHUA.line = RHUx;
%     data.RHUL.line = RHUz;
%
% end
% %__________________________________________________________________________
% %------------------------------------------------------------------------
% % Temporary left radius bones %
% if ismember({'LELB','LFRM','LWRA','LWRB'},chlist)
%
%     if ~ismember('LSHO',chlist)
%         LEJC = LELB;
%         LWR = (LWRA+LWRB)/2;
%     end
%
%     LRAz = LEJC - LWR;
%     LRAtemp = LFRM - LWR;
%     LRAx = cross(LRAz,LRAtemp);
%     LRAy = cross(LRAx,LRAz);
%     %------------------------------------------------------------------------
%     % Left Wrist joint centers
%     WristOSx = 0;
%     LWristOSy = -(mm + (lwristwidth/2));
%     WristOSz = 0;
%
%     LWJC = [];
%
%     for i = 1:length(LWR)
%         LWJC = [LWJC;LWR(i,:) + [WristOSx,LWristOSy,WristOSz]];
%     end
%     %------------------------------------------------------------------------
%     % Left Radius bones
%
%     LRAz = LEJC - LWJC;
%     LRAtemp = LFRM - LWJC;
%     LRAx = cross(LRAz,LRAtemp);
%     LRAy = cross(LRAx,LRAz);
%     LRAo = LWJC;
%
%     data.LRAO.line = LRAo;
%     data.LRAP.line = LRAy;
%     data.LRAA.line = LRAx;
%     data.LRAL.line = LRAz;
% end
% %__________________________________________________________________________
% if ismember({'RELB','RFRM','RWRA','RWRB'},chlist)
%
%     if ~ismember('RSHO',chlist)
%         REJC = RELB;
%         RWR = (RWRA+RWRB)/2;
%     end
%
%     RRAz = REJC - RWR;
%     RRAtemp = RFRM - RWR;
%     RRAx = cross(RRAz,RRAtemp);
%     RRAy = cross(RRAx,RRAz);
%     %------------------------------------------------------------------------
%     % Right Wrist joint centers
%
%     WristOSx = 0;
%     RWristOSy = -(mm + (rwristwidth/2));
%     WristOSz = 0;
%
%     RWJC = [];
%
%     for i = 1:length(RWR)
%         RWJC = [RWJC;RWR(i,:) + [WristOSx,RWristOSy,WristOSz]];
%     end
%     %------------------------------------------------------------------------
%     % Right radius bones
%     RRAz = REJC - RWJC;
%     RRAtemp = RFRM - RWJC;
%     RRAx = cross(RRAz,RRAtemp);
%     RRAy = cross(RRAx,RRAz);
%     RRAo = RWJC;
%
%     data.RRAO.line = RRAo;
%     data.RRAP.line = RRAy;
%     data.RRAA.line = RRAx;
%     data.RRAL.line = RRAz;
% end
% %__________________________________________________________________________
% %-------------------------------------------------------------------------
% % Temporary Left Hand bones
%
% if ismember({'LWRA','LWRB','LFIN'},chlist)
%
%     LWR = (LWRA+LWRB)/2;
%
%     LHNo = LFIN ;
%     LHNz = LWJC - LFIN;
%     LHNtemp = LWR - LFIN;
%     LHNy = cross(LHNz,LHNtemp);
%     LHNx = cross(LHNy,LHNz);
%
%     %-------------------------------------------------------------------------
%     % Left Hand origin centers
%     LHandOSx = -( mm + (LHandThickness/2));
%
%     LHC =[];
%
%
%     for i =1:length(LFIN)
%         LHC = [LHC;LFIN(i,:) + [LHandOSx,0,0]];
%     end
%     %-------------------------------------------------------------------------
%     % Left Hand bones %
%
%     LHNo = LHC ;
%     LHNz = LWJC - LHC;
%     LHNtemp = LWR - LHC;
%     LHNy = cross(LHNz,LHNtemp);
%     LHNx = cross(LHNy,LHNz);
%
%     data.LHNO.line = LHNo;
%     data.LHNP.line = LHNy;
%     data.LHNA.line = LHNx;
%     data.LHNL.line = LHNz;
%
% end
% %__________________________________________________________________________
%
% if ismember({'RWRA','RWRB','RFIN'},chlist)
%
%     RWR = (RWRA+RWRB)/2;
%     RHNo = RFIN ;
%     RHNz = RWJC - RFIN;
%     RHNtemp = RWR - RFIN;
%     RHNy = cross(RHNz,RHNtemp);
%     RHNx = cross(RHNy,RHNz);
%
%     %-------------------------------------------------------------------------
%     % Right Hand origin center
%
%     RHandOSx = -( mm + (RHandThickness/2));
%
%     RHC=[];
%
%     for i =1:length(RFIN)
%         RHC = [RHC;RFIN(i,:) + [RHandOSx,0,0]];
%     end
%
%     %-------------------------------------------------------------------------
%     % Right Hand bones %
%
%     RHNo = RHC ;
%     RHNz = RHC - RHC;
%     RHNtemp = RWR - RHC;
%     RHNy = cross(RHNz,RHNtemp);
%     RHNx = cross(RHNy,RHNz);
%
%     data.RHNO.line = RHNo;
%     data.RHNP.line = RHNy;
%     data.RHNA.line = RHNx;
%     data.RHNL.line = RHNz;
% end
%
% %--------------------------------------------------------------------------
%
%
% varout = data;
% fldv = fieldnames(varout);
% fldv = setdiff(fldv,'zoosystem');
% filt = filteroption(300);

% for i =1:length(fldv)
%     varout.(fldv{i}).line = filterline(data.(fldv{i}).line,filt);
% end






function anthro = getAnthro(data)

% ANTHRO = GETANTHRO(DATA) extracts anthropometric data from file.
%
% NOTES
% - These values must have been computed in vicon. Update to compute
%   from 'scratch'

anthro = data.zoosystem.Anthro;

