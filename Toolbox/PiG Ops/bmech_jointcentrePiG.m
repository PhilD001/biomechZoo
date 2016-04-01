function bmech_jointcentrePiG(fld,joints)

% bmech_hipjointcentrePiG(fld) is a batch process function to compute left 
% and right hip joint centers for plug-in gait marker data
%
% ARGUMENTS
%  fld    ... folder to operate on
%  joints ... name of joints to compute: 'HipJC','KneeJC', or 'Ankle JC' as
%             cell array of strings
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
    joints = {'HipJC','KneeJC','AnkleJC'};
end
cd(fld)

fl = engine('path',fld,'extension','zoo');



% Batch process 
%
for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},['computing joint centres: ',strjoin(joints)])
    
    if ismember('HipJC',joints)
        data = hipJointCentrePiG(data);
    end
    
    if ismember('KneeJC',joints)
        data = jointCentrePiG(data,'Knee');
    end
    
    if ismember('AnkleJC',joints)
        data = jointCentrePiG(data,'Ankle');
    end
        
     zsave(fl{i},data,['joints: ',strjoin(joints)]);
end



