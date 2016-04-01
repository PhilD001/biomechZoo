% ======= Biomechanics Zoosystem Toolbox Demo Processing Script ============================

% NOTES:
% - This script demonstrates the basic tools available in the Biomechanics Zoosystem Toolbox 
%   by processing data for a hypothetical study.
% - All folders and subfolders of the "Biomechanics Zoosystem Toolbox" folder should be 
%   added to the MatLab path before starting the demo script. Windows users should then 
%   remove the subfolder 'Mac Fixes' from the path.
% - Sample data is contained in the 'raw c3d files' folder.
% - Each processing step should operate on a new folder. This allows the user to retain 
%   the original data. Also, the user can keep track of the changes performed throughout 
%   the processing procedure. All steps are included in the download to help users trouble-
%   shoot individual problems.
% - The user is encouraged to first run through each step to understand the procedure. 
% - The advanced user would also want to explore the underlying code of each function.
% - Further information about the zoosystem can be found in:
%   ~\the zoosystem\Help Files\zoo_presentation.ppt'

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
% Last updated by Philippe C. Dixon April 1st 2016
% - Improved user interface and help
% - Improved statistical analysis section
% - Added additional processing steps (joint kinematics, filtering) to
%   demonstrate that the Zoossytem can be used to fully process and analyze 'raw' data 
%   (markers gap filled and filtered)
%
% see https://github.com/PhilD001/the-zoosystem for the latest version of the code
% and associated help files
%
% License, citations, and latest version information, type 'zooinfo'
 

%% Step 1: Conversion to the Zoosystem format ----------------------------------------------
%
% - In this step, we convert data from origial format (.c3d) to zoosystem format (.zoo).
% - User should create a copy of folder 'raw c3d files' called '1-c3d2zoo'. This will allow 
%   us to return to the original data at any time.

fld = uigetfolder;                                                         % '1-c3d2zoo'
del = 'yes';                                                               % delete original

c3d2zoo(fld,del)                                                           % run conversion

% User notes: 
% - Explore the structure of a raw zoo file by typing 'grab' and selecting any file.


%% STEP 2: Processing force plate data ------------------------------------------------------
%
% - In this step, ground reaction forces are processed for later analysis (see hypotheses): 
%   (1) Basic filtering
%   (2) Normalizing to mass (N/kg)
%   (2) Downsampling to match kinematics
%   (3) Association of foot to force plate
% - User should create a copy of folder '1-c3d2zoo' called '2-prep fpdata'.

fld = uigetfolder;                                                         % '2-process fpdata'
filt.cutoff = 20;                                                          % filter settings 
filt.ftype  = 'butterworth';                                               % see function
filt.forder = 4;                                                           % for list of all
filt.pass   = 'low';                                                       % filter choices
ch_fp = {'Fx1','Fy1','Fz1','Fx2','Fy2','Fz2'};

bmech_filter('fld',fld,'filt',filt,'chfilt',ch_fp)                         % filter

bmech_massnormalize(fld,ch_fp,'Forces')                                    % convert to N/kg

bmech_resample(fld,'Analog')                                               % FP match kin 

bmech_forceplate2limbside(fld)                                             % assoc limbs

% User notes:
% - This dataset also includes 'RGroundReactionForce' and 'LGroundReactionForce' channels.
%   These are PiG modeller created channels that were filtered, mass normalized and 
%   dowwnsampled. The process here recreates these steps from the raw force data.  


%% Step 3: Partitioning the data -----------------------------------------------------------
%
% - This step limits the analysis to a single stance phase for the right limb.
% - Data are partitionned based on right limb force plate hits.
% - The subfolder 'subfld' will be ignored (data within will not be
%   partitioned). Static data does not contain partition events and does not need
%   to be partitionned. 
% - The user should create a copy of folder '2-prep fpdata' called '3-partition'.

fld = uigetfolder;                                                         % '3-partition'
evt1 = 'RFS';                                                              % start event  
evt2 = 'RFO';                                                              % end event 
subfld = 'Static';                                                         % no partition

bmech_addevent(fld,'RFz',evt1,'FS FP',subfld)                              % Finds FS and FO 
bmech_addevent(fld,'RFz',evt2,'FO FP',subfld)                              % based on Fz sig

bmech_partition(evt1,evt2,fld,subfld)                                      % run function

% User notes:
% - The call to bmech_addevent determines which foot is 'associated' with which force plate
%   using a kinematic algoritm (see ZeniEventDetect.m). The information is stored in 
%   data.zoosystem.CompInfo. Later, this will be used to identify the correct force plate.  
% - After processing, all files show data over the stance phase of the right limb (left will
%   be in swing). Check by plotting, for example 'RFz': 'plot(data.RFz.line)'. 
% - The field data.zoosystem.Video is updated to reflect the parititonning: 
%   ORIGINAL_START_FRAME and ORIGINAL_END_FRAME refer to the frames captured in Vicon. The
%   ORIGINAL_START_FRAME is considered the first frame in the Zoosystem. Thus, the 
%   CURRENT_START_FRAME indicates how many frames were cut from the start in partionning.
% - Analog channels sampled at 1000Hz were downsampled by bmech_resample before 
%   partitionning and therefore reflect correct partition points. 
% - The dataset also included events that were manually identified in Vicon 
%   ('Right_FootStrike1' and 'Right_FootOff1'). The user can check that these are similar 
%   to the events identified here.


%% STEP 4: Computing joint kinematics -------------------------------------------------------
%
% - This steps computes ankle, knee, and hip joint kinematics using the 'kinemat' toolbox 
%   of Reinschmidt and Van den Bogert, see: http://isbweb.org/software/movanal/kinemat/
% - Additional 'virtual markers' representing the ankle (AnkleJC), knee (KneeJC), 
%   and hip (HipJC) are computed to allow kinematic computations
% - The user should create a copy of folder '3-partition' called '4-kinemat'.

fld = uigetfolder;                                                         % '4-kinemat'
Pelvis = {'RASI','LASI','SACR'};                                           % markers used to
Thigh  = {'KNE','THI','HipJC'};                                            % define each seg
Shank  = {'ANK','TIB','KneeJC'};                                           % for joint angle
Foot   = {'ANK','TOE','HEE'};                                              % computations
joints = {'HipJC','KneeJC'};
sequence = 'yxz';

bmech_jointcentrePiG(fld,joints)                                           % adds hip joint

bmech_kinemat(fld,Pelvis,Thigh,Shank,Foot,sequence)                        % comp. kinematics

% User notes:
% - This step has been included to demonstrate that the zoosystem can be used on 'raw' data,
%   i.e., data that contain only marker data (labelled and gap filled). This dataset also 
%   contains joint centres/angles computed by the Pig modeller that could be used instead. 
% - Joint kinematics from the kinemat toolbox are assumed to be 'valid'. It is left as an 
%   exercise to the user to compare these outputs to the PiG. 
% - bmech_kinemat as implemented here relies on virtual joint center markers (not present in
%   'raw data'. These were computed from marker data as described in the PiG user manual 
% - bmech_kinemat relies on Matlab's symbolic math toolbox to compute the PiG 'Chord' 
%   function. If this toolbox is unavailable other algorithms must be considered.
% - PiG information (leg length and marker diameteter) must be exported to original c3d file
%   or appended in a custom step for correction functionality
% - Comparison of kinemat and PiG output is shown in PiGvsKinemat_Straight.pdf and 
%   PiGvsKinemat_Turn.pdf stored in \Sample Study\Figures\ 


%% Step 5: Cleaning the data ---------------------------------------------------------------
%
% - This step cleans up the zoo files by removing unwanted channels and by splitting 
%   (exploding) 3D channels into separate channels ('_x','_y', and '_z' for easier analysis
%   and plotting.
% - User should create a copy of folder '4-kinemat' called '5-clean'.

fld   = uigetfolder;                                                       % '5-clean'
subfld = 'Static';                                                         % no partition
chkp  = {'RFx','RFy','RFz','SACR','LASI',...                               % chns to keep
         'RHipKinemat','RKneeKinemat','RAnkleKinemat',};               

bmech_removefolder(fld,subfld)                                             % rm static

bmech_removechannel('fld',fld,'chkp',chkp)
bmech_removechannel('fld',fld,'chrm','LASI')

bmech_explode(fld)                                                         % mx3 to 3 mx1

% User notes:
% - All files now contain a single channel for marker data ('SACR'), channels for each 
%   dependent variable to be analysed (exploded into three mx1 subchannels), and additonal 
%   ankle angles ('RAnkleKinemat', also exploded)
% - The 'zoosystem' metainformation channel is never removed by 'bmech_removechannel'


%% Step 6: Adding events -------------------------------------------------------------------
%
% - In this step, discrete events along the curves are identified for statistical analysis
%   (see hypotheses).
% - User should create a copy of folder '5-clean' called '6-add events'.

fld = uigetfolder;                                                         % '6-add events'

bmech_addevent(fld,'RFx','min','min')                                      % min val stance
bmech_addevent(fld,'RHipKinemat_y','max','max')                            % max val stance

% User notes:
% - Local events have been added to the event branch of the channels selected. Users can 
%   explore data by typing 'grab', selecting a file and plotting using 'zplot', e.g.:
%   'zplot(data.RHipAngles_y)'. See ~\Sample Study\figures\zplot_figure_example.fig' 
% - An event does not need to be added for knee flexion at foot-off because this event 
%   already exists ('RFO' identified in step 3 or 'Right_Foot_Off1' identified in Vicon).
%   This kind of event is referred to as a 'global event' and can be accessed by any channel.


%% Step 7: Normalizing the data ------------------------------------------------------------
%
% - This step normalizes data to a single length of 101 frames (0-100% stance phase)
% - User should create a copy of folder '6-add events' called '7-normalize'

fld = uigetfolder;                                                         % '7-normalize'
nlength = 100;                                                             % 100% of stance

bmech_normalize(fld,nlength)

% User notes:
% - Different interpolation methods can be implemented in bmech_normalize via an optional
%   (third) argument


%% Step 8: Visualization -------------------------------------------------------------------
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
%        'RHipKinemat_y', 'RKneeKinemat_x', and 'RFx' to the generic axes '1 1', '1 2', '1 3'
%        and select 'ok'. The axes of each figure will be updated.
%   (4)  In the main menu of either figure window, choose 'File'-->'load data' and select
%        the step 7 folder. This will allow ensembler to populate the axes with
%        corresponding data. For example, the 'RHipKinemat_y' axes of figure 'Turn' contains 
%        only the RHipKinemat_y data for the turn condition 
%   (5)  For now, ignore the events by selecting 'Events' --> 'clear all events'. Only the 
%        line data remain. 
%   (6)  One line for RFx of the Turn condition appears separate from the others. Left click
%        on the trace to identify the trial (HC002D25.zoo).  We will see later why this 
%        trace is different, but for now let's assume it is an outlier that should be 
%        removed. This could be done by deleting the file in a standard window explorer 
%        (or mac finder) window, but the rest of the data (hip and knee angles) appear 
%        unaffected and should not be deleted. In ensembler, left click on the trial, 
%        press 'delete' on the  keyboard and select 'Delete \ Channel'. This will replace 
%        all line and event data in this channel with 999 values (check using grab).
%   (7)  Select 'Ensembler' --> 'Ensemble (SD)' and the 'Ensembler' --> 'combine data' to 
%        graph the average of both conditions together. Line styles and colors can be 
%        updated via the 'Line' menu. Change the colors and styles to easily differentiate 
%        the conditons. 
%   (8)  Add a legend by selecting 'Insert' --> 'legend'  
%   (9)  Finalize graphs by exploring the menu bar options or by selecting Edit, property 
%        editor on.
%   (10) Save the figure by selecting File, save fig or export to pdf format by selecting 
%        File, export.
%        See ~\Sample Study\figures\ensembler_line_example.fig and .pdf for sample outputs

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
%      the others. This direction change was rsponsible for seemingly incorrect force 
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


%% Step 9: Statistical analysis ------------------------------------------------------------
%
% - After analysis and visualization of data is complete, it is now possible to export the
%   data for statistical analysis
%
% METHOD A: Exporting to spreadsheet (using the eventval function)
%
fld = uigetfolder;                                                         % '6-add events'
levts = {'min','max'};                                                     % local events                                            
gevts = 'RFS';                                                             % global events                                       
aevts = {'Bodymass','Height'};                                                          % anthro events
ch = {'RFx','RHipKinemat_y','RKneeKinemat_x'};                             % channel to search
dim1 = {'Straight','Turn'};                                                % conditions
dim2 = {'HC002D','HC030A','HC031A','HC032A','HC033A',...          % subjects
        'HC036A','HC038A','HC039A','HC040A','HC044A','HC050A',...
        'HC055A'};
excelserver = 'off';                                                       % use java
ext = '.xls';                                                              % preferred ext

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
% RGroundReactionForce_x maximum (GRF_ML)
%
ch = 'RFx';
evt = 'min';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_GRF_ML] = ttest(r.Straight,r.Turn,0.05,'both');
disp(['p-value for GRF_ml = ',num2str(pval_GRF_ML)])

% RHipKinemat maximum (Hip_ADD)
%
ch = 'RHipKinemat_y';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Hip_ADD,~,stats] = ttest(r.Straight,r.Turn,0.05,'both');
disp(['p-value for Hip_ADD = ',num2str(pval_Hip_ADD)])

% RKneeAngle_x at foot off (Knee_FLX)
%
ch = 'RKneeKinemat_x';
evt = 'RFS';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Knee_FLX] = ttest(r.Straight,r.Turn,0.05,'both');
disp(['p-value for Knee_FLX = ',num2str(pval_Knee_FLX)])

