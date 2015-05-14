function bmech_removeevent(evt,fld,ch)

% bmech_removeevent(evt)
% 
% This m-file will remove events from your data. This step is usually done before final graphing
%
% ARGUMENTS
%  evt  ...   name of event(s) to remove as cell array of strings 
%             ex {'HS','TO'}. Default is all events
%  fld  ...   folder to operate on
%  ch   ...   specific channel to remove
% 
%
% Updated by Phil Dixon July 2009
%  - You can now specify which channel you wish to remove.
%    Removal of several (but not all) events at the same is not yet supported  
%
% Updated  by Phil Dixon Oct 2009
%  - changed the argument order
%
% updated by Phil Dixon Feb 2013
% - can remove all events from a single channel if desired
%
%----------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
%                                                                                            %                
% MAIN CONTRIBUTORS                                                                          %
%                                                                                            %
% Philippe C. Dixon         Dept. of Engineering Science. University of Oxford, Oxford, UK   %
% JJ Loh                    Medicus Corda, Montreal, Canada                                  %
% Yannick Michaud-Paquette  Dept. of Kinesiology. McGill University, Montreal, Canada        %
%                                                                                            %
% - This toolbox is provided in open-source format with latest version available on          %
%   GitHub: https://github.com/phild001                                                      %
%                                                                                            %
% - Users are encouraged to edit and contribute to functions                                 %
% - Please reference if used during preparation of manuscripts                               %                                                                                           %
%                                                                                            %
%  main contact: philippe.dixon@gmail.com                                                    %
%                                                                                            %
%--------------------------------------------------------------------------------------------%

if nargin ==0
    evt = 'all';
    fld = uigetfolder;
    cd(fld);
    ch = '';
    
end

if nargin ==1
   fld = uigetfolder;
   ch = '';
end

if nargin==2
    ch ='';
end
    

fl = engine('path',fld,'extension','zoo');

 for i = 1:length(fl)
    data = load(fl{i},'-mat');
    disp(['removing events from:',fl{i}]);
    data = data.data;
    data = removeevent(data,evt,ch);
     save(fl{i},'data');
end

function data = removeevent(data,evt,ch)
    
if ~iscell(evt)
    evt = {evt};
end

if isempty(ch)
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
