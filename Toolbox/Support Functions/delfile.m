function delfile(fl)

% DELFILE(fl) deletes a single file or group of files
% 
% ARGUMENTS
% fl  ... 'string' for single file or cell array of strings for multiple files
%
% NOTES
% - works on MAC and PC platforms
%


% Revision History
%
% Created by Philippe C. Dixon Jan 3rd 2013
%
% Updated by Philippe C. Dixon March 24th 2015
% - can delete multiple files
%
% Updated by Philippe C. Dixon May 2015
% - ability to delete hidden files implemented for PC platform 


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 



if ~iscell(fl)
    fl = {fl};
end


for i = 1:length(fl)
    
    if exist(fl{i},'file')~=2
        error(fl{i},'file does not exist, check path')
    else
        batchdisplay(fl{i},'deleting file')
    end
    
    
    if ispc
        % dos(['erase "',fl{i},'"']);
        delete(fl{i}) 
    else
        unix(['rm -f -R ' '"' fl{i} '"']);
    end
    
    
    
    
end

