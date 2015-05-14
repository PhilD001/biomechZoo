function data = addchannel(data,ch,ndata,section)

% data = addchannel(data,ch,ndata)
%
% ARGUMENTS
% data    ... struct containing zoo data
% ch      ... name of new channel (as string) that you want to add
% ndata   ... vector of new data to be added to new channel
% section ... 'video' or 'analog' section
%
%
% RETURNS
% data    ... struct containing original channels and new channel
%
% NOTES
% - To learn how to use addchannel please take a look at bmech_sampleaddchannel
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
%
%
%%----------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
%                                                                                            %                
% MAIN CONTRIBUTORS                                                                          %
%                                                                                            %
% Philippe C. Dixon         Dept. of Engineering Science. University of Oxford, Oxford, UK   %
% JJ Loh                    Medicus Corda, Montreal, Canada                                  %
% Yannick Michaud-Paquette  Dept. of Kinesiology. McGill University, Montreal, Canada        %
%                                                                                            %
% - This toolbox is provided in open-source format with latest version available on          %
%   GitHub: https://github.com/phild001                                                      %
%                                                                                            %
% - Users are encouraged to edit and contribute to functions                                 %
% - Please reference if used during preparation of manuscripts                               %                                                                                           %
%                                                                                            %
%  main contact: philippe.dixon@gmail.com                                                    %
%                                                                                            %
%--------------------------------------------------------------------------------------------%


%--backwards compatibility-------------------------------------------------
if nargin==3  
    section = '';
end

%--error checking---------------------------------------------------------
[~,c] = size(ndata);

if c>3
    error('data must be nx1 or nx3')
end

%--Add channel to zoo system---------------------------------------------
data.(ch).line = ndata;
data.(ch).event = struct;

%--Add channel to appropriate channel list--------------------------------
if isin(section,'Video')
    channels =data.zoosystem.Video.Channels;
    channels{end+1} = ch;
    channels = makecolumn(channels);
    
    data.zoosystem.Video.Channels = channels;
    
elseif isin(section,'Analog')
    channels = data.zoosystem.Analog.Channels;
    channels{end+1} = ch;
    channels = makecolumn(channels);
    
    data.zoosystem.Analog.Channels = channels;

end

