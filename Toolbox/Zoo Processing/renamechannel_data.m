function data = renamechannel_data(data,och,nch)

% data = RENAMECHANNEL_DATA(data,och,nch) renames zoo channels 
% ARGUMENTS
%  data  ...  zoo file
%  och   ...  Name of old channels (cell array of strings or single string) e.g. {'ch1','ch2'}
%  nch   ...  Name of new channels (cell array of strings or single string)
%
% RETURNS
%  data  ...  Zoo files with new channels appended
%
% See also bmech_renamechannel, removechannel_data, addchannel_data


% Revision History
%
% Created by Philippe C. Dixon  
% - extracted from old functions
%
% Updated by Philippe C. Dixon May 2015
% - code implements 'addchannel.m' and 'removechannel.m'
%
% Updated by Philippe C. Dixon Jan 2016
% - fixed bug for files without video or analog sections



% Error checking 
%
if ~iscell(och)
    och = {och};
end

if ~iscell(nch)
    nch= {nch};
end



% Get Video/Analog channel list
%
if isfield(data.zoosystem,'Video')
    vch = data.zoosystem.Video.Channels;
else
    vch = {''};
end

if isfield(data.zoosystem,'Analog')
        ach = data.zoosystem.Analog.Channels;
else
    ach = {''};
end



for i = 1:length(och)

    if isempty(findfield(data,och{i}))
        disp(['channel: ',och{i}, ' does not exist'])
    else
        
        if ismember(och{i},vch)
            section = 'Video';
        elseif ismember(och{i},ach)
            section = 'Analog';
        else
            error(['unknown section for ch: ',och{i}])
        end
                
        data = addchannel_data(data,nch{i},data.(och{i}).line,section);  
        data.(nch{i}).event = data.(och{i}).event;
        data = removechannel_data(data,och{i});
    end
end

