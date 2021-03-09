function bmech_renameevent(fld,evt,nevt)
      
% bmech_renameevent(fld,evt,nevt) will rename events in your data. 
%
% ARGUMENTS
%  fld   ...  folder to operate on
%  evt   ...  name of existing event as cell array of strings
%  nevt  ...  name of new events as cell array of string


% Revision History
%
% Create by Philippe C. Dixon Nov 2008
%
% updated by Philippe C. Dixon, Oct 2009
% - old event is also deleted 
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon Oct 2016
% - Function can handle cell array of strings
% - Added extra error checking



% Error checking
%
% check for single string instead of cell array of strings
%
if ~iscell(evt)
    evt = {evt};
end

if ~iscell(nevt)
    nevt= {nevt};
end


if length(evt)~=length(nevt)
    error('number of new name events does not match number of old channel names to replace')
end
    
disp(' ')
disp('renaming the following events:')
for i = 1:length(evt)
    disp(['renaming ', evt{i}, ' to ',nevt{i}])
end

disp(' ')



% Batch process
%
cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    batchdisp(fl{i},'renaming events')
    data = zload(fl{i});
    data = renameevent_data(data,evt,nevt);
    zsave(fl{i},data);
end








