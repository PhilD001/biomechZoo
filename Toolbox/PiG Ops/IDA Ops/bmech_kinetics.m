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


% Get static and dynamic trials
%
fl_all = engine('path',fld,'extension','zoo');
fl_static = engine('path',fld,'extension','zoo','search path',settings.static);
fl = setdiff(fl_all,fl_static);


for i = 1:length(fl)
    data = zload(fl{i});                                               % load dyn trial
    batchdisp(fl{i},'computing lower-limb kinetics')     
    data = kinetics_data(data,settings,filt); 
    zsave(fl{i},data);
end

for i = 1:length(fl_static)
    batchdisp(fl_static{i},'skipping static trial')
end



