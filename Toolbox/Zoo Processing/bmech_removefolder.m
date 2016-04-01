function bmech_removefolder(fld,sfld)

%  bmech_removefolder(fld,sfld) removes trials from subfolder 'sfld' 
%
% ARGUMENTS
%  fld      ... root folder to operate on
%  sfld     ... subfolder to remove as cell array of strings


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

% Error checking
%
if ~iscell(sfld)
    sfld = {sfld};
end

s = filesep;    % determine slash direction based on computer type
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
        batchdisplay(fl{j},'deleting trial')
        delete(fl{j})
    end
    
    
    sfld_all = subdir(fld)';
    
    for j = 1:length(sfld_all)
        if isin(sfld_all{j},sfld{i}) && exist(sfld_all{j},'dir')==7
            batchdisplay(sfld_all{j},'removing folder')
            rmdir(sfld_all{j},'s')
        end
    end
    
    
end