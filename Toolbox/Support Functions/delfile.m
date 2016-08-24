function delfile(fl)

% DELFILE(fl) deletes a single file or group of files
% 
% ARGUMENTS
% fl  ... 'string' for single file or cell array of strings for multiple files
%
% See also outlier, bmech_removefolder


% Revision History
%
% Created by Philippe C. Dixon Jan 3rd 2013
%
% Updated by Philippe C. Dixon March 24th 2015
% - can delete multiple files
%
% Updated by Philippe C. Dixon May 2015
% - ability to delete hidden files implemented for PC platform 
%
% Updated by Philippe C. Dixon Jult 2015
% - bug fix with user display 
% - added search directory below current working directory for MAC


if ~iscell(fl)
    fl = {fl};
end


for i = 1:length(fl)
    
    if exist(fl{i},'file')==2
        batchdisplay(fl{i},'deleting file')
   
    if ispc
        % dos(['erase "',fl{i},'"']);
        delete(fl{i}) 
    else
        unix(['rm -f -R ' '"' fl{i} '"']);
    end
    
    else
       disp('attempting to locate file in current working directory....')
       
       file = engine('fld',pwd,'search file',fl{i});
       
       if isempty(file)
              batchdisplay(file{1},'file not found')
       else
           delfile(file{i})
       end
    end
    
end

