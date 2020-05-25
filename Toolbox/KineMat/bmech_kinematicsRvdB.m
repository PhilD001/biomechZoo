function bmech_kinematicsRvdB(fld,Pelvis,Thigh,Shank,Foot,sequence)

% BMECH_KINEMATICSRVDB(fld,Pelvis,Thigh,Shank,Foot,sequence) computes lower-limb 
% (ankle, knee, hip) joint kinematics using the kinemat toolbox of Reinschmidt 
% and Van den Bogert
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string). Default: folder selection window. 
%  Pelvis    ... cell array of markers (min 3) defining pelvis segment. 
%                Default, use markers 'RASI','LASI','SACR'
%  Thigh     ... cell array of markers (min 3) defining Thigh segment.  
%                Default, use markers 'THI','KNE','KneeJC','HipJC'
%  Shank     ... cell array of markers (min 3) defining Shank segment.
%                Default, use markers 'ANK','TIB','AnkleJC','KneeJC'
%  Foot      ... cell array of markers (min 3) defining Foot segment.
%                Default, use markers 'TOE','HEE','AnkleJC'
%  sequence  ... cardan sequence to choose. Default 'yxz'
%
% NOTES
% - Code based on 'cardan.m' part of Reinschmidt and Van den Bogert 'kinemat'
%   toolbox: http://isbweb.org/software/movanal/kinemat/
% - If hip, knee, and/or ankle joint center  are chosen as virtual tracking
%   markers for kinematics, these will be computed by hipJointCentrePiG and
%   jointCentrePiG. The latter requires the Symbolic Math Toolbox
%
% See also cardan, kinematicsRvdB_data


% Set defaults
%
if nargin ==1
    Pelvis = {'RASI','LASI','SACR'};
    Thigh  = {'THI','KNE','KneeJC','HipJC'};
    Shank  = {'ANK','TIB','AnkleJC','KneeJC'};
    Foot   = {'TOE','HEE','AnkleJC'};
    sequence = 'yxz';
end

if nargin ==2
    Thigh  = {'THI','KNE','KneeJC','HipJC'};
    Shank  = {'ANK','TIB','AnkleJC','KneeJC'};
    Foot   = {'TOE','HEE','AnkleJC'};
    sequence = 'yxz';
end

if nargin ==3
    Shank  = {'ANK','TIB','AnkleJC','KneeJC'};
    Foot   = {'TOE','HEE','AnkleJC'};
    sequence = 'yxz';
end

if nargin ==4
    Foot   = {'TOE','HEE','AnkleJC'};
    sequence = 'yxz';
end


if nargin == 5
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
    
    batchdisplay(flDyn{i},'computing joint angles via kinemat toolbox')
    data = kinematicsRvdB_data(sdata,data,Pelvis,Thigh,Shank,Foot,sequence);
    
    zsave(flDyn{i},data);
end

