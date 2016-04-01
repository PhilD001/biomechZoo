
 
%% Step 1: Conversion to the Zoosystem format-----------------------------------------------
%

fld = uigetfolder;                                                         % '1-c3d2zoo'
del = 'yes';                                                               % delete original

c3d2zoo(fld,del)                                                           % run conversion

%% STEP 2: Prepare force plate data for analysis ---------------------------------------------
%
fld = uigetfolder;                                                           % '2-prep fpdata'

bmech_resample(fld,'Analog')                                                 % FP match kin 

bmech_forceplate2limbside(fld)


%% Step 3: Partitioning the data------------------------------------------------------------
%
fld    = uigetfolder;                                                     % '3-partition'
evt1 = 'Right_FootStrike1';                                                             % start event  
evt2   = 'Right_FootOff1';                                                           % end event 
subfld = 'Static';                                                        % no partition

% bmech_removefolder(fld,'Straight')                                             % rm static

% 
% bmech_addevent(fld,'RFz',evt1,'FS FP',subfld)                         % Finds FS and FO 
% bmech_addevent(fld,'RFz',evt2,'FO FP',subfld)                         % based on Fz signal


bmech_partition(evt1,evt2,fld,subfld)                                     % run function



%% STEP 4: Compute lower-limb kinematics
%
% - This steps computes ankle, knee, and hip joint kinematics using the
%   'kinemat' toolbox of Reinschmidt and Van den Bogert
%   see: http://isbweb.org/software/movanal/kinemat/
% - Additional 'virtual markers' representing the ankle (AnkleJC), knee (KneeJC), 
%   and hip (HipJC) are computed to allow kinematic computations
% 
fld = uigetfolder;                                                        % '4-kinematics'
Pelvis = {'RASI','LASI','SACR'};                                          % markers used to
Thigh  = {'KNE','THI','KneeJC','HipJC'};                                  % define each seg
Shank  = {'ANK','TIB','AnkleJC','KneeJC'};                                % for joint angle
Foot   = {'ANK','TOE','HEE','AnkleJC'};                                   % computations
sequence = 'yxz';

bmech_kinemat(fld,Pelvis,Thigh,Shank,Foot,sequence)                       % comp. kinematics


%% Step 5: Cleaning the data----------------------------------------------------------------
%
% - This step cleans up the zoo files by removing unwanted channels and by splitting 
%   (exploding) 3D channels into separate channels for easier analysis/plotting.
% - User should create a copy of folder '2-partition' called '3-clean'.

fld   = uigetfolder;                                                       % '5-clean'
chkp  = {'SACR','LASI','RASI','RKNE','LKNE','RTHI','LTHI',...
         'RTOE','LTOE','RHEE','LHEE',...
         'RANK','LANK','RTIB','LTIB','RHipJC','LHipJC',...
         'RKneeJC','LKneeJC','RAnkleJC','LAnkleJC',...
         'RHipKinemat','RKneeKinemat','RAnkleKinemat',...
         'RHipAngles','RKneeAngles','RAnkleAngles',...
         'LHipKinemat','LKneeKinemat','LAnkleKinemat',...
         'LHipAngles','LKneeAngles','LAnkleAngles'};               



bmech_removechannel('fld',fld,'chkp',chkp)                                 % two approaches

bmech_explode(fld,{'RHipKinemat','RKneeKinemat','RAnkleKinemat',...
         'RHipAngles','RKneeAngles','RAnkleAngles',...
         'LHipKinemat','LKneeKinemat','LAnkleKinemat',...
         'LHipAngles','LKneeAngles','LAnkleAngles'})                                                   % mx3 to 3 mx1


                                                     % '7-normalize'
nlength = 100;                                                             % 100% of stance

bmech_normalize(fld,nlength)


