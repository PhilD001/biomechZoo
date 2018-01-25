function data = cocontraction_data(data,muscle_pairs,sides)

% COCONTRACTION_DATA(data,muscle_pairs) computes co-contraction indices 
%
% ARGUMENTS
%  data     ...   zoo struct
%  pairs    ...   Names of muscle pairs (cell array of strings). 
%  sides    ...   Prefix for limb side. Default = {'R','L'}
%
% RETURNS
%  data     ...  updated zoo struct
%
% NOTES
% - See cocontraction_line for co-contraction computational approach
%
% See also bmech_cocontraction, cocontraction_line

if nargin==2
    sides = {'R','L'};
end

for i = 1:length(muscle_pairs)
    muscles = strsplit(muscle_pairs{i},'_');
    
    for j = 1:length(sides) 
        muscle1 = data.([sides{j},muscles{1}]).line;
        muscle2 = data.([sides{j},muscles{2}]).line;
        
        disp(['computing co-contraction for muscles ',sides{j},muscles{1},' and ',sides{j},muscles{2}])
        r = cocontraction_line(muscle1,muscle2);
        data = addchannel_data(data,[sides{j},muscles{1},'_',muscles{2}],r,'Analog');
    end
end

