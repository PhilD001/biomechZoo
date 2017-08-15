function bmech_removechannel(fld,ch,action)

% BMECH_REMOVECHANNEL(fld,ch,action) batch process removal of unwanted channels
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string)
%  ch       ...  Channel(s) to operate on (single string or cell array of strings).
%  action   ...  Action to take on ch (string): 'keep' or 'remove' channels in ch
%
% See also removechannel_data, bmech_removechannel_example


% Created 2008
%
% Updated by Philippe C. Dixon August 2010
% -  if channels don't exist, error will not occur
%
% Updated by Philippe C. Dixon February 2014
% - Removed channels are also removed from zoosystem channel list
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon July 2016
% - reformatted for zosystem v1.3



% Set defaults/Error check
%
if ~iscell(ch)
    ch = {ch};
end


% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'removing channel');
    
    [chn,suff] = getchannels(data,ch,action);
    
    data = removechannel_data(data,chn);
    zsave(fl{i},data, ['removed ',num2str(length(chn)),' ',suff]);
end


function [ch,suff] = getchannels(data,ch,action)

if strcmp(action,'keep')
    allch = setdiff(fieldnames(data),'zoosystem');
    ch = (setdiff(allch,ch));
end

if length(ch)==1
    suff = 'channel';
else
    suff = 'channels';
end

















