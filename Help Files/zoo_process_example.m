% ======= Biomechanics Zoosystem Toolbox Demo Processing Script ===============================

% NOTES:
% - This script demonstrates the basic tools available in the Biomechanics Zoosystem Toolbox 
%   by processing data for a hypothetical study
% - All folders and subfolders of the "Biomechanics Zoosystem Toolbox" folder should be added
%   to the MatLab path before starting the demo script
% - Sample data is contained in the 'raw c3d files' folder
% - Each processing step will result in the creation of a new folder. This allows the user to
%   retain the original data. Also, the user can keep track of the changes done to the data 
%   throughout the processing procedure. All steps are included in the download to help users 
%   trouble shoot individual problems
% - The user is encouraged to first run through each step to understand the procedure. 
% - The advanced user would also want to explore the underlying code of each function
% - Further information about the zoosystem can be found in ~\the
%   zoosystem\Help Files\zoo_presentation.ppt'

% THE STUDY
% - 11 subjects were asked to perform straight walking (Straight) and turning gait (Turn) 
%   trials in a typical motion capture environment while fit with the Plug-in Gait marker set
% - Standard gait variables (e.g. joint angles and ground reaction forces) were computed 
% - For the purposes of this demo, we will hypothesize that there are differences between
%   conditons for: 
%   (1) maximum hip adduction in stance
%   (2) knee flexion angle at foot-off
%   (3) maximum medio-lateral ground reaction force
% - Steps 1 to 5 process the data for analysis
% - The 'Visualization' section presents the two main graphical user interfaces (GUIs) of the
%   zoosystem: 'ensembler' and 'director'. 
% - The 'statistical analysis' section will demonstrate how to export data to be easly read by 
%   statistical programs such as SPSS
%
% Created by Philippe C. Dixon November 2013 
%
% Updated by Philippe C. Dixon May 2015
% - Improved user interface and help


%% STEP 1: Convert to zoosystem ---------------------------------------------------------------
%
% - In this step, we wish to convert data from origial format (c3d) to zoosystem format (.zoo)
% - User should create a copy of folder 'raw c3d files' called '1-c3d2zoo'. This will allow 
%   us to return to the original data at any time
% - Explore the structure of a raw zoo file by typing "grab" and selecting any file

fld = uigetfolder;                                                          % select '1-c3d2zoo'
del = 'yes';                                                                % delete original

c3d2zoo(fld,del)                                                            % run conversion


%% STEP 2: Partition --------------------------------------------------------------------------
%
% - This step limits the analysis to a single stance phase for the right limb
% - Data are partitionned based on existing events identified in Vicon
% - the user should create a copy of folder '1-c3d2zoo' called '2-partition'

fld    = uigetfolder;                                                       % select '2-partition'
pstart = 'Right_FootStrike1';                                               % start event  
pend   = 'Right_FootOff1';                                                  % end event 

bmech_partition(pstart,pend,fld)                                            % run function

% User notes
% - After processing, all files show data during stance phase of the right limb only. User can
%   explore data by typing 'grab' in the command window, selecting a file and plotting a channel 
%   e.g. plot(data.RGroundReactionForce.line) 
% - User can check the data.zoosystem.Video field for updated frame information
% - Analog channels sampled at 1000Hz will not be partitionned appropriately. If these channels 
%   are required for analysis, user should downsample these channels prior to partionning. Full 
%   list of analog channels stored in 'data.zoosystem.Analog.Channels'


%% STEP 3: Clean ------------------------------------------------------------------------------
%
% - This step cleans up the zoo files by removing unwanted channels and by splitting (exploding) 
%   3D channels into separate channels for easier analysis
% - User should create a copy of folder '2-partition' called '3-clean'

fld   = uigetfolder;                                                        % select '3-clean'
chkp  = {'RGroundReactionForce','RHipAngles','RKneeAngles','SACR','LASI'};  % chns to keep
chexp = {'RGroundReactionForce','RHipAngles','RKneeAngles'};                % chns to be analysed
  
bmech_removechannel('fld',fld,'chkp',chkp)                                  % two approaches to
bmech_removechannel('fld',fld,'chrm','LASI')                                % removing chns

bmech_explode(fld,chexp)                                                    % nx3 to 3 nx1


% User notes
% - All files now contain a single channel for marker data (data.SACR) as well as channels for
%   each dependent variable to be analysed (exploded into three nx1 subchannels) 
% - the 'zoosystem' metainformation channel is never removed by 'bmech_removechannel'


%% STEP 4: Add Events -------------------------------------------------------------------------
%
% - In this step, discrete events along the curves are identified for statistical analysis
%   (see hypotheses)
% - User should create a copy of folder '3-clean' called '4-addevents'

fld = uigetfolder;                                                          % select '4-addevents'

bmech_addevent(fld,'RHipAngles_y','max','max')                              % max val stance
bmech_addevent(fld,'RGroundReactionForce_x','max','max')                    % min val stance

% User notes
% - Local events have been added to the event branch of the channels selected. User can explore 
%   data by typing 'grab' in the command window, selecting a file and plotting using 'zplot' e.g.
%   zplot(data.RHipAngles_y) (see ~\Sample Study\figures\zplot_figure_example.fig' for an example
% - An event does not need to be added for knee flexion at foot-off because this event already 
%   exists ('Right_Foot_Off1' identified in Vicon). Its index (time) is saved under the 'SACR_x'
%   event branch. This kind of event is referred to as a 'global event'.


%% STEP 5: Normalize and view -----------------------------------------------------------------
%
% - This steps normalizes the data to a given length of 101 frames (0-100% of the stance phase)
% - User should create a copy of folder '4-addevents' called '5-normalize'
%
fld = uigetfolder;                                                          % select '5-normalize'
nlength = 100;                                                              % 100% of stance
bmech_normalize(fld,nlength)


%% VISUALIZATION ------------------------------------------------------------------------------
%
% - Now that the processing is complete, it is important to visualize the data to check for 
%   errors/problems. This can be done using the 'ensembler' and 'director' tools
%
% ENSEMBLER (PART 1): 
% - The main GUI in the zoosystem is 'ensembler'. For this example, follow these instructions: 
%   (1) Type 'ensembler' in the Matlab command window. A window pops up with various settings.  
%   (2) change the 'name' field to 'Straight' 'turn', rows to '1', and columns to '3' (all 
%       without quotes) and click 'OK'. This will create two generic figure windows, each with 
%       three empty axes. To resize figure windows and axes to your liking, select 'restart' 
%       from the 'File' menu on either of the figure windows and edit the sizing options
%   (3) Select 'Axes' --> 're-tag'. Choose any zoo file from the step 5 folder. This opens a 
%       window for you to select which channel(s) to view in ensembler. Associate 'RHipAngles_y', 
%       'RKneeAngles_x', and 'RGroundReactionForce_x' to the generic axes '1 1', '1 2', '1 3'
%       and select 'ok'. The axes of each figure will be updated
%   (4) In the main menu of either figure window, choose 'File'-->'load data' and select the 
%       step 5 folder. This will allow ensembler to populate the axes with corresponding data. 
%       For example, the 'RHipAngles_y' axes of figure 'Turn' contains only the RHipAngle_y 
%       data for the turn condition 
%   (5) For now, ignore the events by selecting 'Events' --> 'clear all events'. Only the line 
%       data remain. We can see that one of the lines for 'RGroundReactionForce_x' for the turn 
%       condition is separate from the rest. Clicking on it turns it blue and reveals that it 
%       is trial 'HC002D25.zoo'. We will see later why this trace is different, but for now let's
%       assume it is an outlier that should be removed. This could be done by deleting the file
%       in a standard window explorer (or mac finder) window, but the rest of the data (hip and
%       knee angles) appear unaffected and should not be deleted. In ensembler, left click on 
%       the trial, press 'delete' on the  keyboard and select 'Delete Channel'. This will replace
%       all line and event data in this channel with 999 values (check using grab).
%   (6) Select 'Ensembler' --> 'Ensemble (SD)' and the 'Ensembler' --> 'combine data' to graph 
%       the average of both conditions together. Line styles and colors can be updated via the
%       'Line' menu. Change the colors and styles to easily differentiate the conditons. 
%   (7) Add a legend by selecting 'Insert' --> 'legend'         
%   (8) Graphs can be saved as Matlab figures (.fig) or exported to a number of formats. See
%       ~\Sample Study\figures\ensembler_line_example.fig and .pdf for sample outputs

% DIRECTOR  
% - The other zoosystem GUI is called 'director'. Director is a 3D virtual environment for 
%   visualization of 3D motion data. Out of the box, it can animate motion trials for plug-
%   in gait data, but can be updated by advanced users for use with other datasets. 
% - Let us explore a few trials from the dataset by following these steps: 
%  (1) Type 'director' (make sure ensembler is closed) from the command window. This opens up a
%      blank 3D canvas. 
%  (2) Select 'Load File' and choose a file from the step 1 folder. Choose 'lower-limbs' and then 
%      select a few markers to display from the list (e.g. 'RP1M', 'RP5M', and 'RTOE'). This will
%      load a skeleton and markers associated with the trial. Director detects the position of 
%      force plates in the file and also displays them in the 3D environment. 
%  (3) Select 'RHipAngles' from the top-left channel list and click 'Play' to start the animation. 
%  (4) Repeating this process for a number of trials (including our so-called outlier) reveals 
%      that in trial 'HC002D25.zoo' the subject walked in the opposite direction to the others
%      This direction change was rsponsible for seemingly incorrect force profile. A function 
%      could be written to rotate GRF to a single orientation in a real study. Visualization 
%      helped us save this file from the rubbish bin. 

% ENSEMBLER (PART 2)
% - We are interested in extracting discrete points along the curves (see hypotheses). Follow 
%   the steps below to crete bar graphs for the given events
%  (1) Repeat steps 1-4, but this time only load the RHipAngles_y data
%  (2) Ensemble and combie the data to show a mean and confidence interval (CI) curve
%      for each condition on a single axis. 
%  (3) Choose 'Analysis' --> 'bar graph' to display these discrete data. Graph can be customized
%      and exported for the user's purposes.
%  (4) Customize the bar graphs by selecting 'Edit' --> 'property editor on'. A pull down menu
%      will be added in future releases to easily customize bar graphs. 


%% STATISTICAL ANALYSIS -----------------------------------------------------------------------
%
% - After analysis and visualization of data is complete, it is now possible to export the data
%   for statistical analysis
%
% SETUP
% - The following preliminary steps are required for event export: 
%   (1) A folder called 'statistics' in ('~\The zoosystem\Sample Study\Statistics') 
%       needs to be created
%   (2) This folder should contain two files: dim1.xls and dim2.xls. Read 'eventval' help to 
%       learn about set-up). Here sample files have already been created.

% - Run the code below and then open the newly created 'eventval.xls' file. WARNING: This module 
%   will not work on non-windows platforms due to limitations in the available excel server. 

fld = uigetfolder;                                                          % select folder
localevts = 'max';                                                          % local events
globalevts = 'Right_FootOff1';                                              % global events
ch = {'RGroundReactionForce_x','RHipAngles_y','RKneeAngles_x'};             % channels
eventval('fld',fld,'localevts',localevts,'globalevts',globalevts,'ch',ch)   
                   
% User notes:
% - If you run into problems take a look at the 'eventval_backup.xls' file
% - Non-existant events (e.g. 'max' for RKneeAngles_x') and outliers will show as 999 values 
%   in the excel sheet
% - Check that data in excel sheet matches zoo data using grab
% - This sheet can be imported into SPSS to test the hypotheses...what do you find?





