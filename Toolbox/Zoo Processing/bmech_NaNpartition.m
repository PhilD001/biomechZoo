function bmech_NaNpartition(fld)

% bmech_NaNpartition(fld) parititons all channels based on NaNs. All channels are
% partitionned over the range of frames where all channels contain numbers
%
% ARGUMENTS
% fld  ...   folder to operate on
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
end

% Batch process
%
cd(fld)
fl = engine('fld',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'NaNpartition');
    data = NaNpartition(data);
    data = partition_data(data,'data_start','data_end');
    zsave(fl{i},data);
end


function data = NaNpartition(data)

ch = setdiff(fieldnames(data),{'zoosystem'});

str_stk = zeros(length(ch),1);
end_stk = zeros(length(ch),1);

for i = 1:length(ch)
    r = data.(ch{i}).line;
    r = r(:,1);
    indx = isnan(r);
    str_stk(i) = find(indx==0,1,'first');
    end_stk(i) = find(indx==0,1,'last');
end

frm_str = max(str_stk);
frm_end = min(end_stk);

% add partition events
data.(ch{1}).event.data_start = [frm_str 0 0 ];
data.(ch{1}).event.data_end = [frm_end 0 0 ];

% save to zoosystem
data.zoosystem.Video.ORIGINAL_NAN_START_FRAME = data.zoosystem.Video.ORIGINAL_START_FRAME(1) + frm_str;
data.zoosystem.Video.NAN_END_FRAME = data.zoosystem.Video.ORIGINAL_END_FRAME(1) - (data.zoosystem.Video.CURRENT_END_FRAME(1) - frm_end);

