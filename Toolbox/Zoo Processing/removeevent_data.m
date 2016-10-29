function data = removeevent_data(data,evt,ch)

% data = REMOVEEVENT_DATA(data,evt,ch) removes event from zoo file

% ARGUMENTS
%  data  ...  Zoo data 
%  evt   ...  Name of event(s) to remove (string or cell array of strings) e.g.{'HS','TO'}. 
%             Default is 'all'
%  ch    ...  channels from which to remove events. Default is 'all'
%
% RETURNS
%  data  ...  Zoo data with events removed
%
% See also bmech_removeevent


if ~iscell(evt)
    evt = {evt};
end


if ~iscell(ch)
    ch = {ch};
end


if isin(ch{1},'all') 
    ch = setdiff(fieldnames(data),{'zoosystem'});
end

if strcmp(evt{1},'all')
   
    for i = 1:length(ch)
        evts = fieldnames(data.(ch{i}).event);
        
        for j = 1:length(evts)
            data.(ch{i}).event = rmfield(data.(ch{i}).event,evts(j));
        end
    end
    
else
    
    
    for a = 1:length(evt)
        
        for i = 1:length(ch)
            evts = fieldnames(data.(ch{i}).event);
            
            if ~isempty(evts)
                
                for j =1:length(evts)
                    
                    if strcmp(evt{a},evts{j})
                        
                        data.(ch{i}).event = rmfield(data.(ch{i}).event,evts(j));
                    end
                end
            end
            
        end
        
        
        
    end
    
end
