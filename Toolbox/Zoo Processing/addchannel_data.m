function data = addchannel_data(data,ch,ndata,section)

% data = ADDCHANNEL_DATA(data,ch,ndata,section)
%
% ARGUMENTS
%  data     ...  Zoo data (struct)
%  ch       ...  Name of new channel to add (string) 
%  ndata    ...  vector of new data to be added to new channel
%  section  ...  'Video' or 'Analog' section
%
% RETURNS
%  data    ...   Zoo data with new channel appended 
%
% NOTES
% - unlike 'bmech_removechannel', there is no batch processing equivalent
%   function to add channels since for a given channel, each file needs to contain
%   specific data.
%
% See also bmech_removechannel, bmech_removeevent, bmech_addevent, removechannel_data


% Revision History
%
% Created 2008 by JJ Loh and Philippe C. Dixon
%
% Updated September 9th 2013 by Philippe C. Dixon
% - Channel added to appropriate channel list (updated for zoosystem v1.2) 
% - dded error check for wrong data size
% - function renamed for consistency (non-batch function)
%
% Updated by Philippe C. Dixon March 3rd 2015 
% - channel list is n x1 cell array of strings
%
% Updated by Philippe C. Dixon July 2016
% - removed backwards compatiblity check
% - simplified algorithm
%
% Updated by Philippe C. Dixon June 2017
% - Added warning for data overwrite if channel already exists
%
% Updtated by Philippe C. Dixon December 20178
% - bug fix for repeated channel names in zoosystem branch when adding the
%   same channel multiple times

% set defaults/error checking 
%
[~,c] = size(ndata);

if iscell(ch)
    ch = ch{1};
end

if c>3
    error('data must be nx1 or nx3')
end

if strcmp(section,'video')
    section = 'Video';
end

if strcmp(section,'analog')
    section = 'Analog';
end


% Check if channel already exists
%
if isfield(data,ch)
    warning(['channel ',ch,' already exists, overwriting with new data...'])
end


% Add channel (check if field is valid) to zoo struct
%
try
    data.(ch).line = ndata;
catch ME
    warning([ME.message, ' making valid field...'])
    ch = makevalidfield(ch);
    data.(ch).line = ndata;
end
data.(ch).event = struct;


% Add channel to appropriate channel list
%
ochs = makecolumn(data.zoosystem.(section).Channels);

if ~ismember(ch,ochs)
    nchs = [ochs; ch];
    data.zoosystem.(section).Channels = nchs;
end