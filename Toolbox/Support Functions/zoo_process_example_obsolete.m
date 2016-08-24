% ZOO_PROCESS_EXAMPLE demonstrates the basic tools available in BiomechZoo by processing
% data for a hypothetical study.
%
% NOTES
% - BiomechZoo folders should be added to the MatLab path before starting the demo.
%   This can be accomplished by running startZoo.m (located in the root BiomechZoo folder)
% - Sample data must first be downloaded <a href="https://github.com/PhilD001/the-zoosystem-samplestudy">here</a>
% - Run mode ('auto' or 'manual'). If input set to 'auto' all processing 
%             steps are run automatically without user input: zoo_process_example('auto').
%             The 'auto' option is useful to verify a the toolbox has been correctly loaded into the Matlab path.
%
%
%- Each processing step should operate on a new folder (manual mode). This allows the user to
%   retain the original data. Also, the user can keep track of the changes performed throughout
%   the processing procedure. All steps are included in the download to help users trouble-
%   shoot individual problems.
% - The user is encouraged to first run through each step to understand the procedure.
% - The advanced user may also want to explore the underlying code of each function.
%
%
% THE STUDY
% - 12 subjects were asked to perform straight walking (Straight) and 90 degree turning
%   while walking (Turn) trials in a typical motion capture environment while fit with the
%   Plug-in Gait (PiG) markers.
% - For the purposes of this demo, we will hypothesize that there are differences between
%   conditons for:
%   (1) Maximum medio-lateral ground reaction force (GRF_ML)
%   (2) Maximum hip adduction in stance (Hip_ADD)
%   (3) Knee flexion angle at foot-off (Knee_FLX)
%
% - Step 1-7 processes the data for analysis
% - Step 8 (The visualization section) presents the two main graphical user interfaces
%   (GUIs) of the zoosystem: 'ensembler' and 'director'.
% - Step 9 (The statistical analysis section) demonstrates how to export data to be read
%   by thrid party statistical programs such as SPSS or R.
%
% Created by Philippe C. Dixon November 2013
%
% Last updated by Philippe C. Dixon August 2nd 2016
% - Improved help
% - Included hyperlinks
% - Added processes for comparsion with PiG outputs
% - Added 'auto' mode
%
% see https://github.com/PhilD001/the-zoosystem for the latest version of the code
% and associated help files
%
%
%
% License, citations, and latest version information, type 'zooinfo'



%% Step 0: Set run mode -----------------------------------------------------------------------
%
% - If mode is set to 'auto', all processes will apply to the new folder called 
%   'zoo files (auto process)' created in this step
% - If mode is set to 'manual', the user can run each cell (step 1-9) indivdually, each time
%   manually copying a new folder iteratively for each step

mode = 'manual';                                                           % run cell by cell
%mode = 'auto';                                                               % run whole script

if strfind(mode,'auto')
    fld = uigetfolder('select ''raw c3d files''');
    tic
    indx = strfind(fld,filesep);
    folder = fld(indx(end)+1:end);
    tfld = strrep(fld,folder,'zoo files (auto process)');
    copyfile(fld,tfld)
    fld = tfld;
    cd(fld)
end


%% Step 1: Conversion to the Zoosystem format -------------------------------------------------
%
% - In this step, we convert data from origial format (.c3d) to zoosystem format (.zoo).
% - User should create a copy of folder 'raw c3d files' called '1-c3d2zoo'. This will allow
%   us to return to the original data at any time.
if strfind(mode,'manual')
    fld = uigetfolder('select ''1-c3d2zoo''');
end

del = 'yes';                                                                 % delete original

c3d2zoo(fld,del)                                                             % run conversion

% User notes:
% - Explore the structure of a raw zoo file by typing 'grab' and selecting any file.


%% STEP 2: Clean ------------------------------------------------------------------------------
%
% - removes channels not needed for current study (speeds up processing)
if strfind(mode,'manual')
    fld = uigetfolder('select ''2-initial clean''');
end

ofld = {'vsk'};                                                     % not needed

ch = {'LFHD','LBHD','RFHD','RBHD','C7','T10','T12','RBAK','CLAV','STRN',...  % PiG markers
      'LSHO','LELB','LWRA','LWRB','LFIN','RSHO','RELB','RWRA','RWRB',...
      'RFIN','SACR','RASI','LASI','LTHI','LTIB','LKNE','LANK','LHEE',...
      'LTOE','RTHI','RTIB','RKNE','RANK','RHEE','RTOE',...
      'RHJC','LHJC','RFEO','LFEO','RTIO','LTIO',...                          % PiG jnt center
      'LPelvisAngles','LHipAngles','LKneeAngles','LAnkleAngles',...          % PiG kinematics
      'RPelvisAngles','RHipAngles','RKneeAngles','RAnkleAngles',...
      'LHipForce','LKneeForce','LAnkleForce','LHipMoment','LKneeMoment',...  % PiG kinetics
      'LAnkleMoment','LHipPower','LKneePower','LAnklePower','RHipForce',...
      'RKneeForce','RAnkleForce','RHipMoment','RKneeMoment',...
      'RAnkleMoment','RHipPower','RKneePower','RAnklePower',...   
      'LGroundReactionForce','LGroundReactionMoment',...                     % PiG proc GRF
      'RGroundReactionForce','RGroundReactionMoment',...
      'ForceFx1','ForceFy1','ForceFz1','MomentMx1','MomentMy1',...           % raw GRF
      'MomentMz1','ForceFx2','ForceFy2','ForceFz2','MomentMx2',...
      'MomentMy2','MomentMz2'};
    
bmech_removechannel(fld,ch,'keep')

bmech_removefolder(fld,ofld)                                                 % rm static

 
%% Step 3: Partitioning the data --------------------------------------------------------------
%
% - This step limits the analysis to a single stance phase for the right limb.
% - Data are partitionned based on right limb force plate hits.
% - The subfolder 'sfld' will be ignored (i.e., not partitioned, because static data do not
%   contain gait data and do not need to be partitionned).
% - The user should create a copy of folder '2-initial clean' called '3-partition'.

if strfind(mode,'manual')
    fld  = uigetfolder('select ''3-partition''');
end

sfld  = 'Static';                                                            % no partition
evtn1 = 'RFS';                                                               % start evt name
evtn2 = 'RFO';                                                               % end evt name
evtt1 = 'RFS_FP';                                                            % start evt type
evtt2 = 'RFO_FP';                                                            % end evt type
ch    = 'SACR';                                                              % event channel

bmech_forceplate2limbside(fld);

bmech_addevent(fld,ch,evtn1,evtt1,sfld)                                      % Find FS and FO
bmech_addevent(fld,ch,evtn2,evtt2,sfld)                                      % based on Fz sig

bmech_partition(fld,evtn1,evtn2,sfld)                                        % run function

% User notes:
% - After processing, all files show data over the stance phase of the right limb (left will
%   be in swing). Check by plotting, for example the vertical component of the ground reaction
%   force 'plot(data.RightGroundReactionForce.line(:,3))'.
% - The field data.zoosystem.Video is updated to reflect the parititonning:
%   ORIGINAL_START_FRAME and ORIGINAL_END_FRAME refer to the frames captured in Vicon. The
%   ORIGINAL_START_FRAME is considered the first frame BiomechZoo. Thus, the
%   CURRENT_START_FRAME indicates how many frames were cut from the start in partionning.
% - Analog channels sampled at 1000 Hz were downsampled by bmech_resample before
%   partitionning and therefore reflect correct partition points.
% - The dataset also includes, for some files, events that were manually identified in Vicon
%   ('Right_FootStrike1' and 'Right_FootOff1'). The user can check that these are similar
%   to the events identified here.


%% STEP 4: Computing joint kinematics and kinetics --------------------------------------------
%
% - This steps computes ankle, knee, and hip joint kinematics using two approaches:
%   (1) 'kinemat' toolbox see: http://isbweb.org/software/movanal/kinemat/
%   (2) custom code made to reproduce the PiG outputs
% - Ankle, knee, and hip joint centres are also computed to supported kinematic calculations
% - The user should create a copy of folder '3-partition' called '4-kinemat'.

if strfind(mode,'manual')
    fld = uigetfolder('select ''4-computations''');
end

sfld = {'Static'};                                                     % no partition

Pelvis = {'RASI','LASI','SACR'};                                             % markers used to
Thigh  = {'KNE','THI','HipJC'};                                              % define each seg
Shank  = {'ANK','TIB','KneeJC'};                                             % for kinemat
Foot   = {'ANK','TOE','HEE'};                                                % computations
joints = {'HipJC','KneeJC','AnkleJC'};
sequence = 'yxz';                                                            % Euler sequence

bmech_jointcentrePiG(fld,joints)                                             % Joint centres

bmech_kinematicsRvdB(fld,Pelvis,Thigh,Shank,Foot,sequence)                   % run kinemat

bmech_kinematics(fld)                                                        % run PiG kinemat

bmech_kinetics(fld)                                                          % run PiG kinetics

bmech_removefolder(fld,sfld)                                                 % rm static


% User notes:
% - This step demonstrates the kinematic tools available in BiomechZoo
% - Joint kinematics are computed from 'raw' marker data (labelled and gap filled); however,
%   the existing anthropometric within the c3d file were used to support the calculations.
%   A truly 'raw' process would need to include a step in which anthropometric information is
%   added to the data.zoosystem.Anthro branch
% - This dataset also contains kinematc quantities computed by the Pig modeller. These can be
%   used to compare the present calculations.
% - The angles (right side only) output by the kinemat function were offset by the static
%   PiG angles in order to better compare the processes.


%% Step 5: Adding events ----------------------------------------------------------------------
%
% - In this step, discrete events along the curves are identified for statistical analysis
%   (see hypotheses).
% - User should create a copy of folder '5-clean' called '6-add events'.

if  strfind(mode,'manual')
    fld = uigetfolder('select ''6-add events''');
end

bmech_explode(fld)                                                           % n x 3 to 3 n x 1

bmech_addevent(fld,'RightGroundReactionForce_x','min','min')                 % min val stance
bmech_addevent(fld,'RightHipAngle_y','max','max')                            % max val stance

% User notes:
% - Local events have been added to the event branch of the channels selected. Users can
%   explore data by typing 'grab', selecting a file and plotting using 'zplot', e.g.:
%   'zplot(data.RHipAngles_y)'. See ~\Sample Study\figures\zplot_figure_example.fig'
% - An event does not need to be added for knee flexion at foot-off because this event
%   already exists ('RFO' identified in step 3 or 'Right_Foot_Off1' identified in Vicon).
%   This kind of event is referred to as a 'global event' and can be accessed by any channel.


%% Step 6: Normalizing the data ---------------------------------------------------------------
%
% - This step normalizes data to a single length of 101 frames (0-100% stance phase)
% - User should create a copy of folder '6-add events' called '7-normalize'

if  strfind(mode,'manual')
    fld = uigetfolder('select ''6-normalize''');
end

nlength = 100;                                                               % 100% of stance
method = 'linear';                                                           % interp method
ch = 'all';                                                                  % norm all channels

bmech_normalize(fld,ch,nlength,method)


%% Step 7: Visualization -------------------------------------------------------------------
%
% - Now that the processing is complete, it is important to visualize the data to check for
%   errors/problems. This can be done using the 'ensembler' and 'director' tools.
%
% ENSEMBLER (PART 1):
% - The main GUI in the zoosystem is 'ensembler'. For this example, follow instructions:
%   (1)  Type 'ensembler' in the Matlab command window. A window pops up with some settings
%   (2)  Change the 'name' field to 'Straight' 'turn', rows to '1', and columns to '3' (all
%        without quotes) and click 'OK'. This will create two generic figure windows, each
%        with three empty axes. To resize figure windows and axes to your liking, select
%        'restart' from the 'File' menu on the main figure window and edit sizing options
%   (3)  Select 'Axes' --> 're-tag'. Choose any zoo file from the step 7 folder. This opens
%        a window for you to select which channel(s) to view in ensembler. Associate
%        'RightHipAngle_y', 'RightKneeAngle_x', and 'RForceFx' to the generic axes '1 1', '1 2', '1 3'
%        and select 'ok'. The axes of each figure will be updated.
%   (4)  In the main menu of either figure window, choose 'File'-->'load data' and select
%        the step 7 folder. This will allow ensembler to populate the axes with
%        corresponding data. For example, the 'RightHipAngle_y' axes of figure 'Turn' contains
%        only the RightHipAngle_y data for the turn condition
%   (5)  For now, ignore the events by selecting 'Events' --> 'clear all events'. Only the
%        line data remain.
%   (6)  One line for RightGroundReactionForce_x of the Turn condition appears separate from
%        the others. Left click on the trace to identify the trial (HC002D25.zoo).  We will
%        see later why this trace is different, but for now let's assume it is an outlier that
%        should be removed. This could be done by deleting the file in an explorer window
%        (or mac finder), but the rest of the data (hip and knee angles) appear
%        unaffected and should not be deleted. In ensembler, left click on the trial,
%        press 'delete' on the  keyboard and select 'Delete Channel'. This will replace
%        all line and event data in this channel with 999 values (check
%        using grab). For comparison purposes, this process should be
%        repeated for RGroundReactionForce_x (the vicon output)
%   (7)  Select 'Ensembler' --> 'Ensemble (SD)' and the 'Ensembler' --> 'combine data' to
%        graph the average of both conditions together. Line styles and colors can be
%        updated via the 'Line' menu. Change the colors and styles to easily differentiate
%        the conditons.
%   (8)  Add a legend by selecting 'Insert' --> 'legend'
%   (9)  Finalize graphs by exploring the menu bar options or by selecting Edit, property
%        editor on.
%   (10) Save the figure by selecting File, save fig or export to pdf format by selecting
%        File, export.
%        See ensembler_line_example.fig and .pdf in the 'Figures' subfolder of the sample study
%        data set for sample outputs

% DIRECTOR
% - The other zoosystem GUI is called 'director'. Director is a 3D virtual environment for
%   visualization of 3D motion data. Out of the box, it can animate motion trials for
%   plug-in gait data, but can be updated by advanced users for use with other datasets.
% - Let us explore a few trials from the dataset by following these steps:
%  (1) Type 'director' (make sure ensembler is closed) from the command window. This opens
%      up a blank 3D canvas.
%  (2) Select 'Load File' and choose a file from the step 1 folder.
%  (3) Choose 'lower-limbs' and then select a few markers to display from the list (e.g.
%      'RP1M','RP5M', and 'RTOE'). This will load a skeleton and markers associated with the
%      trial. Director detects the position of force plates in the file and also displays
%      them in the 3D environment. Select a channel from the top-left channel list to
%      display its graph. Click 'Play' to start the animation.
%  (4) Repeating this process for a number of trials (including our so-called outlier)
%      reveals that in trial 'HC002D25.zoo' the subject walked in the opposite direction to
%      the others. This direction change was responsible for seemingly incorrect force
%      profile. A function could be written to rotate GRF to a single (global) orientation
%      in a real study.

% ENSEMBLER (PART 2)
% - We are interested in extracting discrete points along the curves (see hypotheses).
%   Follow the steps below to crete bar graphs for the given events
%  (1) Repeat steps 1-4, but this time only load the RHipAngles_y data
%  (2) Select Ensembler --> Ensemble (CI) then Ensembler, combine data to show a mean and
%      confidence interval (CI) curve for each condition on a single axis.
%  (3) Select 'Bar Graph' --> 'bar graph' to display these discrete data.
%  (4) Finalize, and save graphs using steps 8-10 from the time-series graphing instructions

if strfind(mode,'auto')
    out_file = [fld,filesep,'HC002D',filesep,'Turn',filesep,'HC002D25.zoo'];
    ch = {'RightGroundReactionForce_x','RGroundReactionForce_x'};
    outlier(out_file,ch)
end


%% Step 8: Statistical analysis ------------------------------------------------------------
%
% - After analysis and visualization of data is complete, it is now possible to export the
%   data for statistical analysis
%
% METHOD A: Exporting to spreadsheet (using the eventval function)
%
if strfind(mode,'manual')
    fld = uigetfolder('select ''6-adding events''');
end

levts = {'min','max'};                                                       % local events
gevts = {'RFO'};                                                             % global events
aevts = {'Bodymass','Height'};                                               % anthro events
ch    = {'RightGroundReactionForce_x','RightHipAngle_y','RightKneeAngle_x'}; % channel to search
dim1  = {'Straight','Turn'};                                                 % conditions
dim2  = {'HC002D','HC030A','HC031A','HC032A','HC033A','HC036A',...           % subjects
         'HC038A','HC039A','HC040A','HC044A','HC050A','HC055A'};
    
excelserver = 'off';                                                         % use java
ext = '.xls';                                                                % preferred ext

eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
    'globalevts',gevts,'anthroevts',aevts,'ch',ch,'excelserver',excelserver,...
    'ext',ext)

% User notes:
% - If you run into problems take a look at the exisiting 'eventval.xls' file
% - Non-existant events (e.g. 'max' for RKneeAngles_x') and outliers will show as 999 values
% - Check that data in excel sheet matches zoo data using grab
% - This sheet can be imported into SPSS to test the hypotheses...what do you find?
% - On mac or if excel is not installed on computer, 'excelserver' must be set to 'off'


% METHOD B: Analysis within the Matlab environment (using extractevents.m)
%
%
% RightGroundReactionForce_x maximum (GRF_ML)
%
ch  = 'RightGroundReactionForce_x';
evt = 'min';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_GRF_ML] = ttest(r.Straight,r.Turn,0.05,'both');                    % p-val = 0.006*
disp(['p-value for GRF_ml = ',num2str(pval_GRF_ML)])

% RHipKinemat maximum (Hip_ADD)
%
ch  = 'RightHipAngle_y';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Hip_ADD] = ttest(r.Straight,r.Turn,0.05,'both');                  % p-val = 0.033*
disp(['p-value for Hip_ADD = ',num2str(pval_Hip_ADD)])

% RKneeAngle_x at foot off (Knee_FLX)
%
ch  = 'RightKneeAngle_x';
evt = 'RFS';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Knee_FLX] = ttest(r.Straight,r.Turn,0.05,'both');                   % p-val = 0.356
disp(['p-value for Knee_FLX = ',num2str(pval_Knee_FLX)])

if strfind(mode,'auto')
    disp(' ')
    disp('**********************************')
    disp('Finished running demo program in : ')
    toc
    disp('**********************************')
end

