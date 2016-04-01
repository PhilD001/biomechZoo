function bmech_kinemat(fld,Pelvis,Thigh,Shank,Foot,sequence)

% bmech_kimemat(fld,Pelvis,Thigh,Shank,Foot,sequence) computes lower-limb (ankle, knee, hip)
% joint kinematics
%
% ARGUMENTS
%  fld      ...  Root folder to operate on. Each subject's folder must contain
%                a 'Static' subfolder where static pose trial data reside.
%  Pelvis    ... cell array of markers (min 3) defining pelvis segment
%  Thigh     ... cell array of markers (min 3) defining Thigh segment
%  Shank     ... cell array of markers (min 3) defining Shank segment
%  Foot      ... cell array of markers (min 3) defining Foot segment
%  sequence  ... cardan sequence to choose. Default 'yxz'
%
% NOTES
% - Code based on 'cardan.m' part of Reinschmidt and Van den Bogert 'kinemat'
%   toolbox: http://isbweb.org/software/movanal/kinemat/
% - If hip, knee, and/or ankle joint center  are chosen as virtual tracking
%   markers for kinematics, these will be computed by hipJointCentrePiG and
%   jointCentrePiG. The latter requires the Symbolic Math Toolbox


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


% Set defaults
%
if nargin ==1
    Pelvis = {'RASI','LASI','SACR'};
    Thigh  = {'KNE','THI','KneeJC','HipJC'};
    Shank  = {'ANK','TIB','AnkleJC','KneeJC'};
    Foot   = {'ANK','TOE','HEE','AnkleJC'};
    sequence = 'yxz';
end



% Get static and dynamic trials
%
fl = engine('path',fld,'extension','zoo');
flStat = engine('path',fld,'extension','zoo','folder','Static');
flDyn = setdiff(fl,flStat);



% Batch process each dynamic trial, but find associated static trial
%
cd(fld)
for i = 1:length(flDyn)
    data = zload(flDyn{i});
    currentSub = deblank(data.zoosystem.Header.SubName);
    flStatic = engine('path',[fld,filesep,currentSub],'extension','zoo','search path','Static');
    sdata = zload(flStatic{1});
    
    batchdisplay(flDyn{i},'computing joint angles')
    [sdata,data]= kinemat(sdata,data,Pelvis,Thigh,Shank,Foot,sequence);
    
    zsave(flStatic{1},sdata);
    zsave(flDyn{i},data);
end

