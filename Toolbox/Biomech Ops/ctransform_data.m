function data = ctransform_data(data,ch,c1,c2)

% data = CTRANSFORM_DATA(data,ch,c1,c2) coordinate transformation 
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channel(s) to operate on (single string or cell array of strings)
%  c1       ...  original coordinate system (3 x 3 matrix)
%  c2       ...  New coordinate system (3 x 3 matrix). Default, global [1 0 0; 0 1 0; 0 0 1]
%
% RETURN
%  data     ...  Data with ch in new coordinate system
%
% See also bmech_ctransform, ctransform_line, gunit


if ~iscell(ch)
    ch = {ch};
end

if nargin ==3
    c2 = gunit;
end

for i = 1:length(ch)
    if isfield(data,ch{i})
        data.(ch{i}).line = ctransform_line(data.(ch{i}).line,c1,c2);
    end
end

