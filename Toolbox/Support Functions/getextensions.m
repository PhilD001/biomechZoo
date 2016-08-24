function ext = getextensions(fl)

% ext = getextensions(fl) returns file types from list of files
%
% ARGUMENTS
% fl    ...   cell array of strings containing files. Usually from engine
%
% RETURNS
% ext   ...   file extension



ext = cell(size(fl));

for i = 1:length(fl)
    ext{i} = extension(fl{i});  
end


ext = unique(ext);