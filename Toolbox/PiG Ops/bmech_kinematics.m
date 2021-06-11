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

% Get static and dynamic trials
%
fl = engine('path',fld,'ext','zoo');
flStat = engine('path',fld,'ext','zoo','folder',settings.static);
if isempty(flStat)
    flStat = engine('path',fld,'ext','zoo','folder',lower(settings.static));
end

if isempty(flStat)
        flStat = engine('path',fld,'ext','zoo','search file',settings.static);
end

if isempty(flStat)
    flStat = engine('path',fld,'ext','zoo','search file',lower(settings.static));
end

flDyn =setdiff(fl,flStat);
subname_prev = [];

for i = 1:length(flDyn)
    
    data = zload(flDyn{i});                                               % load dyn trial
    subname = data.zoosystem.Header.SubName;                              % ID subject

    if ~strcmp(subname_prev,subname)                                      % load static
        indx = find(contains(flStat,subname));
        if isempty(indx)
           error(['no static trials for: ',subname])
        elseif length(indx) > 1
           error(['more than one static trial for: ',subname])
        end
        
        flStatSub = flStat(indx);
        [~,flStatFile,ext] = fileparts(flStatSub{1});
        disp(' ')
        disp(['processing static trial ',flStatFile,ext,' for subject ',subname])                     % compute quants
        sdata = zload(flStatSub{1});
        subname_prev = subname;
          
        % Compute ankle static offset using static trial
        %
        sdata = makebones_data(sdata,'static',settings.flat);
        sdata = kinematics_data(sdata);
    end
    
    % Create joint kinematics for dynamic trial
    %
    batchdisp(flDyn{i},'computing PiG kinematics')
    data = ankleoffsetPiG_data(data,sdata);
    data = makebones_data(data,'dynamic');
    data = kinematics_data(data,settings);
    
    % save to zoo
    zsave(flStat{1},sdata);
    zsave(flDyn{i},data);
end



