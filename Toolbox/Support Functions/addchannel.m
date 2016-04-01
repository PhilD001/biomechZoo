function data = addchannel(data,ch,ndata,section)

% data = ADDCHANNEL(data,ch,ndata,section)
%
% ARGUMENTS
%  data     ...  struct containing zoo data
%  ch       ...  name of new channel (as string) that you want to add
%  ndata    ...  vector of new data to be added to new channel
%  section  ...  'video' or 'analog' section
%
%
% RETURNS
%  data    ...   struct containing original channels and new channel
%
% NOTES
% - unlike 'bmech_removechannel', there is no batch processing equivalent
%   function to add channels since for a given channel, each file needs to contain
%   specific data.



% Revision History
%
% Created 2008 by JJ Loh and Philippe C. Dixon
%
% Updated September 9th 2013 by Philippe C. Dixon
% - Channel added to appropriate channel list (updated for zoosystem v1.2) 
% - dded error check for wrong data size
% - function renamed for consistency (non-batch function)
%
% Updated March 3rd 2015 by Philippe C. Dixon
% - channel list is n x1 cell array of strings


% Part of the Zoosystem Biomechanics Toolbox 
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 





%--backwards compatibility-------------------------------------------------
if nargin==3  
    section = '';
    disp('WARNING: channel section not recorded')
end

%--error checking---------------------------------------------------------
[~,c] = size(ndata);

if c>3
    error('data must be nx1 or nx3')
end

section = lower(section);


%--Add channel to zoo system---------------------------------------------
data.(ch).line = ndata;
data.(ch).event = struct;




%--Add channel to appropriate channel list--------------------------------
if isin(section,'video')
    channels =data.zoosystem.Video.Channels;
    channels{end+1} = ch;
    channels = makecolumn(channels);
    
    data.zoosystem.Video.Channels = channels;
    
elseif isin(section,'analog')
    channels = data.zoosystem.Analog.Channels;
    channels{end+1} = ch;
    channels = makecolumn(channels);
    
    data.zoosystem.Analog.Channels = channels;

end

