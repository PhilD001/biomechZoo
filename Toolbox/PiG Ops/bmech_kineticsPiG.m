function bmech_kineticsPiG(fld)

% BMECH_KINETICS(fld) is a batch process function to compute lower-limb
% joint kinetics according to the plug-in gait (PiG) model
%
% ARGUMENTS
%  fld         ...  Folder to batch process (string). Default: folder selection window.
%
% See also bmech_kinematicsPiG, bmech_jointcentrePiG


% Revision History
%
% Created by Philippe C. Dixon June 13th 2016


% Set defaults/error check
%
if nargin==0
    fld = uigetfolder;
end
cd(fld)

% Get static and dynamic trials
%
fl = engine('path',fld,'extension','zoo');


for i = 1:length(fl)
    
    data = zload(fl{i});                                               % load dyn trial
    
    
    % check files
    if isin(fl{i},'Static')
        batchdisplay(fl{i},'skipping static trial')
    else
        batchdisplay(fl{i},'computing PiG kinetics')
        
        data = kineticsPiG_data(data);
        
        %zsave(fl{i},data);
    end
end



