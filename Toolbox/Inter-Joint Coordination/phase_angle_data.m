function data = phase_angle_data(data, chns, evt1, evt2, pad_type)


% PHASE_ANGLE_DATA(data, chns, evt1, evt2) computes phase angle taking into
% account additional padding due to Hilbert Transform edge effects
%
% ARGUMENTS
%   data        ... struct, zoo file to operate on
%   chns        ... cell array strings, channels over which to compute phase angle
%   evt1        ... string, name of first event where phase angle computation should start
%   evt12       ... string, name of second event where phase angle computation should end
%   pad_type    ... num, option to pad with zeros or Nans. Default is NaN
% 
% RETURNS
%   data        ... struct, zoo file with additonal phase angle channels added
%                   as 'chns{i}_phase' 
%

if nargin == 4
    pad_type = NaN;
end

evt1_frames = findfield(data, evt1);
evt1_frames = evt1_frames(1);
if evt1_frames == 1
    warning(['event 1 (', evt1,') corresponds to first frame of data, additional data are required for padding'])
end

evt2_frames = findfield(data, evt2);
evt2_frames = evt2_frames(1);
if evt2_frames == length(data.(chns{1}).line)
    warning(['event 2 (', evt2, ') corresponds to last frame of data, additional data are required for padding'])
end


for i = 1:length(chns)
    r = data.(chns{i}).line;
    p_angle = phase_angle(r);
    p_angle(1:evt1_frames-1) = pad_type;
    p_angle(evt2_frames+1:end) = pad_type;
    data = addchannel_data(data, [chns{i}, '_phase'], p_angle, 'video');
end
    