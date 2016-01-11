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


% set defaults
%
if nargin==0
    fld = uigetfolder;
end



% Batch process
%
cd(fld)

fl = engine('fld',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'NaNpartition');
    data = NaNpartition(data);
    data = partitiondata(data,'data_start','data_end');
    zsave(fl{i},data);
end



function data = NaNpartition(data)

ch = setdiff(fieldnames(data),{'zoosystem'});

str_stk = [];
end_stk = [];


for i = 1:length(ch)
    r = data.(ch{i}).line;
    r = r(:,1);
    indx = isnan(r);
    str_plate = find(indx==0,1,'first');
    end_plate = find(indx==0,1,'last');
    str_stk = [str_stk;str_plate];
    end_stk = [end_stk;end_plate];
end

frm_str = max(str_stk);
frm_end = min(end_stk);

% add partition events
%
data.(ch{1}).event.data_start = [frm_str 0 0 ];
data.(ch{1}).event.data_end = [frm_end 0 0 ];

% save to zoosystem

data.zoosystem.Video.ORIGINAL_NAN_START_FRAME = data.zoosystem.Video.ORIGINAL_START_FRAME(1) + frm_str;
data.zoosystem.Video.NAN_END_FRAME = data.zoosystem.Video.ORIGINAL_END_FRAME(1) - (data.zoosystem.Video.CURRENT_END_FRAME(1) - frm_end);

