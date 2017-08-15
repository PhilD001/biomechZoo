function ensembler_eventval(fld,settings)

% ENSEMBLER_EVENTVAL(fld) prepares data for export to a spreadsheet using eventval



% get groups
%
figs = findobj('type','figure','KeyPressFcn','ensembler(''keypress'')'); % make sure we have ens figures

if length(figs)==1
    name = get(figs(1),'name');
    
    if strfind(name,'and')                    % data were combined
        dim1 = strsplit(name,' and ');
    else                                      % only one group
        dim1 = {name};
    end
    
else
    dim1 = cell(size(figs));
    for i = 1:length(figs)
        dim1{i} = get(figs(i),'name');
    end
    
    dim1 = strrep(dim1,'+','/');               % for multiple groups
    
end



% get channels
%
ax = findobj(figs(1),'type','axes');
ch = cell(size(ax));
for i = 1:length(ax)
    ch{i} = get(ax(i),'tag');
end

% get events
%
evts = findobj('string',settings.string);        % regular ensembler data
av_evts = findobj('string',settings.ensstring);  % data have been ensembled
br_evts = findobj('type','bar');                  % events are in bar graphs

if ~isempty(evts)
    
    evt = cell(size(evts));
    for i = 1:length(evts)
        evt{i} = get(evts(i),'tag');
    end
    evt = unique(evt);
    
elseif ~isempty(av_evts)
    evt = strrep(get(av_evts,'tag'),'_av_','');
    for i = 1:length(evt)
        for j = 1:length(dim1)
            evt{i} = strrep(evt{i},dim1{j},'');
        end
        
    end
    evt = unique(evt);
    
elseif ~isempty(br_evts)
    evt = strrep(get(br_evts,'tag'),'_av_','');
    for i = 1:length(evt)
        for j = 1:length(dim1)
            evt{i} = strrep(evt{i},dim1{j},'');
        end
        
    end
    evt = unique(evt);
else
    ensembler_msgbox(fld,'No events found, cannot export event data')
    return
end


% split local and global events
%
gevts = cell(size(evt));
levts = cell(size(evt));

for i = 1:length(evt)
    if strfind(evt{i},'_global')
        gevts{i} = strrep(evt{i},'_global','');
    else
        levts{i} = evt{i};
    end
end

gevts(cellfun(@isempty,gevts)) = [];
levts(cellfun(@isempty,levts)) = [];

if isempty(gevts)
    gevts = {'none'};
end

if isempty(levts)
    levts = {'none'};
end

% Get subjects (dim2)
%
dim2 = extract_filestruct(fld);


% Set up for eventval
%
excelserver = 'off';                                                        % switch to 'off'
ext = '.xlsx';                                                              % if java error
evalFile = eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
    'globalevts',gevts,'ch',ch,'excelserver',excelserver,...
    'ext',ext);

ensembler_msgbox(fld,['Data exported to: ',concatEnsPrompt(evalFile)])