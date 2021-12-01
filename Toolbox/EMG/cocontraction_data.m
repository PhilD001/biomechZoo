function data = cocontraction_data(data,muscle_pairs,varargin)

% COCONTRACTION_DATA(data,muscle_pairs) computes co-contraction indices
%
% ARGUMENTS
%  data     ...   zoo struct
%  pairs    ...   Names of muscle pairs (cell array of strings).
%  method   ...   Choice of algorithm to use.
%                 Default :'Rudolph'. Other choices :'Falconer' and 'Lo2017'.
% RETURNS
%  data     ...  updated zoo struct
%
% NOTES
% - See cocontraction_line for co-contraction computational approach
%
% See also bmech_cocontraction, cocontraction_line

n= nargin; % number of input argument

switch n
    case 2
        method_exists =false;
        events_exists =false;
        
    case 3
        if ischar(varargin{1})
            method = varargin{1};
            method_exists =true;
            events_exists =false;
        elseif iscell(varargin{1})
            evts =varargin{1};
            method_exists =false;
            if length(evts)==2
                events_exists =true;
                evts_tag = [evts{1, 1} '_to_' evts{1, 2}];
                
                evt1 = evts{1, 1};
                evt2 = evts{1, 2};
                
                if ~isempty(findfield(data,evt1)) && ~isempty(findfield(data,evt2))
                    
                    fields = fieldnames(data);
                    SACR_field =fields(strcmp(fields,'SACR'));
                    
                    if isempty(SACR_field)
                        SACR_field= fields(strcmp(fields,'SACR_x'));
                    end
                    
                    if data.(SACR_field{1}).event.(evt1)(1)<data.(SACR_field{1}).event.(evt2)(1) && (data.(SACR_field{1}).event.(evt2)(1)-data.(SACR_field{1}).event.(evt1)(1))< length(data.(SACR_field{1}).line)
                        data_prt = partition_data(data,evt1,evt2);
                    else
                        disp('issue with event 1 and event 2: Ignoring event(s) and considering complete signal')
                        events_exists =false;
                    end
                    
                else
                    disp('event(s) do not exist: Ignoring event(s) and considering complete signal')
                    events_exists =false;
                end
                
            else
                disp('event 2 not provided: Ignoring event(s) and considering complete signal')
                events_exists =false;
            end
        end
        
    case 4
        method = varargin{1};
        method_exists =true;
        evts =varargin{2};
        
        if length(evts)==2
            events_exists =true;
            evts_tag = [evts{1, 1} '_to_' evts{1, 2}];
            
            evt1 = evts{1, 1};
            evt2 = evts{1, 2};
            
            if ~isempty(findfield(data,evt1)) && ~isempty(findfield(data,evt2))
                
                fields = fieldnames(data);
                SACR_field =fields(strcmp(fields,'SACR'));
                
                if isempty(SACR_field)
                    SACR_field= fields(strcmp(fields,'SACR_x'));
                end
                
                if data.(SACR_field{1}).event.(evt1)(1)<data.(SACR_field{1}).event.(evt2)(1) && (data.(SACR_field{1}).event.(evt2)(1) - data.(SACR_field{1}).event.(evt1)(1))< length(data.(SACR_field{1}).line)
                    data_prt = partition_data(data,evt1,evt2);
                else
                    disp( 'issue with event 1 and event 2: Ignoring event(s) and considering complete signal')
                    events_exists =false;
                end
                
            else
                disp('event(s) do not exist: Ignoring event(s) and considering complete signal')
                events_exists =false;
            end
            
        else
            disp('event 2 not provided: Ignoring event(s) and considering complete signal')
            events_exists =false;
        end
        
    otherwise
        disp('Error: check input arguments \ not all input arguments have to provided')
end


for i = 1:length(muscle_pairs)
    muscles = strsplit(muscle_pairs{i},'-');
    
    if isempty(strfind(muscle_pairs{i},'-'))
        error('must use hyphen between muscle pairs')
    end
    if ~isfield(data,[muscles{1}])||~isfield(data,[muscles{2}])
        error('invalid muscle(s) / muscle(s) do not exist')
    end
    
    if ~isfield(data,muscles{1})||~isfield(data,muscles{2})
        error('EMG channel not normalized')
    end
    
    if events_exists
        muscle1 = data.(muscles{1}).line;
        muscle2 = data.(muscles{2}).line;
        
        muscle1_prt = data_prt.(muscles{1}).line;
        muscle2_prt = data_prt.(muscles{2}).line;
        
        ch_name = [muscles{1},'_',muscles{2}];
        
    else
        muscle1 = data.(muscles{1}).line;
        muscle2 = data.(muscles{2}).line;
        
        ch_name = [muscles{1},'_',muscles{2}];
        
    end
    
    if method_exists
        disp(['computing co-contraction for muscles ',muscles{1},' and ',muscles{2},' using ',method, ' method'])
        
        [r,r_val] = cocontraction_line(muscle1,muscle2,method);
        
        if ~isfield(data,[ch_name '_' method])
            data = addchannel_data(data,[ch_name '_' method],r,'Analog');
        else
            disp('channel already exists: updating channel')
            data.([ch_name '_' method]).line =r;
        end
        
        if r_val~=0 &&events_exists
             disp(['from ', evts_tag])
            [~,r_val] = cocontraction_line(muscle1_prt,muscle2_prt,method);
            data.([ch_name '_' method]).event.(['co_contraction_value' '_from_' evts_tag])= [1,r_val,0];
        elseif r_val~=0
            disp('for entire signal')
            data.([ch_name '_' method]).event.co_contraction_value= [1,r_val,0];
        end
        
    else
        disp(['computing co-contraction for muscles ',muscles{1},' and ',muscles{2},' using Default:Rudolph'])
        disp('for entire signal')
        r = cocontraction_line(muscle1,muscle2);
        if ~isfield(data,[ch_name '_Rudolph'])
            data = addchannel_data(data,[ch_name '_Rudolph'],r,'Analog');
        else
            disp('channel already exists: updating channel')
            data.([ch_name '_Rudolph']).line =r;
        end
        
    end
    
    
    
end


