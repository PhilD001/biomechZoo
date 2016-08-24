function outlier(fl,ch)

% OUTLIER(fl,chns) makes line and event data for 'fl' an outlier, i.e. line and event data
% become 999
%

if isempty(strfind(fl,filesep))
    fl = engine('fld',pwd,'search file',fl);
    fl = fl{1};
end

data = zload(fl);

if ~iscell(ch)
    ch = {ch};
end

for i = 1:length(ch)
    disp(['replacing line data for channel ',ch{i},' to 999'])
    data.(ch{i}).line = 999*ones(length(data.(ch{i}).line),1);
    evts = fieldnames(data.(ch{i}).event);
    if ~isempty(evts)
        for j = 1:length(evts)
            disp(['replacing event data for ',evts{j},' to [exd 999 0]'])
            data.(ch{i}).event.(evts{j})(2) = 999;
        end
    end
end

zsave(fl,data)