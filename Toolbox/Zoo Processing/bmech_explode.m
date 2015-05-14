function bmech_explode(fld,ch)

% bmech_explode(fld,ch) is used to split n x 3 data into three nx1
% channels. New channels have a dimension suffix (e.g. '_x', '_y', and '_z'
% for the 1st, 2nd, and 3rd columns of the matrix, respectively). 
% 
% ARGUMENTS
%   fld ... folder to explode
%   ch  ... channels to explode as cell array of strings. Default is all
%
% 
% Created by Philippe C. Dixon JJ Loh 2008
%
% Updated Sept 2011
% - User can selectively explode channels. Default is still 'all'
%
% Updated November 2011
% - If event data exists then they will be stored in channel_x.event 
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

if nargin ==0
    fld = uigetfolder('select folder containing data to explode');
    ch = 'all';
end

if nargin ==1
    ch = 'all';
end

if ~iscell(ch)
    ch = {ch};
end

cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'exploding data');
    data = explodechannel(data,ch);
    save(fl{i},'data');
end

