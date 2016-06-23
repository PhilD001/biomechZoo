function zoo_process_example_auto(fld)


% ZOO_PROCESS_EXAMPLE_AUTO(fld) automatically runs through the processing steps
% for the sample study. This function can be used to test if the Zoosystem
% toolbox runs correctly on the user system. Users wishing to explore the
% processing of the sample study using step by step instructions should
% explore <a href="matlab:edit zoo_process_example">zoo_process_example.m</a> 
%
% ARGUMENTS
%  fld     ...  Full path leading to root folder of the sample study ('raw c3d files').
%               If not provided, a explorer window will open prompting the
%               user to select the correct folder.
%
% NOTES:
% - The sample study data must first be downloaded <a href="https://github.com/PhilD001/the-zoosystem-samplestudy">here</a>


% Created by Philippe C. Dixon June 22nd 2016 
%
if nargin==0
    fld = uigetfolder('select ''raw c3d files''');
end
cd(fld)
tic

% Step 0: Copy c3d files to output folder -------------------------------------------------
% 
indx = strfind(fld,filesep);
folder = fld(indx(end)+1:end);
tfld = strrep(fld,folder,'zoo files (auto process)');
copyfile(fld,tfld)
fld = tfld;

% Step 1: Conversion to the Zoosystem format ----------------------------------------------
% 
del = 'yes';                                                              % delete c3dfiles
c3d2zoo(fld,del)                                                           % run conversion

% STEP 2: Processing force plate data ------------------------------------------------------
%                                                    
filt.cutoff = 20;                                                          % filter settings 
filt.ftype  = 'butterworth';                                               % see function
filt.forder = 4;                                                           % for list of all
filt.pass   = 'low';                                                       % filter choices
ch_fp = {'Fx1','Fy1','Fz1','Fx2','Fy2','Fz2'};

bmech_filter('fld',fld,'filt',filt,'chfilt',ch_fp)                         % filter
bmech_massnormalize(fld,ch_fp,'Forces')                                    % convert to N/kg
bmech_resample(fld,'Analog')                                               % FP match kin 
bmech_forceplate2limbside(fld)                                             % assoc limbs

% Step 3: Partitioning the data -----------------------------------------------------------
%
sfld = 'Static';                                                           % no partition
evt1 = 'RFS';                                                              % start event  
evt2 = 'RFO';                                                              % end event 

bmech_addevent(fld,'RFz',evt1,'FS FP',sfld)                                % Finds FS and FO 
bmech_addevent(fld,'RFz',evt2,'FO FP',sfld)                                % based on Fz sig
bmech_partition(evt1,evt2,fld,sfld)                                        % run function

% STEP 4: Computing joint kinematics -------------------------------------------------------
%
Pelvis = {'RASI','LASI','SACR'};                                           % markers used to
Thigh  = {'KNE','THI','HipJC'};                                            % define each seg
Shank  = {'ANK','TIB','KneeJC'};                                           % for joint angle
Foot   = {'ANK','TOE','HEE'};                                              % computations
joints = {'HipJC','KneeJC'};
sequence = 'yxz';                                                          % Euler sequence

bmech_jointcentrePiG(fld,joints)                                           % adds hip joint
bmech_kinemat(fld,Pelvis,Thigh,Shank,Foot,sequence)                        % comp. kinematics

% Step 5: Cleaning the data ---------------------------------------------------------------
%
sfld = 'Static';                                                           % no partition
chkp = {'RFx','RFy','RFz','SACR','LASI',...                                % chns to keep
        'RHipKinemat','RKneeKinemat','RAnkleKinemat',};               

bmech_removefolder(fld,sfld)                                               % rm static
bmech_removechannel('fld',fld,'chkp',chkp)
bmech_removechannel('fld',fld,'chrm','LASI')
bmech_explode(fld)                                                         % mx3 to 3 mx1

% Step 6: Adding events -------------------------------------------------------------------
%
bmech_addevent(fld,'RFx','min','min')                                      % min val stance
bmech_addevent(fld,'RHipKinemat_y','max','max')                            % max val stance

% Step 7: Normalizing the data ------------------------------------------------------------
%
nlength = 100;                                                             % 100% of stance
bmech_normalize(fld,nlength)


% Step 8: Visualization -------------------------------------------------------------------
% - This step is not performed here, outlier channel is tagged as outlier (999)
out_file = [fld,filesep,'HC002D',filesep,'Turn',filesep,'HC002D25.zoo'];
data = zload(out_file);
data.RFx.line = 999*data.RFx.line;
data.RFx.event.min = [1 999 0];


% Step 9: Statistical analysis ------------------------------------------------------------
%
% METHOD A: Exporting to spreadsheet (using the eventval function)
%
levts = {'min','max'};                                                     % local events                                            
gevts = {'RFS'};                                                           % global events                                       
aevts = {'Bodymass','Height'};                                             % anthro events
ch    = {'RFx','RHipKinemat_y','RKneeKinemat_x'};                          % channel to search
dim1  = {'Straight','Turn'};                                               % conditions
dim2  = {'HC002D','HC030A','HC031A','HC032A','HC033A',...                  % subjects
         'HC036A','HC038A','HC039A','HC040A','HC044A','HC050A',...
         'HC055A'};
excelserver = 'off';                                                       % use java
ext = '.xls';                                                              % preferred ext

eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
         'globalevts',gevts,'anthroevts',aevts,'ch',ch,'excelserver',excelserver,...
         'ext',ext) 
     

% METHOD B: Analysis within the Matlab environment (using extractevents.m)
%
%
% RGroundReactionForce_x maximum (GRF_ML)
%
ch  = 'RFx';
evt = 'min';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_GRF_ML] = ttest(r.Straight,r.Turn,0.05,'both');                    % p-val = 0.006*
disp(['p-value for GRF_ml = ',num2str(pval_GRF_ML)])

% RHipKinemat maximum (Hip_ADD)
%
ch  = 'RHipKinemat_y';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);            
[~,pval_Hip_ADD] = ttest(r.Straight,r.Turn,0.05,'both');           % p-val = 0.033*
disp(['p-value for Hip_ADD = ',num2str(pval_Hip_ADD)])

% RKneeAngle_x at foot off (Knee_FLX)
%
ch  = 'RKneeKinemat_x';
evt = 'RFS';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Knee_FLX] = ttest(r.Straight,r.Turn,0.05,'both');                   % p-val = 0.356
disp(['p-value for Knee_FLX = ',num2str(pval_Knee_FLX)])

%---SHOW END OF PROGRAM-------------------------------------------------------------------------
%
disp(' ')
disp('**********************************')
disp('Finished running demo program: ')
toc
disp('**********************************')

