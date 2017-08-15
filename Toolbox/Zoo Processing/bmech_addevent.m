function bmech_addevent(fld,ch,ename,type,sfld)

% BMECH_ADDEVENT(fld,ch,ename,type,sfld) batch process of event addition
%
% ARGUMENTS
%  fld      ... Folder to batch process (string).  
%  ch       ... Name of channel to add events to as string. ex Choose 'fz1'
%               or 'fz2' or 'all' for all channels
%  ename    ... The name of new event branch in zoo file as string
%  type     ... See line 47 ('max' 'min' 'toe off' heel strike'...) string
%  sfld     ... Subfolder of files not to include in addevent algorithm. Default ''
%
% NOTES:
% - adding events can be done at any point during processing and can be called numerous times
% - add new cases as required to compute new events in addevents.m
%
% See also addevent_data, bmech_removeevent, bmech_renameevent


% Revision History
%
% Created by Philippe C. Dixon 2008
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon Sept 2015
% - Additional argument 'sfld' can be used to exclude folder 'sfld' from
%   addevent algorithm. This can be useful when events do not 'make sence' for
%   a particular sub folder. e.g. a subfolder of static pose cannot have a
%   foot strike event. For these files the event would show [1 NaN 0]
%
% Updated by Philippe C. Dixon July 2017
% - Bug fix for option 'all' for ch (github bug report #4)


if nargin==4
    sfld = '';
end


% Get files to process
%
if ~isempty(sfld)
    fl  = engine('path',fld,'extension','zoo');
    sfl = engine('path',fld,'extension','zoo','folder',sfld);
    fl  = setdiff(fl,sfl);
else
    fl  = engine('path',fld,'extension','zoo');
end

cd(fld)


% Batch process
%
for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp( fl{i},['adding event ',ename])
    data = addevent_data(data,ch,ename,type);
    if strcmp(ch,'all')
        zsave(fl{i},data,['added ',type,' to all channels'])
    else
        zsave(fl{i},data,['added ',type,' to channel ',strjoin(ch)])
    end
    
end
