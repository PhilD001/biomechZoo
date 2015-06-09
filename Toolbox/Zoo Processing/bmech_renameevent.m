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




cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    batchdisplay(fl{i},['renaming event from ',evt,' to ',nevt])
    data = zload(fl{i});
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





