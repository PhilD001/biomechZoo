function data = reversepol_data(data,ch)

% data = REVERSEPOL_data(data,ch) polarity reversing for a given channel and
% accompanying event if available
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channels to reverse as cell array of strings
%
% RETURNS
%  data     ...  Zoo data with channels in ch with reversed polarity
%
% See also bmech_reversepol, reversepol_line


% set default, all channels have polarity reversed if not channel not chosen
if nargin == 1
    ch = {'all'};
end

% convert single string to cell array of string
if ischar(ch)
    ch = {ch};
end

if strcmp(ch{1},'all')
    ch = setdiff(fieldnames(data),'zoosystem');
end


for i = 1:length(ch)
    
    if isfield(data,ch{i})
        data.(ch{i}).line = reversepol_line(data.(ch{i}).line);
        evt = fieldnames(data.(ch{i}).event);
        
        for j = 1:length(evt)
            
            if ~strcmp(evt{j},'rom')
                r = data.(ch{i}).event.(evt{j});
                data.(ch{i}).event.(evt{j}) = [r(1) -r(2) r(3)];
            end
        end
        
    end
    
end
