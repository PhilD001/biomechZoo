function bmech_renameevent(fld,evt,nevt)
      
% This m-file will rename events in your data. Used to correct
% mistakes,etc...
%
% ARGUMENTS
% fld   ...  folder to operate on
% evt   ...  name of existing event as a string
% nevt  ...  name of new event as a string
%
% Create by Phil Dixon Nov 2008
%
% updated by Phil Dixon, Oct 2009
% - old event is also deleted 
%


cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = load(fl{i},'-mat');
    data = data.data;
    data = renameevent(data,evt,nevt,fl{i});
    save(fl{i},'data');
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





