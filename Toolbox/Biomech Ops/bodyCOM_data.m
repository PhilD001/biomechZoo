function data = bodyCOM_data(data,ch)

% data = BODYCOM_DATA(data,ch)computes center of mass (COM) position from all available body
% segment positions
%
% ARGUMENTS
%  data   ...  Zoo data to operate on
%  ch     ...  Name of new body COM channel. Default 'BodyCOM'
%
% RETURN
%  data   ... Zoo data with body COM position appended
%
% See also segmentCOM_data


% Set defaults
%
if nargin==0
    [data,fl] = testmode;
    ch = 'BodyCOM';
else
    fl = [];
end

if nargin==1
    ch = 'BodyCOM';
end

msg = 'COM required for accurate computation of whole body COM';

% Check if segment COM have been calculated
%
if ~isfield(data,'PelvisCOM') 
    data = segmentCOM_data(data);
end

% Create empty matrix
%
chns = setdiff(fieldnames(data),'zoosystem');
junk = zeros(size(data.(chns{1}).line));


% Get all body segment COM
%
if isfield(data,'HeadCOM')                   % Head COM
    headcom = data.HeadCOM.line;
else
    headcom = junk;
end

if isfield(data,'TrunkCOM')                  % Trunk COM
    trunkcom = data.TrunkCOM.line;
else
    error(['Trunk ',msg])
end

if isfield(data,'PelvisCOM')                 % Pelvis COM
    pelviscom = data.PelvisCOM.line;
else
    error(['Pelvis ',msg])
end

if isfield(data,'RUpperArmCOM')
    rupperarmcom = data.RUpperArmCOM.line;   % Right Upper Arm COM
    lupperarmcom = data.LUpperArmCOM.line;   % Left Upper Arm COM
elseif isfield(data,'RightHumerusCOM')
    rupperarmcom = data.RightHumerusCOM.line;
    lupperarmcom = data.LeftHumerusCOM.line;
else
    rupperarmcom = junk;
    lupperarmcom = junk;
end

if isfield(data,'RForeArmCOM')
    rforearmcom = data.RForeArmCOM.line;     % Right ForeArm COM
    lforearmcom = data.LForeArmCOM.line;     % Left ForeArm COM
elseif isfield(data,'RightRadiusCOM')
     rforearmcom = data.RightRadiusCOM.line;
     lforearmcom = data.LeftRadiusCOM.line;
else
    rforearmcom = junk;
    lforearmcom = junk;
end

if isfield(data,'RightHandCOM')
    rhandcom = data.RightHandCOM.line;
    lhandcom = data.LeftHandCOM.line;
else
    rhandcom = [];
    lhandcom = [];
end

if isfield(data,'RThighCOM')                   
    rthighcom = data.RThighCOM.line;         % Right Thigh COM
    lthighcom = data.LThighCOM.line;         % Left Thigh COM
elseif isfield(data,'RightFemurCOM')
    rthighcom = data.RightFemurCOM.line;
    lthighcom = data.LeftFemurCOM.line;
else
    error(['Thigh ',msg])
end

if isfield(data,'RShankCOM')
    rshankcom=data.RShankCOM.line;           % Right Shank COM
    lshankcom=data.LShankCOM.line;           % Left Shank COM
elseif isfield(data,'RightTibiaCOM')
    rshankcom=data.RightTibiaCOM.line;
    lshankcom=data.LeftTibiaCOM.line;
else
    error(['Shank ',msg])
end

if isfield(data,'RFootCOM')
    rfootcom = data.RFootCOM.line;           % Right Foot COM
    lfootcom = data.LFootCOM.line;           % Left Foot COM
elseif isfield(data,'RightFootCOM')
    rfootcom = data.RightFootCOM.line;
    lfootcom = data.LeftFootCOM.line;
else
    error(['Shank ',msg])
end


% Calculate whole body COM
%
if isempty(rhandcom)
    bcm = 0.081.*headcom + 0.355.*trunkcom + 0.028.*rupperarmcom + 0.028.*lupperarmcom +...
          0.022.*rforearmcom + 0.022.*lforearmcom + 0.142.*pelviscom + 0.1.*rthighcom + ...
          0.1.*lthighcom + 0.0465.*rshankcom + 0.0465.*lshankcom + 0.0145*rfootcom +0.0145.*lfootcom;
else
    bcm = 0.081.*headcom + 0.355.*trunkcom + 0.028.*rupperarmcom + 0.028.*lupperarmcom +...
          0.016.*rforearmcom + 0.016.*lforearmcom + 0.006.*rhandcom + 0.006.*lhandcom + ...
          0.142.*pelviscom + 0.1.*rthighcom + 0.1.*lthighcom + 0.0465.*rshankcom + 0.0465.*lshankcom +...
          0.0145*rfootcom +0.0145.*lfootcom;
end

% check for errors
%
if isnan(mean(mean(bcm)))
    error('NaN in data used to calculate Body COM')
end

% check units
%
unt = data.zoosystem.Units.Markers;

if isin(unt,'mm')
    r = 1000;
elseif isin(unt,'m')
    r = 1;
else
    error('marker data not in m or mm')
end

if isfield(data,'RThighCOM')  % for stair study
    bcm = bcm/r;
end

% Add to zoosystem
%
data = addchannel_data(data,ch,bcm,'video');

data.zoosystem.Units.(ch) = 'm';


% save (test mode only)
%
if ~isempty(fl)
   zsave(fl,data)
end


function [data,file] = testmode

pth = fileparts(which('samplestudy_process.m'));
indx = strfind(pth,'biomechZoo-help');
root = pth(1:indx+15);
file = [root,filesep,'HC002D25_testCOM.zoo'];

if ~exist(file,'file')
    error('no sample data available for testing')
else
    data = zload(file);
end