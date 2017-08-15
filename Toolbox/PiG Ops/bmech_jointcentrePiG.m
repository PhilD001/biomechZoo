function bmech_jointcentrePiG(fld,joints)

% BMECH_JOINTCENTREPIG(fld,joints) is a batch process function to compute left 
% and right hip,knee, and joint centers based on Vicon plug-in gait (PiG) method
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string). Default: folder selection window. 
%  joints   ...  Name of joints to compute  (string or cell array of strings): 'HipJC',
%                'KneeJC', or 'Ankle JC'. Default {'HipJC','KneeJC','AnkleJC'};
% NOTES
% - Hip joint centre computation method based on Davis et al. "A gait analysis data 
%   collection and reduction technique". Hum Mov Sci. 1991. see 'hipJointCentrePiG.m'
%   (available in the help files)
% - Knee and ankle joint centre computed via the PiG "chord" function. See
%   Vicon User manual (available in the help files)
%
% See also jointcentrePiG_data


% Revision History
%
% Created by Philippe C. Dixon March 23rd 2016
%
% Updated by Philippe C. Dixon July 2016
% - reformatted for zoosystem v1.3


% Default settings/error checking
%
if nargin==0
    fld = uigetfolder;
    joints = {'HipJC','KneeJC','AnkleJC'};
end

if nargin==1
    joints = {'HipJC','KneeJC','AnkleJC'};
end

if ~iscell(joints)
    joints = {joints};
end


% Batch process 
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},['computing joint centres: ',strjoin(joints)])
    
    
    if ismember('HipJC',joints)
        data = hipjointcentrePiG_data(data);
    end
    
    if ismember('KneeJC',joints)
        data = jointcentrePiG_data(data,'Knee');
    end
    
    if ismember('AnkleJC',joints)
        data = jointcentrePiG_data(data,'Ankle');
    end
        
     zsave(fl{i},data,['joints: ',strjoin(joints)]);
end



