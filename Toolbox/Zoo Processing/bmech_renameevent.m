function bmech_renameevent(fld,evt,nevt)
      
% bmech_renameevent(fld,evt,nevt) will rename events in your data. 
%
% ARGUMENTS
%  fld   ...  folder to operate on
%  evt   ...  name of existing event as a string
%  nevt  ...  name of new event as a string


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


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    batchdisplay(fl{i},['renaming event from ',evt,' to ',nevt])
    data = zload(fl{i});
    data = renameevent(data,evt,nevt,fl{i});
    zsave(fl{i},data);
end



function data = renameevent(data,evt,nevt,fl)


ch = fieldnames(data);
ch = setdiff (ch,{'zoosystem'});

for i = 1:length(ch)

    if isfield(data.(ch{i}).event,evt)
        disp(['rename event:',fl]);
        data.(ch{i}).event.(nevt)=data.(ch{i}).event.(evt);  
        data.(ch{i}).event = rmfield(data.(ch{i}).event, evt);
    end
end





