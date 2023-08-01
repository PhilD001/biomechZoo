function data = NaN_partition_data(data, chns_search)

% DATA = NAN_PARTITION_DATA(data) partitions data based on the presence of
% NaNs. Data will be trimmed based on the largest possible
% interval that contains non-NaN data for all channels. 
%
% ARGUMENTS
%  data         ...  Zoo data file (struct)
%  chns_search  ...  optional. List of channels to consider in the NaN search

% RETURNS
%  data ... partitionned zoo data
%
% see also, bmech_NaNpartition


% extract only channels of interest
if nargin==1
    chns_search = setdiff(fieldnames(data),{'zoosystem'});
end

if ischar(chns_search)
    if strcmp(chns_search, 'all')
        chns_search = setdiff(fieldnames(data),{'zoosystem'});
    end
end

str_stk = zeros(length(chns_search),1);
end_stk = zeros(length(chns_search),1);
for i = 1:length(chns_search)
    r = data.(chns_search{i}).line;
    r = r(:,1);              
    indx = isnan(r);
    str_stk(i) = find(indx==0,1,'first');
    end_stk(i) = find(indx==0,1,'last');
end

frm_str = max(str_stk);
frm_end = min(end_stk);

% add partition events
data.(chns_search{1}).event.first_nonNaN = [frm_str 0 0 ];
data.(chns_search{1}).event.last_nonNaN = [frm_end 0 0 ];


% partition data
data = partition_data(data,'first_nonNaN','last_nonNaN');


% save to zoosystem
data.zoosystem.Video.ORIGINAL_NAN_START_FRAME = data.zoosystem.Video.ORIGINAL_START_FRAME(1) + frm_str;
data.zoosystem.Video.NAN_END_FRAME = data.zoosystem.Video.ORIGINAL_END_FRAME(1) - (data.zoosystem.Video.CURRENT_END_FRAME(1) - frm_end);



