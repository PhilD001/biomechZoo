function section = getChannelSection(data,ch)

% section = GETCHANNELSECTION(data,ch) returns the section ('video' or
% 'analog' of a channel


if ismember(ch,data.zoosystem.Video.Channels)
    section = 'Video';
elseif ismember(ch,data.zoosystem.Analog.Channels)
    section = 'Analog';
else
    error([ch,' not found in zoosystem'])
end