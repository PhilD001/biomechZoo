function bmech_kinetics(fld,settings,filt)

% BMECH_KINETICS(fld,settings) is a batch process function to compute lower-limb
% joint kinetics according to the plug-in gait (PiG) model
%
% ARGUMENTS
%  fld       ...  Folder to batch process (string). Default: folder selection window.
%  settings  ...  Settings control (struct) with the following fields:
%                 'segpar'(string). Default, 'segmentParameters' (currently only choice)
%                 'graph' (boolean). Default, false
%                 'city'  (string). Default, 'standard' sets grav const, see g
%                 'filt'  (boolean). Default, false. Don't filter intermediate calculations
%                 'comp'  (boolean). Default, true. Compares agains Vicon output (if available)
%  filt            Filter settings for GRF (struct). Default, see setFilt


% See also bmech_kinematics, bmech_jointcentre, kinetics_data


% Revision History
%
% Created by Philippe C. Dixon June 13th 2016


% Set defaults/error check
%

cd(fld)

if nargin==1
    filt = setFilt;
    settings.segpar = 'segments.xls';                           % see getSegmentPar
    settings.graph  = false;                                    % graph results
    settings.city   = 'standard';                               % choose g based on city
    settings.filt   = false;                                    % Filter intermediate calc
    settings.comp   = true;
    settings.static = 'Static';                                 % name of static folder
end

if nargin == 2
    filt = setFilt;
end

% get all  trials
fl = engine('path',fld,'ext','zoo');

% Get static trials
flStat = engine('path',fld,'ext','zoo','search path',settings.static);
if isempty(flStat)
    flStat = engine('path',fld,'ext','zoo','search file',settings.static);
end

% only run through 
flDyn = setdiff(fl,flStat);
for i = 1:length(flDyn)
    data = zload(flDyn{i});                                               % load dyn trial
    batchdisp(flDyn{i},'computing lower-limb kinetics')     
    data = kinetics_data(data,settings,filt); 
    zsave(flDyn{i},data);
end

for i = 1:length(flStat)
    batchdisp(flStat{i},'skipping static trial')
end



