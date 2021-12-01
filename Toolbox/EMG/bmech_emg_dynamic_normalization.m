function bmech_emg_dynamic_normalization(fld,ch,before_str,after_str, static_str)

% BMECH_EMG_DYNAMIC_NORMALIZATION(fld,ch before_str,after_str) will perform nonmalize filtereld EMG signals
%  1-  est. local max events for all channel (*_rect_RMS)
%  2-  est. global max based on local max events
%  3-  normlize  *_rect_RMS
%
% ARGUMENTS
%  fld          ... folder to operate on
%  ch           ... name of emg channels to process (cell array of strings)
%  before_str   ... string characters before subject_id
%  after_str    ... string characters after subject_id
%                   Example: File Name = 'Trimmed_HYA03_Walking_T02-level.zoo'
%                   Subject ID = HYA03
%                   before_str = ' Trimmed_'
%                   after_str = '_Walking'
%  static_str   ... str, name of static files (if any) to ignore
% *** note: if Subject ID is in the begining  of the file name
%                         before_str='';

% error checking
if nargin ==2
    before_str = '';
    after_str ='';
end

if nargin < 5
    static_str = 'Cal';
end

if ischar(ch)
    ch = {ch};
end

cd(fld)
% extract all non static files
fl_all = engine('path',fld,'extension','zoo');
fl_tmp = engine('path',fld,'extension','zoo','search file',static_str);
fl = setdiff(fl_all,fl_tmp);

% Estimating local max for each EMG channel
local_max_all_trial =struct();

for i = 1:length(fl)
    batchdisp(fl{i},'finding local max value of emg channels')
    data = zload(fl{i});
    [~, file_name] = fileparts(fl{i});
    if ~isempty(before_str) && ~isempty(after_str)
        subject_id  = extractBetween(file_name,before_str,after_str);
    else
        if ~isfield(data.zoosystem.Header, 'SubName')
            error('trial must contain a subject name field in data.zoosystem.Header')
        end
        subject_id = {deblank(data.zoosystem.Header.SubName)};
    end
    
    if any(strcmp(fieldnames(local_max_all_trial),subject_id{1,1}))
        [data,local_max_all_trial.(subject_id{1,1})] = max_of_data(data,ch,local_max_all_trial.(subject_id{1,1}));
    else
        local_max_all_trial.(subject_id{1,1}) = struct();
        [data,local_max_all_trial.(subject_id{1,1})] = max_of_data(data,ch,local_max_all_trial.(subject_id{1,1}));
    end
    
    zsave(fl{i},data);
end

% Estimating global max for a channel from all the trials of a subject
global_max = struct();
subject_id_all =fieldnames(local_max_all_trial);

for i=1: length(subject_id_all)
    ch_names = fieldnames(local_max_all_trial.(subject_id_all{i,1}));
    for j =1:length(ch_names)
        ch_local_max_data = local_max_all_trial.(subject_id_all{i,1}).(ch_names{j,1});
        global_max.(subject_id_all{i,1}).(ch_names{j,1}) = max(ch_local_max_data);
    end
end

% Dynamic Normalization
for i = 1:length(fl)
    batchdisp(fl{i},'emg dynamic normailization process')
    data = zload(fl{i});
    [~, file_name] = fileparts(fl{i});
    if ~isempty(before_str) && ~isempty(after_str)
        subject_id  = extractBetween(file_name,before_str,after_str);
    else
        if ~isfield(data.zoosystem.Header, 'SubName')
            error('trial must contain a subject name field in data.zoosystem.Header')
        end
        subject_id = {deblank(data.zoosystem.Header.SubName)};
    end
    
    for j = 1:length(ch)
        local_ch_name =ch{j};
        r = data.(local_ch_name).line;
        max_val = global_max.(subject_id{1,1}).(local_ch_name);
        norm_r = r/ max_val;                                                                             % normalizing by global max
        data = addchannel_data(data,[ch{j},'_normalized'],norm_r,'Analog');
        data.([ch{j},'_normalized']).event.global_max = [1, max_val, 0];
    end
    zsave(fl{i},data);
end



function [data,max_all] = max_of_data(data,emg_ch,max_all)

for i = 1:length(emg_ch)
    
    local_ch_name = emg_ch{i};
    r = data.(local_ch_name).line;
    local_max = max(r);
    ch_names = fieldnames(max_all);
    
    if any(strcmp(ch_names, local_ch_name))
        max_data = max_all.(local_ch_name);
        max_data = [max_data local_max];
        max_all.(local_ch_name) = max_data;
    else
        max_all.(local_ch_name) =local_max;
    end
    
    data = addevent_data(data,{local_ch_name},'local_max','max'); % adds max to each *_rect_RMS emg channel
    
end
