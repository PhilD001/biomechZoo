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
%  1) adding events can be done at any point during processing and can be called numerous times 
%  2) simply add new cases as required to compute new events
%
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
