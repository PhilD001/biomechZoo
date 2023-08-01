function bmech_NaNpartition(fld, chns_search)

% bmech_NaNpartition(fld) parititons all channels based on NaNs. All channels are
% partitionned over the range of frames where all channels contain numbers
%
% ARGUMENTS
% fld          ...   folder to operate on
% chns_search  ...  optional. List of channels to consider in the NaN search

%
% NOTES
% - Algorithm search all channels for the last NaN at the start of the data
%   and the first NaN at the end of the data. For the NaNs at the start,
%   the largest index is retained as the start of the partition. For
%   the NaNs at the end, the smallest index is retained as the end of the
%   partition.


% Revision History
%
% Created by Phil Renaud and Philippe C. Dixon June 2015
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


% set defaults
if nargin==0
    fld = uigetfolder;
    chns_search = 'all';
end

if nargin==1
    chns_search = 'all';
end


% Batch process
%
cd(fld)
fl = engine('fld',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'NaNpartition');
    data = NaNpartition_data(data, chns_search);
    zsave(fl{i},data);
end
