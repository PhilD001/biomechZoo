function data = bmech_addchannel(data,ch,ndata,section)

% data = bmech_addchannel(data,ch,ndata)
%
% ARGUMENTS
%    data  ... struct containing zoo data
%    ch    ... name of new channel (as string) that you want to add
%    ndata ... vector of new data to be added to new channel
%
% RETURNS
%   data   ... struct containing original channels and new channel
%
% NOTES
% -To learn how to use BMECH_ADDCHANNEL please take a look at BMECH_SAMPLEADDCHANNEL
% - Unlike with BMECH_REMOVECHANNEL no batch processing is available here. 
%
% Created 2008 by JJ Loh and Philippe C. Dixon
%
% Updated by Philippe C. Dixon September 2013 
% - channel added to appropriate channel list (updated for zoosystem v1.2) 
% - added error check for wrong data size
%
% Updated by Philippe C. Dixon March 2014
% - functionality with zoosystem v1.2 implemented
% - backwards compatibility not supported
%
%
%----------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
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

%--Add channel to zoo syste-m---------------------------------------------
data.(ch).line = ndata;
data.(ch).event = struct;

%--Add channel to appropriate channel list--------------------------------
if isin(section,'Video')
    channels = {data.zoosystem.Video.Channels; ch};
    data.zoosystem.Video.Channels = channels;
elseif isin(section,'Analog')
    channels = {data.zoosystem.Analog.Channels; ch};
    data.zoosystem.Analog.Channels = channels;
end

