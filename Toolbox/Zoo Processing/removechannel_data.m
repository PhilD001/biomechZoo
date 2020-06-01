function data= removechannel_data(data,ch)

% data= REMOVECHANNEL_DATA(data,ch) removes channels from zoo files
%
% ARGUMENTS
%  data     ...  Zoo data (struct)
%  ch       ...  Channels to remove (string or cell array of strings)
%
% RETURNS
%  data     ...  Zoo data with ch removed from struct
%
% See also bmech_removechannel, bmech_removeevent, bmech_addevent, bmech_removeevent


% Revision History
%
% Created by Philippe C. Dixon
% - extracted from old functions
%
% Updated by Philippe C. Dixon May 2015
% - updated help
%
% Updated by Philippe C. Dixon July 2016
% - Removed argument 'section'. Program will search automatically
%
% Updated by Philippe C. Dixon Dec 2016
% - Improved help section


% error checking
%
if ~iscell(ch)
    ch = {ch};
end


% get section of channels
%
v_list = cell(size(ch));


for i = 1:length(ch)
    if isfield(data,ch{i})
        
        if ismember(ch{i},data.zoosystem.Video.Channels)
            v_list{i}  = ch{i};
            
        elseif ismember(ch{i},data.zoosystem.Analog.Channels)
            continue
        else
            warning(['missing section fieldname in zoosystem for ',ch{i}])
            data = rmfield(data,ch{i});
        end
    end
end

v_list(cellfun(@isempty,v_list)) = [];







% process
%
for i = 1:length(ch)
    
    if isfield(data,ch{i})
              
        if ismember(ch{i},v_list)
            section = 'Video';
        else 
            section = 'Analog';
        end
        
        data = rmfield(data,ch{i});
        chlist = data.zoosystem.(section).Channels;
        nchlist = setdiff(chlist,ch{i});
        data.zoosystem.(section).Channels = nchlist;
         
    end
end