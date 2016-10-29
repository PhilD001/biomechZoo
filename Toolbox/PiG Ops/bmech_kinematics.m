function bmech_kinematics(fld,settings)

% BMECH_KINEMATICS(fld,settings) is a batch process function to compute lower-limb
% joint kinematics according to the plug-in gait (PiG) model
%
% ARGUMENTS
%  fld       ... Folder to batch process (string). Default: folder selection window.
%  settings  ... Settings control (struct) with the following fields:
%                'graph' (boolean). Graph comparisons agains Vicon. Default, false
%                'comp'  (boolean). Vicon vs BiomeZoo RMS diff (if available). Default, true
%                'flat' Assume foot flat for static pose. Default: true
%
% NOTES
% - Static files associated with a given dynamic file should be placed in a
%   folder called 'Static' or contain the word 'static' in the file name
%   e.g.     root - Subject 1 - cond1
%                             - Static
%
% See also bmech_kinematicsRvdB,bmech_jointcentrePiG, bmech_kinetics


% Revision History
%
% Created by Philippe C. Dixon June 13th 2016


% Set defaults/error check

if nargin==1
    settings.static = 'Static';
    settings.flat = true;
    settings.graph = false;
    settings.comp = true;
end


cd(fld)

% Get static and dynamic trials
%
fl = engine('path',fld,'extension','zoo');
flStat = engine('path',fld,'extension','zoo','folder',settings.static);
flDyn =setdiff(fl,flStat);
subname_prev = [];

for i = 1:length(flDyn)
    
    data = zload(flDyn{i});                                               % load dyn trial
    subname = deblank(data.zoosystem.Header.SubName);                     % ID subject
    
    if ~strcmp(subname_prev,subname)                                      % load static
        flStat = engine('path',fld,'extension','zoo',...                  % associated with
            'search path',[subname,filesep,settings.static]);            % dyn trial
        if isempty(flStat)
            error(['no static trials for: ',subname])
        elseif length(flStat)>1
            error(['more than one static trial for: ',subname])
        end
        batchdisplay(flStat{1},'processing static trial')                     % compute quants
        
        sdata = zload(flStat{1});
        subname_prev = subname;
    end
    
    % Compute ankle static offset using static trial
    %
    sdata = makebones(sdata,'static',settings.flat);
    sdata = kinematics_data(sdata);
    
    
    % Create joint kinematics for dynamic trial
    %
    batchdisplay(flDyn{i},'computing PiG kinematics')
    data = ankleoffsetPiG_data(data,sdata);
    data = makebones(data,'dynamic');
    data = kinematics_data(data,settings);
    
    % save to zoo
    zsave(flStat{1},sdata);
    zsave(flDyn{i},data);
end



