function section = getSection(data,ch)

% section = GETSECTION(data,ch) returns section ('Video' or 'Analog') of channel
%
% ARGUMENTS
%  data     ...  Zoo data
%  channel  ...  Channel name (string)
%
% RETURNS
%  section  ...  Name of section associated with channel ('Video' or 'Analog')
%
% See also addchannel, removechannel

% Revision History
%
% Created by Philippe C Dixon July 2016


% Check arguments
%
if nargin ~= 2
    error('2 arguments are required to run this function')
end

% Extract appropriate section
%
if ismember(ch,data.zoosystem.Video.Channels)
    section = 'Video';
elseif ismember(ch,data.zoosystem.Analog.Channels)
    section = 'Analog';
else
    error('Channel not contained in channel list')
end

