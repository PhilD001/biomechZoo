function bmech_partition(fld,evt1,evt2,nfld)

% BMECH_PARTITION(fld,evt1,evt2,nfld) partitions (cuts) files from evt1 and evt2.
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string). Default: folder selection window.
%  evt1     ...  Name of first event as a string.
%  evt2     ...  Name of second event as a string.
%  nfld     ...  Folder(s) NOT to partition (string or cell array of strings). Default: ''
%
% See also partition_data


% Revision History
%
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon August 2009
% - functions within ensembler now
%
% Updated by Philippe C. Dixon February 2012
% - multiple excluded folders are now possible
%
% Updated by Philippe C. Dixon May 2015
% - improved help
% - cleaned up code
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon May 2017
% - Improved help section


% Set Defaults
%
if nargin == 3
    nfld  = '';
end


% Batch proces
%
cd(fld);
fl = engine('path',fld,'extension','zoo');
nfl = {};
if isempty(nfld)
    
    for i = 1:length(fl)
        data = zload(fl{i});
        
        if ~isempty(findfield(data,evt1)) && ~isempty(findfield(data,evt2))
            batchdisp(fl{i},'partitioning');
            data = partition_data(data,evt1,evt2);
            zsave(fl{i},data,[evt1,' to ',evt2])
        else
            nfl{i} = fl{i}; %#ok<AGROW>
        end

    end
    
else
    
    for i = 1:length(fl)
        
        if ~isin(fl{i},nfld)
            data = zload(fl{i});
            batchdisp(fl{i},'partitioning');
            data = partition_data(data,evt1,evt2);
            zsave(fl{i},data,[evt1,' to ', evt2])
        else
            nfl{i} = fl{i}; %#ok<AGROW>
        end
    end
end

nfl(cellfun(@isempty,nfl)) = [];   
for i = 1:length(nfl)
    batchdisp(nfl{i},'not partitioning');
end