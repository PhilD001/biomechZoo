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


% Part of the Zoosystem Biomechanics Toolbox v1.2
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
    save(fl{i},'data');
end
