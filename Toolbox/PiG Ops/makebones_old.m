function data = makebones_old(data)

% DATA = MAKEBONES(data) creates new 'bones' from marker data using the Vicon PiG conventions
% 
% NOTE
% - convention % 'O', 'A', 'L', 'P' 
 % - this function allows for unprocessed data to be used or to improve
%   calculations
% - only tested on data from OGL 
% - all values should be converted to millimeter

% Created October 2012 by Philippe C. Dixon


%---FOR TESTING-----
% %
if nargin==0
   grab;
end


%---DEFAULT VALUES---
%
mdiam = 14; % marker diameter
conv = 1000;

%---DEFINE MARKERS FOR CLARITY----
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



% TEST MARKERS
%

RHJC = data.RHJC.line;
LHJC = data.LHJC.line;

PELO = data.PELO.line;
PELA = data.PELA.line;
PELL = data.PELL.line;
PELP = data.PELP.line;



% Create pelvis
%
 pelo = (LASI + RASI)/2;
 pela = LASI - pelo;
 peltemp = SACR - pelo;
 pelp = cross(pela,peltemp);
 pell = cross(pela,pelp);

  
%--GET PELVIS COORDINATE SYSTEM---
%
ip = makeunit(pela - pelo);
jp = makeunit(pell - pelo);
kp = makeunit(pelp - pelo);

% %--MAKE GLOBAL COORIDNATE SYSTEM-------
% %
I = longunit(ip,'i');
J = longunit(ip,'j');
K = longunit(ip,'k');


%--EXTRACT ANTHROPOMETRIC INFO---

LLegLength = data.zoosystem.Anthro.LLegLength; % in m
RLegLength = data.zoosystem.Anthro.RLegLength; % in m



%--GET HIP JOINT CENTRE USING NEWINGTON-GAGE METHOD (CLOSE AGREEMENT)----

InterAsis = mean(magnitude(RASI-LASI)); % mm
MeanLegLength = mean([LLegLength RLegLength])*conv; % 

HJC = zeros(size(data.RASI.line));
vec_global = zeros(size(data.RASI.line));
side = {'R','L'};

for a = 1:length(side)
    
    LegLength = data.zoosystem.Anthro.([side{a},'LegLength'])*conv;
    AsisTrocDist = 0.1288*LegLength - 48.56;  % verified in Vicon
    C = MeanLegLength*0.115 - 15.3;
    aa = InterAsis/2;
    theta = 0.5;   % in radians
    beta = 0.314;  % in radians
    
    
    X = C*cos(theta)*sin(beta) - (AsisTrocDist + mdiam/2)*cos(beta);

    if a ==1
        Y = (C*sin(theta) - aa);
    else
        Y = -(C*sin(theta) - aa);
    end
    Z = -C*cos(theta)*cos(beta) - (AsisTrocDist + mdiam/2)*sin(beta);

    vec = [X,Y,Z];  % vector pointing from PELO to HJC in pelvis coordinates
    
    for b = 1:length(I)
        
        PLCS = [ip(b,:) ; jp(b,:) ; kp(b,:)];
        GCS = [I(b,:) ;  J(b,:) ; K(b,:)];
        vec_global(b,:) = ctransform(PLCS,GCS,vec);   % vector pointing from PELO to HJC in pelvis coordinates
    end
    
    data.([side{a},'HJCcalc']).line = PELO+vec_global;
    data.([side{a},'HJCcalc']).event = struct;
   
end


vect_pelvis = vec
vect_global = LHJC(1,:) - PELO(1,:)


%============ GET  HIP JOINT CENTRE USING HARRINGTON METHOD ========================
%
% ip = makeunit(PELA - PELO); % harrington pelvis system
% jp = makeunit(PELP - PELO);
% kp = makeunit(PELL - PELO);
% 
% mASIS = pointonline(RASI,LASI,0.5); % in GCS verified in director
% 
% PW = magnitude(RASI-LASI); % mm
% PD = magnitude(SACR-mASIS);
%    
% RLL =ones(size(row)).*(data.zoosystem.Anthro.RLegLength*conv);
% 
% rxhat = -0.24.*PD-9.9;
% ryhat = -0.16.*PW - 0.04.*RLL - 7.1;
% rzhat = -0.28.*PD+0.16.*PW+7.9;
% rhat = [rxhat ryhat rzhat];
% 
% LLL =ones(size(row)).*( data.zoosystem.Anthro.LLegLength*conv);
% lxhat = -0.24.*PD-9.9;
% lyhat = -0.16.*PW - 0.04.*LLL + 7.1;
% lzhat = -0.28.*PD+0.16.*PW+7.9;
% lhat = [lxhat lyhat lzhat];
% 
% RHJChar = zeros(size(mat));
% LHJChar = zeros(size(mat));
% 
% for i = 1:length(row)
%    
%      PLCS = [ip(i,:) ; jp(i,:) ; kp(i,:)];
%      GCS = [I(i,:) ;  J(i,:) ; K(i,:)];
%      RHJChar(i,:) = ctransform(PLCS,GCS,rhat(i,:));   % 
%      LHJChar(i,:) = ctransform(PLCS,GCS,lhat(i,:));   % 
% 
% end
% 
% data.RHJChar.line = RHJChar;
% data.RHJChar.event = struct;
% 
% 
% data.LHJChar.line = LHJChar;
% data.LHJChar.event = struct;
% 
% data.mASIS.line  = mASIS;
% data.mASIS.event = struct;


%============ GET KNEE JOINT CENTRE USING VICON CHORD FUNCTION=======================
%
% - work on this later, Leitch method is best anyway

%============ GET KNEE JOINT CENTRE USING LEITCH METHOD==============================
%
% - verified in director. Slight offset with PiG kne (FEO)
% - code could be sped up 
RKJC = GetKneeJointCentreLeitch(RHJC,RTHI,RKNE,RKneeWidth,mdiam);
LKJC = GetKneeJointCentreLeitch(LHJC,LTHI,LKNE,LKneeWidth,mdiam);


%=========== ADD TO ZOOSYSTEM ======================================================

data.RFEOleitch.line = RKJC;
data.RFEOleitch.event = struct;


data.LFEOleitch.line = LKJC;
data.LFEOleitch.event = struct;


% 
% 
% if ismember({'RSTL'},ch)
% 
% disp('creating segments for Oxford foot model')
% disp(' ')
% 
% 
% %=====RTibia Segment====
% % 
% RTI3 = (data.RKNE.line + data.RMCK.line)/2;   % NEAR 'RFEO', RTIB3  ... VERIFIED
% RTI0 = (data.RANK.line + data.RMMA.line)/2;   % SAME AS 'RAJC'      ... VERIFIED
%  
% dis =  magnitude(data.RMMA.line - data.RANK.line)/2; % points laterally
% one = ones(length(RTI0),1);
% zero = zeros(length(RTI0),1);
% 
% RTI2 = RTI0 - [dis zero  zero];     % points proximally
% % RTI3 = data.RTIB3.line/100;
% % RTI2 = data.RTIB2.line/100; % cheating
% 
% RTI1 =cross(RTI2,RTI3);   % mutually perpendicular to p and l 
% 
% % plot(RTI1)
% % title( 'my calc')
% % 
% % figure
% % plot(data.RTIB1.line)
% % title('vicon calc')
% 
% % data.RKJc.line = RKJC;
% % data.RAJc.line = RTIo;
% 
% nch = {'RTI0','RTI1','RTI2','RTI3'};
% %----add to data
% 
% for i = 1:length(nch)
%     data.(nch{i}).line = eval(nch{i});    
% end

% data.RTI0.line = RTI0;   % origin of TIB is AJC
% data.RTI1.line = RTI1;
% data.RTI2.line = RTI2;
% data.RTI3.line = RTI3;   % primary axis points to KJC% 


% data.RTI0.line = RTI0;   % origin of TIB is AJC
% data.RTI1.line = RTI1;
% data.RTI2.line = RTI2;
% data.RTI3.line = RTI3;   % primary axis points to KJC% 


%======RHindFoot Segment=====
   
% RHF0 = data.RHEE.line;    % SAME AS 'RHDFO' VERIFIED
% 
% RCAm = (data.RSTL.line + data.RLCA.line)/2;   % midpoint between RSTL and RLCA
% 
% RHFp = RCAm - data.RHEE.line;   % make a vector in plane of RHEE, PCA; and midpoint between STL and LCA
% RHFf = data.RD5M.line - data.RHEE.line;   %  a vector parallel to floor? 
% RHFp = proj(RHFp,RHFf);   % projection of RHFp parallel to RHFf 
% 
% t1 = RCAm-data.RHEE.line;
% t2 = data.RPCA.line-data.RHEE.line;
% RHFl = cross(t1,t2,2); % points laterally
% 
% RHFa = cross(RHFl,RHFp,2);
% 
% data.RHF0.line= RHFo;
% data.RHFa.line = RHFa;
% data.RHFl.line = RHFl;
% data.RHFp.line = RHFp;
% 


%======RForeFoot Segment========
% all garbage
% RFFo = (data.RP5M.line + data.RP1M.line)/2; 
% 
% RFFp = data.RTOE.line - RFFo;
% % RFFx = projvecpln(RFFx,[data.RP5M.line data.data.RD5M.line data.RD1M.line]);
% 
% RFFa = RFFo; % garbage output to make function run     normpln([data.RP5M.line data.data.RD5M.line data.RD1M.line]);
% RFFa = displace(RFFp,RFFo);
% 
% RFFl = cross(RFFp,RFFa,2);
% 
% data.RFFo.line=  RFFo;
% data.RFFa.line = RFFa;
% data.RFFl.line = RFFl;
% data.RFFp.line = RFFp;



%====RHallux Segment ====

% RHLX = data.RHLX.line - data.RD1M.line;
% 
% data.RHLo.line=  data.RD1M.line;
% data.RHLp.line=  RHLX;



% end
  