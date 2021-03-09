function bmech_hipjointcentrePiG(fld)

% bmech_hipjointcentrePiG(fld) is a batch process function to compute left 
% and right hip joint centers for plug-in gait marker data
%
% ARGUMENTS
%  fld ... folder to operate on
%
% NOTES
% - computation method based on Davis et al. "A gait analysis data collection and reduction
%   technique". Hum Mov Sci. 1991. see 'hipJointCentrePiG.m'


% Revision History
%
% Created by Philippe C. Dixon March 23rd 2016


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


if nargin==0
    fld = uigetfolder;
end
cd(fld)

fl = engine('path',fld,'extension','zoo');




% Batch process 
%
for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing hip joint centre')
    data = hipJointCentrePiG(data);
    zsave(fl{i},data);
end



