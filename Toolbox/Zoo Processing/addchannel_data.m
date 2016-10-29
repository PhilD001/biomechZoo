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



% set defaults/error checking 
%
[~,c] = size(ndata);

if c>3
    error('data must be nx1 or nx3')
end

if strcmp(section,'video')
    section = 'Video';
end

if strcmp(section,'analog')
    section = 'Analog';
end


% Add channel to zoo struct
%
data.(ch).line = ndata;
data.(ch).event = struct;


% Add channel to appropriate channel list
%
ochs = makecolumn(data.zoosystem.(section).Channels);
nchs = [ochs; ch];
data.zoosystem.(section).Channels = nchs;



