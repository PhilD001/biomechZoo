function bmech_addevent(fld,ch,ename,type,sfld)

% bmech_addevent(fld,ch,ename,type) is used to add information to the
% event banch of a given channel
%
% ARGUMENTS
%
%  fld    ... folder containing files
%  ch     ... name of channel to add events to as string. ex Choose 'fz1'
%              or'fz2' or 'all' for all channels
%  ename  ... the name of new event branch in zoo file as string
%  type   ... see line 47 ('max' 'min' 'toe off' heel strike'...) string
%  sfld   ... subfolder of files not to include in addevent algorithm. Default ''
%
% NOTES:
% - adding events can be done at any point during processing and can be called numerous times
% - add new cases as required to compute new events in addevents.m


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


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


if fld ==1   % for backwards compatibility
    fld = uigetfolder;
end

if nargin==4
    sfld = '';
end


% Get files to process
%
if ~isempty(sfld)
    fl = engine('path',fld,'extension','zoo');
    sfl = engine('path',fld,'extension','zoo','folder',sfld);
    fl = setdiff(fl,sfl);
else
    fl = engine('path',fld,'extension','zoo');
end

cd(fld)

if ischar(ch)
    ch = {ch};
end


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay( fl{i},['adding event ',ename])
    data = addevents(data,ch,ename,type);
    if isin(ch{1},'all')
        zsave(fl{i},data,['added ',type,' to all channels'])
    else
        zsave(fl{i},data,['added ',type,' to channel ',strjoin(ch)])
    end
    
end
