function bmech_removeevent(evt,fld,ch)

% bmech_removeevent(fld,evt,ch)
% 
% This m-file will remove events from your data. This step is usually done before final graphing
% to avoid having to clear your graphs
%
% ARGUMENTS
%  evt  ...   name of event(s) to remove as cell array of strings e.g.{'HS','TO'}. Default is 'all'
%  fld  ...   folder to operate on
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



% Part of the Zoosystem Biomechanics Toolbox 
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
    save(fl{i},'data');
end


 
function data = removeevent(data,evt,ch)
    
if ~iscell(evt)
    evt = {evt};
end

if ~iscell(ch)
    ch = {ch};
end


if isin(ch,'all') 
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
