function bmech_leglength(fld)

% BMECH_LEG_LENGTH(fld) computes average leg length from right and left leg length
%
% ARGUMENTS
% fld   ...   folder to operate on
%
% NOTES
% - This function reads left and right leg length data from zoosystem Anthro branch of zoo files
%   and computes average. These data have to be included before this stage 


% Revision History
%
% Created March 31st 2015
%


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt





% Set defaults
%
if nargin==0
    fld = uigetfolder;
end

cd(fld)



% Batch process
%
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'computing average leg-length')
    data = av_leg(data);
    zsave(fl{i},data);
end


function data = av_leg(data)

% Error checking
% 
if ~isfield(data.zoosystem.Anthro,'LLegLength') || ~isfield(data.zoosystem.Anthro,'RLegLength')
    error('missing leg length information')
end

% Compute average leg-length
%
LLeg = data.zoosystem.Anthro.LLegLength;
RLeg = data.zoosystem.Anthro.RLegLength;

Leg = mean([LLeg RLeg]);

% Add to zoosystem
%
data.zoosystem.Anthro.LegLength = Leg;