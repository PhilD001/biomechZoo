function outlier(fl,ch,events)

% OUTLIER(fl,ch,events) makes line and event data for 'fl' an outlier, i.e. line data  
% becomes all 999 and event data becomes [exd 999 0]
%
% ARGUMENTS
%  fl     ...  File to operate on (string)
%  ch     ...  Channel to turn into outlier
%  events ...  List of events. Default all events

% Updated by Philippe Dixon Aug 2017
% - Bug fix in event search algorithm

if nargin==2
    events = {};
end

if isempty(strfind(fl,filesep))
    fl = engine('fld',pwd,'search file',fl);
    fl = fl{1};
end

data = zload(fl);

if ~iscell(ch)
    ch = {ch};
end

if ~iscell(events)
    events  = {events};
end

for i = 1:length(ch)
    disp(['replacing line data for channel ',ch{i},' to 999'])
    data.(ch{i}).line = 999*ones(length(data.(ch{i}).line),1);
    
    for j = 1:length(events)
        if isfield(data.(ch{i}).event,events{j})
            disp(['replacing event data for ',events{j},' to [exd 999 0]'])
            e = data.(ch{i}).event.(events{j});
            exd = e(1);
            data.(ch{i}).event.(events{j}) = [exd 999 0];
        end
    end
    
end

zsave(fl,data)