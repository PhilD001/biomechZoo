function str = cell2str(cellstr)

% converts cell array of string to string
% e.g. cellstr = {'hello'} --> str = 'hello';

if length(cellstr)~=1
    error('more than one string in cell array of strings')
end

str = cellstr{1};