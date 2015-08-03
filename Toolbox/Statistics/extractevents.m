function r = extractevents(varargin)

% r = extractevents(varargin) extracts events from zoofiles

% RETURNS
% r    ...  structed array separated by group/cond
%
%
% Created August 2014
%
% Updated September 2014
% - Can search specific channel via 'ch' argument
%
% Updated October 6th 2014
% - 'r' also includes subject order
%
% Updated October 15th 2014
% - can search for global events
%
% Updated March 31st 2015
% - migrated to varargin style 



groups = [];
subs = [];
conditions = {''};
display = 'on';
ch = [];

for i = 1:2:nargin
    
    switch varargin{i}
        
        case 'fld'
            fld = varargin{i+1};
           
        case 'groups'
            groups = varargin{i+1};
            
        case 'condition'
            conditions = varargin{i+1};
            
        case 'subjects'
            subs =  varargin{i+1};
            
        case 'display'
            display = varargin{i+1};
            
        case 'events'
            evt = varargin{i+1};
            
        case 'channel'
            ch = varargin{i+1};

    end
end



cd(fld)

r = struct;

for g = 1:length(groups)
    
    
    for c = 1:length(conditions)
        
        substk = cell(size(subs));
        
        if isin(display,'on')
            disp(['extracting events for group ',groups{g}, ', condition ', conditions{c},' and event ',evt])
        end
        
        subjects = extract_filestruct([fld,slash,groups{g}]);
        
        stk = NaN*ones(length(subjects),1);
        
        for i = 1:length(subjects)
            file =   engine('path',[fld,slash,groups{g},slash,subjects{i}],'search path',conditions{c},'extension','zoo');
            
            if length(file)>1
                error('more than 1 file per sub/con, run reptrial first')
            end
            
            if ~isempty(file)
                data = zload(file{1});
                subcode = subjects{i};
                
                if isin(ch,'auto')
                    evtval = findfield(data,evt);
                elseif isempty(ch)
                    evtval = findfield(data,evt);
                else
                    evtval = findfield(data.(ch),evt);
                    
                end
                
                
                if isempty(evtval)
                    disp(['event ',evt, ' not found in ch ',ch,' searching global event'])
                    evtval = findfield(data,evt);
                    evtval(2) = data.(ch).line(evtval(1));
                    
                elseif isstruct(evtval)
                    evtval = evtval.event.(evt);
                    
                elseif length(evtval)==1
                    evtval = [evtval evtval];
                end
                
                evtval = evtval(2);
                
                if evtval==999
                    evtval = NaN;
                end
                
                stk(i) = evtval;
                substk{i} = subcode;
                
            end
        end
        
        substk(cellfun(@isempty,substk)) = [];   % That's some hot programming
        
        
        r.([groups{g},conditions{c}]).line = stk;
        r.([groups{g},conditions{c}]).subjects = substk;
        
        
        
        
    end
    
end



