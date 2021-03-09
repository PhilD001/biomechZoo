function bmech_removefolder(fld,sfld)

% BMECH_REMOVEFOLDER(fld,sfld) batch process removal of trials from subfolder 'sfld' 
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string) 
%  sfld     ...  Subfolder to remove (cell array of strings)


% Error checking
%
if ~iscell(sfld)
    sfld = {sfld};
end

s = filesep;                                            % get slash direction based on computer 
indx = strfind(sfld{1},s);

if isempty(indx)
    
    if ispc
        sfld{1} = strrep(sfld{1},'/',s);
    else
        sfld{1} = strrep(sfld{1},'\',s);
    end
end

% Remove sfld data and folder
%
for i = 1:length(sfld)
    
    fl = engine('path',fld,'search path',sfld{i});
    
    for j = 1:length(fl)
        batchdisp(fl{j},'deleting trial')
        delete(fl{j})
    end
    
    sfld_all = subdir(fld)';
    
    for j = 1:length(sfld_all)
        if isin(sfld_all{j},sfld{i}) && exist(sfld_all{j},'dir')==7
            batchdisp(sfld_all{j},'removing folder')
            rmdir(sfld_all{j},'s')
        end
    end
    
    
end