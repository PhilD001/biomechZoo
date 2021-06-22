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
%
% Updated by Philippe C. Dixon April 2017
% - Call to obsolete makebones replaced by makebones_data
%
% Updated by Philippe C. Dixon Jan 2018
% - Fixed bug for missing empty subname in 'data.zoosystem.Header.SubName'
%
% Updated by Philippe C. Dixon Feb 2020
% - removed fixed for problematic subject name field. Subject name is
%   correctly handled in c3d2zoo

% Set defaults/error check

if nargin==1
    settings.static = 'Static';
    settings.flat = true;
    settings.graph = false;
    settings.comp = true;
end

cd(fld)

% Get static trials
%
flStat = engine('path',fld,'ext','zoo','search path',settings.static);
if isempty(flStat)
    flStat = engine('path',fld,'ext','zoo','search file',settings.static);
end

for i = 1:length(flStat)
    
    % load static trial
    sdata = zload(flStat{i});                                               % load dyn trial
    subname = sdata.zoosystem.Header.SubName;                              % ID subject
    
    if str2double(subname) < 120
        continue
    end
        
    
    [~,flStatFile,ext] = fileparts(flStat{i});
    disp(' ')
    disp(['processing static trial ',flStatFile,ext,' for subject ',subname])                     % compute quants
    
    % Compute ankle static offset using static trial
    sdata = makebones_data(sdata,'static',settings.flat);
    sdata = kinematics_data(sdata);
    
    % save to zoo
    zsave(flStat{i},sdata);

    % Create joint kinematics for dynamic trial(s)
    flDyn = engine('fld', fld, 'search path', subname, 'ext', 'zoo');
    if isempty(flDyn)
        flDyn = engine('fld', fld, 'search file', subname, 'ext', 'zoo');
    end
    flDyn = setdiff(flDyn, flStat);
    
    for j = 1:length(flDyn)
        data = zload(flDyn{j});
        batchdisp(flDyn{j},'computing PiG kinematics')
        data = ankleoffsetPiG_data(data,sdata);
        data = makebones_data(data,'dynamic');
        data = kinematics_data(data,settings);
        
        % save to zoo
        zsave(flDyn{j},data);
    end
end



