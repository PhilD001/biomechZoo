% ZOO_PROCESS_EXAMPLE demonstrates the tools available in BiomechZoo by processing
% sample data for a hypothetical study.
%
% NOTES
% - BiomechZoo folders should be added to the MatLab path before starting the demo.
%   This can be accomplished by running startZoo.m (located in the root BiomechZoo folder)
% - Sample data can be downloaded at https://github.com/PhilD001/biomechzoo-samplestudy
% - Run mode ('auto' or 'manual'). If input set to 'auto' all processing steps are run 
%   automatically without user input. In manual mode, each processing step should operate
%   on a new folder. This allows the user to check each process before moving on. 
%   All steps are included in the download to help users trouble-shoot problems.
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
%   (3) Knee flexion moment angle at foot-off (Knee_FLX)
%   (4) Maximum ankle power generation (Ankle_PWR)
%
% - Step 1-7 processes the data for analysis
% - Step 8 (The visualization section) presents the two main graphical user interfaces
%   (GUIs) of the zoosystem: 'ensembler' and 'director'.
% - Step 9 (The statistical analysis section) demonstrates how to export data to be read
%   by thrid party statistical programs such as SPSS or R.
%
% Created by Philippe C. Dixon November 2013
%
% Last updated by Philippe C. Dixon August 15th 2016
% - Improved help
% - Included hyperlinks
% - Added processes for comparsion with PiG outputs
% - Added 'auto' mode
%
% see http://www.biomechzoo.com for the latest updates on the biomechZoo project
%
%
% License, citations, and latest version information, type 'zooinfo'



%% Step 0: Set run mode ------------------------------------------------------------------
%
% - If mode is set to 'auto', all processes will apply to the new folder called 
%   'zoo files (auto process)' created in this step
% - If mode is set to 'manual', the user can run each cell (step 1-9) indivdually, each 
%   time manually copying a new folder for each step

% mode = 'manual';                                                         % cell by cell
mode = 'auto';                                                             % entire code

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


%% Step 1: Conversion to the biomechZoo format -------------------------------------------
%
% - In this step, we convert data from origial format (.c3d) to zoo format (.zoo)
% - User should create a copy of folder 'raw c3d files' called '1-c3d2zoo'. This will 
%   allow us to return to the original data at any time

if strfind(mode,'manual')
    fld = uigetfolder('select ''1-c3d2zoo''');
end

del = 'yes';                                                                % delete c3ds

c3d2zoo(fld,del);                                                           % run conv


% User notes:
% - Explore the structure of a raw zoo file by typing 'grab' and selecting any file.


%% STEP 2: Cleaning the data -------------------------------------------------------------
%
% - removes channels (not used in current study)
% - The user should create a copy of folder '1-c3d2zoo' called '2-clean'

if strfind(mode,'manual')
    fld = uigetfolder('select ''2-clean''');
end

ch = {'LFHD','LBHD','RFHD','RBHD','C7','T10','T12','RBAK','CLAV','STRN',... % PiG markers
      'LSHO','LELB','LWRA','LWRB','LFIN','RSHO','RELB','RWRA','RWRB',...
      'RFIN','SACR','RASI','LASI','LTHI','LTIB','LKNE','LANK','LHEE',...
      'LTOE','RTHI','RTIB','RKNE','RANK','RHEE','RTOE',...
      'RHJC','LHJC','RFEO','LFEO','RTIO','LTIO',...                         % PiG jnts
      'LPelvisAngles','LHipAngles','LKneeAngles','LAnkleAngles',...         % PiG kinemat
      'RPelvisAngles','RHipAngles','RKneeAngles','RAnkleAngles',...
      'LHipForce','LKneeForce','LAnkleForce','LHipMoment','LKneeMoment',... % PiG kinetics
      'LAnkleMoment','LHipPower','LKneePower','LAnklePower','RHipForce',...
      'RKneeForce','RAnkleForce','RHipMoment','RKneeMoment',...
      'RAnkleMoment','RHipPower','RKneePower','RAnklePower',...   
      'LGroundReactionForce','LGroundReactionMoment',...                    % PiG proc GRF
      'RGroundReactionForce','RGroundReactionMoment',...
      'ForceFx1','ForceFy1','ForceFz1','MomentMx1','MomentMy1',...          % raw GRF
      'MomentMz1','ForceFx2','ForceFy2','ForceFz2','MomentMx2',...
      'MomentMy2','MomentMz2'};
    
bmech_removechannel(fld,ch,'keep')                  


%% STEP 3: Processing force plate data ---------------------------------------------------
%
% - In this step, filtering and downsampling of raw force plate data is performed
% - Data are also mass normalized, renamed, and coordinate transformed in order to 
%   prepare ground reaction force (GRF) data for use in other processes
% - These processes attempt to replicate the steps performed by the Vicon modeller
% - The user should create a copy of folder '2-clean' called '3-process fpdata' 

if strfind(mode,'manual')
    fld = uigetfolder('select ''3-process fpdata''');
end
filt.cutoff = 20;                                                           % filter
filt.type   = 'butterworth';                                                % settings 
filt.order  = 4;                                                            % see function
filt.pass   = 'low';
    
bmech_processGRF(fld,filt)


%% Step 4: Partitioning the data ---------------------------------------------------------
%
% - This step limits the analysis to a single stance phase for the right limb
% - Data are partitionned based on right limb force plate hits
% - The subfolder 'sfld' will be ignored (i.e., not partitioned, because static data do
%   not contain gait data and do not need to be partitionned)
% - The user should create a copy of folder '3-process fpdata' called '4-partition'

if strfind(mode,'manual')
    fld  = uigetfolder('select ''4-partition''');
end

sfld  = 'Static';                                                           % no partition
evtn1 = 'RFS';                                                              % start name
evtn2 = 'RFO';                                                              % end name
evtt1 = 'FS_FP';                                                            % start type
evtt2 = 'FO_FP';                                                            % end type
ch    = 'RightGroundReactionForce';                                                              % event channel

bmech_addevent(fld,ch,evtn1,evtt1,sfld)                                     % Find FS & FO
bmech_addevent(fld,ch,evtn2,evtt2,sfld)                                     % based on Fz

bmech_partition(fld,evtn1,evtn2,sfld)                                       % run function

% User notes:
% - After processing, all files show data over the stance phase of the right limb (left 
%   will be in swing). Check by plotting, for example, the vertical ground reaction force:
%  'plot(data.RightGroundReactionForce.line(:,3))'.
% - The dataset also includes, for some files, events that were manually identified in 
%   Vicon ('Right_FootStrike1' and 'Right_FootOff1'). The user can check if these are 
%   similar to the events identified here.


%% STEP 5: Computing joint kinematics and kinetics ---------------------------------------
%
% - This steps computes ankle, knee, and hip joint kinematics using two approaches:
%   (1) 'KineMat' toolbox see: http://isbweb.org/software/movanal/kinemat/
%   (2) custom code made to reproduce the PiG outputs
% - Ankle, knee, and hip joint centres are also computed to supported calculations
% - The user should create a copy of folder '4-partition' called '5-computations'

if strfind(mode,'manual')
    fld = uigetfolder('select ''5-computations''');
end

sfld = {'Static'};                                                          % no partition

Pelvis = {'RASI','LASI','SACR'};                                            % markers to
Thigh  = {'KNE','THI','HipJC'};                                             % define seg
Shank  = {'ANK','TIB','KneeJC'};                                            % for kinemat
Foot   = {'ANK','TOE','HEE'};                                               % computations
joints = {'HipJC','KneeJC','AnkleJC'};
sequence = 'yxz';                                                           % Euler seq

bmech_jointcentrePiG(fld,joints)                                            % Jnt centres

bmech_kinematicsRvdB(fld,Pelvis,Thigh,Shank,Foot,sequence)                  % run kinemat

bmech_kinematics(fld)                                                       % run kinemat

bmech_kinetics(fld)                                                         % run kinetics

bmech_removefolder(fld,sfld)                                                % rm static


% User notes:
% - This step demonstrates the kinematic and kinetic tools available in BiomechZoo
% - Kinematics are computed from 'raw' markers (labelled and gap filled); however, the
%   anthropometric info within the c3d file were used to support the calculations
% - A truly 'raw' process would need to include a step in which anthropometrics are added
%   to the data.zoosystem.Anthro branch
% - This dataset also contains kinematic quantities computed by the PiG modeller. These 
%   were used to compare the present calculations (see biomechZoo-samplestudy/figures/)
% - The angles output by the KineMat function were offset by the static PiG angles in 
%   order to better compare the processes.


%% Step 6: Adding events -----------------------------------------------------------------
%
% - In this step, discrete events along the curves are identified for statistical analysis
%   (see hypotheses)
% - User should create a copy of folder '5-computations' called '6-add events'.

if  strfind(mode,'manual')
    fld = uigetfolder('select ''6-add events''');
end

bmech_explode(fld)

bmech_addevent(fld,'RightGroundReactionForce_x','max','max')                % max lateral
bmech_addevent(fld,'RightHipAngle_y','max','max')                           % max adduct
bmech_addevent(fld,'RightAnklePower','max','max')                           % max gener


% User notes:
% - Local events have been added to the event branch of the channels selected. Users can
%   explore data by typing 'grab', selecting a file and plotting using 'zplot', e.g.:
%   'zplot(data.RightHipAngle_y)'
% - An event does not need to be added for knee moment at foot-off because this event
%   already exists ('RFO' previously identified)
%   This kind of event is referred to as a 'global event', the other events are 'local'


%% Step 7: Normalizing -------------------------------------------------------------------
%
% - This step normalizes all channels to a single length of 101 frames (0-100% stance)
% - User should create a copy of folder '6-add events' called '7-normalize'

if  strfind(mode,'manual')
    fld = uigetfolder('select ''7-normalize''');
end

nlength = 100;                                                              % 100% stance
method = 'linear';                                                          % interp meth
ch = 'all';                                                                 % norm all chs

bmech_normalize(fld,ch,nlength,method)


%% Step 8: Visualization -----------------------------------------------------------------
%
% - Now that the processing is complete, it is important to visualize the data to check
%   for any errors/problems. This can be done using the 'ensembler' and 'director' tools.

% Generating time-series graphs for RightGroundReactionForce_x, RightHipAngle_y, 
% RightKneeMoment_x, and Righ3tAnklePower in Ensembler:
% 
% 1. Type ensembler in the Matlab command window. A preliminary settings window opens.
% 2. Change the name field to Straight Turn, rows to 1, and columns to 4 and click OK. 
%    Two generic Ensembler figures are created, each with four empty axes. The main figure 
%    (Turn) contains a menu bar at the top. To resize figure windows and axes, select 
%    File, restart from the menu bar and edit the sizing options.
% 3. Select Axes, re-tag and choose any fully processed zoo file in the final normalized 
%    folder. A channel selection window opens. Associate RightGroundReactionForce_x, 
%    RightHipAngle_y, RightKneeMoment_x, and RightAnklePower to the generic 1 1, 1 2, 1 3, 
%    and 1 4 axes, respectively, by clicking on the arrows. Each channel should now be 
%    listed on the right of its corresponding axis number in the center of the selection
%    window. Select OK to update the figure axis titles with the selected channel names.
% 4. In the menu bar, choose File, load data, and select the folder containing normalized 
%    data. Ensembler populates the axes with the corresponding channel data for each 
%    condition. Trials from the Straight and Turn conditions will be sorted into the 
%    Straight and Turn figures, respectively.
% 5. Clear all events by selecting Events, clear all events from the menu bar.
% 6. One line for RightGroundReactionForce_x for each condition appears separate from the 
%    others. Left click on the trace to identify the trials (HC002D25.zoo and HC036A10.zoo 
%    for the Straight and Turn conditions, respectively.). Press delete on the keyboard 
%    and select Delete Channel to erase the traces. The line and event values are replaced
%    with the value 999 (see Section 3.3 for justification).
% 7. Select Ensembler, Ensemble (SD) then Ensembler, combine data to graph the average of 
%    both conditions in a single figure. Line styles and colors can be updated via the 
%    Line menu to differentiate the conditions.
% 8. Add a legend by selecting Insert, legend and associating each condition with a number 
%    indicating the order in which the legend entries are displayed (vertically).
% 9. Finalize graphs by exploring the menu bar options or by selecting Edit, property 
%    editor on.
% 10. Save the figure by selecting File, save fig or export to vector graphics format 
%    (.pdf ) by selecting File, export.
%
%
% Generating a bar graph for the maximum hip adduction angle (HipADD) in Ensembler:
%
% 1. Repeat steps 1–4 from the time-series instructions, modified to load the 
%    RightHipAngle_y channel data only.
% 2. Clear the event NRMSE by selecting Events then clear events by type.
% 3. Select Ensembler, ensemble (CI) then Ensembler, combine data.
% 4. Select Bar Graph from the menu, then bar graph to display discrete event data as a 
%    bar graph.
% 5. Finalize, and save using steps 8–10 from the time-series graphing instructions.
%
%
% Visualizing three-dimensional motion capture data in Director:
% 
% 1. Type director in the command window. A blank three-dimensional canvas opens.
% 2. Select Load File and choose a file from the “Step 1” folder.
% 3. Choose lower-limbs to load a lower-body skeleton for the selected trial.
% 4. Choose a few markers to display in the animation and select OK
% 5. Choose a channel to plot by clicking on the channel list in the upper left corner.
% 6. Press Play to start animation (Stop to stop).
% 7. Repeat this process for a number of trials (including

if strfind(mode,'auto')
    out_file_turn = [fld,filesep,'HC002D',filesep,'Turn',filesep,'HC002D25.zoo'];
    out_file_straight = [fld,filesep,'HC036A',filesep,'Straight',filesep,'HC036A10.zoo'];

    ch = {'RightGroundReactionForce_x','RGroundReactionForce_x',...
          'RightGroundReactionForce_y','RGroundReactionForce_y'};
      
    outlier(out_file_turn,ch)                
    outlier(out_file_straight,ch)            
end


%% Step 9: Statistical analysis ----------------------------------------------------------
%
% - After analysis and visualization of data is complete, it is now possible to export the
%   data for statistical analysis
%
% METHOD A: Exporting to spreadsheet (using the eventval function)
%
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-normalize''');
end

levts = {'max'};                                                            % local events
gevts = {'RFO'};                                                            % global events
aevts = {'Bodymass','Height'};                                              % anthro events
ch    = {'RightGroundReactionForce_x','RightHipAngle_y',...                 % channels 
         'RightKneeMoment_x','RightAnklePower'};                            % to export
dim1  = {'Straight','Turn'};                                                % conditions
dim2  = {'HC002D','HC030A','HC031A','HC032A','HC033A','HC036A',...          % subjects
         'HC038A','HC039A','HC040A','HC044A','HC050A','HC055A'};
    
excelserver = 'off';                                                        % use java
ext = '.xls';                                                               % pref ext

eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
    'globalevts',gevts,'anthroevts',aevts,'ch',ch,'excelserver',excelserver,...
    'ext',ext)

% User notes:
% - If you run into problems take a look at the exisiting 'eventval.xls' file
% - Outliers will show as 999
% - Check that data in excel sheet matches zoo data using grab
% - This sheet can be imported into SPSS/R or other programs to test the hypotheses...
%   what do you find?
% - On mac or if excel is not installed on computer, 'excelserver' must be set to 'off'



% METHOD B: Analysis within the Matlab environment (using extractevents.m)
%
alpha = 0.05;

% RightGroundReactionForce_x maximum (GRF_ML)
%
ch  = 'RightGroundReactionForce_x';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval] = ttest(r.Straight,r.Turn,alpha);                                   % p = 0.008*
disp(['p-value for GRF_ml = ',num2str(pval)])
disp(['GRF_ML Straight = ',sprintf('%.1f',nanmean(r.Straight)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Straight)),' N/kg'])
disp(['GRF_ML Turn = ',sprintf('%.1f',nanmean(r.Turn)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Turn)),' N/kg'])


% RightHipAngle maximum (Hip_ADD)
%
ch  = 'RightHipAngle_y';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval] = ttest(r.Straight,r.Turn,alpha);                                   % p = 0.007*
disp(['p-value for Hip_ADD = ',num2str(pval)])
disp(['Hip_ADD Straight = ',sprintf('%.1f',nanmean(r.Straight)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Straight)),' deg'])
disp(['Hip_ADD Turn = ',sprintf('%.1f',nanmean(r.Turn)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Turn)),' deg'])

% RightKneeMoment_x at foot off (Knee_FLX)
%
ch  = 'RightKneeMoment_x';
evt = 'RFO';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval] = ttest(r.Straight,r.Turn,alpha);                                   % p = 0.028
disp(['p-value for Knee_FLX = ',num2str(pval)])
disp(['Knee_FLX Straight = ',sprintf('%.1f',nanmean(r.Straight)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Straight)),' Nmm/Kg'])
disp(['Knee_FLX Turn = ',sprintf('%.1f',nanmean(r.Turn)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Turn)),' Nmm/kg'])


% RightAnklePower max (Ankle_PWR)
%
ch  = 'RightAnklePower';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval] = ttest(r.Straight,r.Turn,alpha);                                   % p = 0.002
disp(['p-value for Ankle_PWR = ',num2str(pval)])
disp(['Ankle_PWR Straight = ',sprintf('%.1f',nanmean(r.Straight)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Straight)),' W/kg'])
disp(['Ankle_PWR Turn = ',sprintf('%.1f',nanmean(r.Turn)),...
    ' +/- ',sprintf('%.1f',nanstd(r.Turn)),' W/kg'])

if strfind(mode,'auto')
    disp(' ')
    disp('**********************************')
    disp('Finished running demo program in : ')
    toc
    disp('**********************************')
end

