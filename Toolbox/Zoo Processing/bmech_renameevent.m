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


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the 
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement 
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of 
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.



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





