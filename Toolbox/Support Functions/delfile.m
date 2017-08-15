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
% Updated by Philippe C. Dixon July 2015
% - bug fix with user display
% - added search directory below current working directory for MAC
%
% Updated by Philippe C. Dixon Nov 2016
% - delete now works on mac platform, no unique platform search
%
% Updated by Philippe C. Dixon Feb 2017
% - deletion occurs usig java function to improve speed performace
%   Test: 835 excel files
%         deleted in 001.293 sec using java
%         deleted in 177.187 sec using 'delfile'


tic                         % start timer
if ~iscell(fl)
    fl = {fl};
end

for i = 1:length(fl)
    
    if exist(fl{i},'file')==2
        batchdisp(fl{i},'deleting file')
        
        %delete(fl{i})
        java.io.File(fl{i}).delete();
       
    else
        disp('attempting to locate file in current working directory....')
        file = engine('fld',pwd,'search file',fl{i});
        
        if isempty(file)
            batchdisp('','file not found')
        else
            batchdisp('','deleting file')
            java.io.File(file).delete();
        end
    end
    
end

if i >1   % only show timer if deleting multiple files
    disp(' ')
    fprintf('Finished deleting data, ')
    toc
end
    
