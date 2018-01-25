function r = extractevents(fld,cons,subjects,ch,evt)

% R = EXTRACTEVENTS(fld,cons,subjects,ch,evt) extracts event data from zoo file
%
% ARGUMENTS
%  fld         ...    Folder to operate on as string
%  cons        ...    List of conditions (cell array of strings)
%  subjects    ...    List of subject names (cell array of strings)
%  ch          ...    Channel to analyse (string)
%  evt         ...    Event to analyse (string)
%
% RETURNS
%  r           ...    Event data by condition (structured array)

% Revision History
%
% Updated November 2017 by Philippe C. Dixon
% - improved output display

if ~iscell(cons)
    cons = {cons};
end

r = struct;
s = filesep;                                                    % determines slash direction

for i = 1:length(cons)
    estk = NaN*ones(length(subjects),1);
    
    for j = 1:length(subjects)
        % disp(['loading files for ',subjects{j},' ',cons{i}])
        file =   engine('path',[fld,s,subjects{j},s,cons{i}],'extension','zoo');
        
        if ~isempty(file)
            data = zload(file{1});                              % load zoo file
            evtval = findfield(data.(ch),evt);                  % searches for local event
            
            if isempty(evtval)                                  % searches for global event
                evtval = findfield(data,evt);                   % if local event is not
                evtval(2) = data.(ch).line(evtval(1));          % found
            end
            
            if evtval(2)==999                                   % check for outlier
                evtval(2) = NaN;
            end
            
            estk(j) = evtval(2);                                % add to event stk
        end
        
    end
    r.(cons{i})= estk;                                          % save to struct
end





