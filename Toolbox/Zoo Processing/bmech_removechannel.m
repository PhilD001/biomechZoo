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
%
% Updated by Philippe C. Dixon December 2017
% - Better support for invalid 'action' input


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
    batchdisp(fl{i},'removing channel');
    
    [chn,suff] = getchannels(data,ch,action);
    
    data = removechannel_data(data,chn);
    zsave(fl{i},data, ['removed ',num2str(length(chn)),' ',suff]);
end


function [nch,suff] = getchannels(data,och,action)

och = makecolumn(och);

if strcmp(action,'keep')
    allch = setdiff(fieldnames(data),'zoosystem');
    nch = setdiff(allch,och);
elseif strcmp(action,'remove')
    nch = och;
else
    error(['unknown action ',action, ' please select ''keep'' or ''remove'''])   
end

if length(nch)==1
    suff = 'channel';
else
    suff = 'channels';
end

















