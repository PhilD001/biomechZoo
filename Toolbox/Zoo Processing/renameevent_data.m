function data = renameevent_data(data,evt,nevt)

% data = RENAMEEVENT_DATA(data,evt,nevt) will rename events in your data. 
%
% ARGUMENTS
%  data  ...  Zoo data
%  evt   ...  name of existing event as cell array of strings
%  nevt  ...  name of new event as cell array of string
%
% RETURNS
%  data  ... Zoo data with events renamed


% Revision History
%
% Made standalone by Philippe C. Dixon Oct 2016
%
% Updated by Philippe C. Dixon Oct 2016
% -More efficient code used
%
% Updated by Philippe C. Dixon May 2017
% -Error check for non existing event names
%
% Updated by Philippe C. Dixon Nov 2017
% - Added error check for evts that are strings. These are converted to cells 
%


if ~iscell(evt)
    evt = {evt};
end

if ~iscell(nevt)
    nevt = {nevt};
end

for i = 1:length(evt)
    [~,ch] = findfield(data,evt{i});
    if isempty(ch)
        disp(['Event: ',evt{i},' not found'])
    else
        data.(ch).event.(nevt{i})=data.(ch).event.(evt{i});
        data.(ch).event = rmfield(data.(ch).event, evt{i});
    end
end
