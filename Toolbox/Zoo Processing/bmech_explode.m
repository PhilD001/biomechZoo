function bmech_explode(fld,ch)

% bmech_explode(fld,ch) is used to split n x 3 data into three n x 1
% channels. New channels have a dimension suffix (e.g. '_x', '_y', and '_z'
% for the 1st, 2nd, and 3rd columns of the matrix, respectively). 
% 
% ARGUMENTS
%   fld ... folder to explode
%   ch  ... channels to explode as cell array of strings. Default is all


% Revision History
%
% Created by Philippe C. Dixon JJ Loh 2008
%
% Updated Sept 2011
% - User can selectively explode channels. Default is still 'all'
%
% Updated November 2011
% - If event data exists then they will be stored in channel_x.event 
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Dr. Philippe C. Dixon, Harvard University. Boston, USA.
% Yannick Michaud-Paquette, McGill University. Montreal, Canada.
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
    zsave(fl{i},data);
end

