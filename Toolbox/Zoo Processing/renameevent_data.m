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

ch = setdiff(fieldnames(data),'zoosystem');

for i = 1:length(evt)
    for j = 1:length(ch)
        if isfield(data.(ch{j}).event,evt{i})
            disp(['event ',evt{i},'found in channel ',ch{j}])
            data.(ch{j}).event.(nevt{i})=data.(ch{j}).event.(evt{i});
            data.(ch{j}).event = rmfield(data.(ch{j}).event, evt{i});
        end
    end
end

