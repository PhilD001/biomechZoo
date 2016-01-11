function bmech_addevent(fld,ch,ename,type)

       
% bmech_addevent(fld,ch,ename,type,cut) is used to add information to the
% event banch of a given channel
%
% ARGUMENTS
%
%  fld    ... folder containing files
%  ch     ... name of channel to add events to as string. ex Choose 'fz1'
%              or'fz2' or 'all' for all channels
%  ename  ... the name of new event branch in zoo file as string
%  type   ... see line 47 ('max' 'min' 'toe off' heel strike'...)string
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


if fld ==1   % for backwards compatibility
    fld = uigetfolder;
end

cd(fld)
fl = engine('path',fld,'extension','zoo');

if ischar(ch)
    ch = {ch};
end


for i = 1:length(fl);
    data = zload(fl{i});
    batchdisplay( fl{i},['adding event ',ename]);
    data = addevents(data,ch,ename,type);
    if isin(ch{1},'all')
        zsave(fl{i},data,['added ',type,' to all channels'])
    else
        zsave(fl{i},data,['added ',type,' to channel ',strjoin(ch)])
    end
    
end
