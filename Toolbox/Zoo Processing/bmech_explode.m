function bmech_explode(fld,ch)

% BMECH_EXPLODE(FLD,CH) is used to split n x 3 data into three n x 1
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


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


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

