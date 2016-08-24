function bmech_kinematicsPiG(fld,sfld,flat)

% BMECH_KINEMATICSPIG(fld,sfld,foot_flat) is a batch process function to compute lower-limb 
% joint kinematics according to the plug-in gait (PiG) model
%
% ARGUMENTS
%  fld         ...  Folder to batch process (string). Default: folder selection window.
%  sfld        ...  Name of static file folder (string). Default: 'Static'
%  flat        ...  Assume foot flat for static pose. Default: true
%
% NOTES
% - Static files associated with a given dynamic file should be placed in a
%   folder called 'Static' or contain the word 'static' in the file name
%   e.g.     root - Subject 1 - cond1
%                             - Static
%
% See also bmech_kinematicsRvdB,bmech_jointcentrePiG


% Revision History
%
% Created by Philippe C. Dixon June 13th 2016


% Set defaults/error check
%
if nargin==0
    fld = uigetfolder;
    sfld = 'Static';
    flat = true;
end

if nargin==1
    sfld = 'Static';
    flat = true;
end

if nargin==2
    flat = true;
end

cd(fld)

% Get static and dynamic trials
%
fl = engine('path',fld,'extension','zoo');
flStat = engine('path',fld,'extension','zoo','folder',sfld);
flDyn =setdiff(fl,flStat);
subname_prev = [];

for i = 1:length(flDyn)
    
    data = zload(flDyn{i});                                               % load dyn trial
    subname = deblank(data.zoosystem.Header.SubName);                     % ID subject
    
    if ~strcmp(subname_prev,subname)                                      % load static
        flStat = engine('path',fld,'extension','zoo',...                  % associated with
            'search path',[subname,filesep,sfld]);            % dyn trial
        if length(flStat) ~=1
            error(['more than one static trial for ',fname])
        end
        sdata = zload(flStat{1});
        subname_prev = subname;
    end
    
    % Compute ankle static offset using static trial
    %
    batchdisplay(flStat{1},'processing static trial')                     % compute quants    
    sdata = makebones(sdata,'static',flat);
    sdata = kinematicsPiG_data(sdata);
    
    
    % Create joint kinematics for dynamic trial
    %
    batchdisplay(flDyn{i},'computing PiG kinematics')
    data = makebones(data,'dynamic');
    data = ankleoffsetPiG_data(data,sdata);                  
    data = kinematicsPiG_data(data);  
    
    % save to zoo
    zsave(flStat{1},sdata);
    zsave(flDyn{i},data);
end



