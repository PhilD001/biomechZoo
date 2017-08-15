function bmech_explode(fld,ch)

% BMECH_EXPLODE(fld,ch) batch process split of n x 3 channel data into three n x 1
% channels. New channels have a dimensional suffix (e.g. '_x', '_y', and '_z'
% for the 1st, 2nd, and 3rd columns of the matrix, respectively). 
% 
% ARGUMENTS
%  fld      ...  Folder to batch process (string). Default: folder selection window. 
%  ch       ...  Channels to explode (single string or cell array of strings). 
%                Default: explode all channels 'all'
%
% See also explode_data, bmech_merge 

% Revision History
%
% Created by Philippe C. Dixon JJ Loh 2008
%
% Updated Sept 2011
% - User can selectively explode channels. Default is still 'all'
%
% Updated November 2011
% - If event data exists then they will be stored in channel_x.event 
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'



% Set defaults/error check
if nargin ==0
    fld = uigetfolder('select folder containing data to explode');
    ch = 'all';
end

if nargin ==1
    ch = 'all';
end

if ~iscell(ch)
    ch = {ch};
end

% Batch process
%
cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'exploding data');
    data = explode_data(data,ch);
    zsave(fl{i},data);
end

