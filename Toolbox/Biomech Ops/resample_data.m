function  data = resample_data(data,ch,p,q,method)

% data = resample_data(data,ch,p,q) resampling function without filtering
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channel(s) to operate on (single string or cell array of strings).
%                Use 'Video' or 'Analog' to resample all video or analog channels
%  p        ...  Numerator of fraction of sampling rate. Default = [];
%  q        ...  Denominator of fraction of fraction of sampling rate. Default = []
%  method   ...  Manner in which interpolation is conducted (string).
%                Default 'linear'
%
% RETURNS
%  data     ...  Zoo data with chosen channels resampled
%
%
% NOTES:
% - If p and q are not provided, then all channels of ch will be resampled
%   to the rate of the other. e.g. bmech_resampe(fld,'Analog') resamples all
%   Analog channels to the 'Video' sampling rate
% - If only select channels are provided from a given type (e.g. only 'Fz1'
%   from 'Analog' channel list. zoosystem metainfo will provide incorrect
%   information.



% See also bmech_resample, bmech_normalize, normalize_line




% Check channel type
%
if nargin==2
    p = [];
    q = [];
    method = 'linear';
end

if ~iscell(ch)
    ch = {ch};
end

% Set defaults/check arguments
%
if ~isempty(ch)
if ismember(ch{1},data.zoosystem.Video.Channels)             % ch in Video channel list
    curSec = 'Video';
    othSec = 'Analog';
    if isempty(p)
        p = data.zoosystem.(othSec).Freq;
        q = data.zoosystem.(curSec).Freq;
    end
    
elseif ismember(ch{1},data.zoosystem.Analog.Channels)        % ch in Analog channel list
    curSec = 'Analog';
    othSec = 'Video';
    if isempty(p)
        p = data.zoosystem.(othSec).Freq;
        q = data.zoosystem.(curSec).Freq;
    end
    
elseif ismember(ch,{'Video'})                                % extract all video channels
    ch = data.zoosystem.Video.Channels;
    curSec = 'Video';
    othSec = 'Analog';
    p = data.zoosystem.(othSec).Freq;
    q = data.zoosystem.(curSec).Freq;
    
elseif ismember(ch,{'Analog'})                               % extract all analog channels
    ch = data.zoosystem.Analog.Channels;
    curSec = 'Analog';
    othSec = 'Video';
    p = data.zoosystem.(othSec).Freq;
    q = data.zoosystem.(curSec).Freq;
    
elseif ~isfield(data,ch{1})
    disp('channel doesn''t exist')
    return
    
else
    error('unknown section of channels')
end

factor = p/q;

% Perform resampling procedure
%
for j = 1:length(ch)
    
    if isfield(data,ch{j})
        r = data.(ch{j}).line;
        ndatalength = round(length(r)*factor)-1;
        data.(ch{j}).line = normalize_line(r,ndatalength,method);
    end
    
    evts = fieldnames(data.(ch{j}).event);                  % update event values
    for e =1:length(evts)
        r =  data.(ch{j}).event.(evts{e});
        r(1) = round(r(1)*factor);
        data.(ch{j}).event.(evts{e}) = r;
    end
    
end

% add zoosystem info
%
if q/p == data.zoosystem.AVR
    data.zoosystem.(curSec).Freq = data.zoosystem.(curSec).Freq*p/q;
    data.zoosystem.(curSec).CURRENT_START_FRAME = data.zoosystem.(othSec).CURRENT_START_FRAME;
    data.zoosystem.(curSec).CURRENT_END_FRAME = data.zoosystem.(othSec).CURRENT_END_FRAME;
    data.zoosystem.(curSec).Indx = data.zoosystem.(othSec).Indx;
    data.zoosystem.AVR = data.zoosystem.(curSec).Freq/data.zoosystem.(othSec).Freq;
    
else
    data.zoosystem.(curSec).Freq = data.zoosystem.(curSec).Freq*p/q;
%     data.zoosystem.AVR = data.zoosystem.(curSec).Freq/data.zoosystem.(othSec).Freq;
    disp(['zoosystem.',(curSec),' not correctly updated, consider using ',curSec,...
        'as input for channel'])
end
end