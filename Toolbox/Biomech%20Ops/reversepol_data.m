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



if isin(ch{1},'all')
    ch = setdiff(fieldnames(data),'zoosystem');
end


for i = 1:length(ch)
    
    if isfield(data,ch{i})
        data.(ch{i}).line = -1.*data.(ch{i}).line;
        evt = fieldnames(data.(ch{i}).event);
        
        for j = 1:length(evt)
            
            if ~isin(evt,'rom')
                r = data.(ch{i}).event.(evt{j});
                data.(ch{i}).event.(evt{j}) = [r(1) -r(2) r(3)];
            end
        end
        
    end
    
end
