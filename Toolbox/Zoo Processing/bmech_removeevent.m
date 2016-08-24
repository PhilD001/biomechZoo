function bmech_removeevent(fld,evt,ch)

% BMECH_REMOVEEVENT(fld,evt,ch) removes events from data set. 
%
% ARGUMENTS
%  fld  ...   Folder to operate on
%  evt  ...   Name of event(s) to remove (string or cell array of strings) e.g.{'HS','TO'}. 
%             Default is 'all'
%  ch   ...   channels from which to remove events. Default is 'all'


% Revision History
%
% Updated by Philippe C. Dixon July 2009
%  - You can now specify which channel you wish to remove.
%    Removal of several (but not all) events at the same is not yet supported  
%
% Updated by Philippe C. Dixon Oct 2009
%  - changed the argument order
%
% Updated by Philippe C. Dixon Feb 2013
% - can remove all events from a single channel if desired
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
% - fixed bug in channel selection


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



% Set Defaults
%
if nargin ==0
    fld = uigetfolder;
    evt = 'all';
    ch = 'all';
end

if nargin ==1
    evt = 'all';
    ch = 'all';
end

if nargin==2
    ch = 'all';
end

    
cd(fld);


% Batch Process
%
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'removing events');
    data = removeevent(data,evt,ch);
    
    if isin(ch,'all')
        zsave(fl{i},data,['removed ',evt,' from all channels'])
    else
        zsave(fl{i},data,['removed ',evt,' from channel ',ch])
    end
    
end


 
function data = removeevent(data,evt,ch)
    
if ~iscell(evt)
    evt = {evt};
end

if ~iscell(ch)
    ch = {ch};
end


if isin(ch{1},'all') 
    ch = setdiff(fieldnames(data),{'zoosystem'});
end

if strcmp(evt{1},'all')
   
    for i = 1:length(ch)
        evts = fieldnames(data.(ch{i}).event);
        
        for j = 1:length(evts)
            data.(ch{i}).event = rmfield(data.(ch{i}).event,evts(j));
        end
    end
    
else
    
    
    for a = 1:length(evt)
        
        for i = 1:length(ch)
            evts = fieldnames(data.(ch{i}).event);
            
            if ~isempty(evts)
                
                for j =1:length(evts)
                    
                    if strcmp(evt{a},evts{j})
                        
                        data.(ch{i}).event = rmfield(data.(ch{i}).event,evts(j));
                    end
                end
            end
            
        end
        
        
        
    end
    
end
