function bmech_merge(fld,ch)

% BMECH_MERGE(fld,ch) batch process merging of exploded channels
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string).
%  ch       ...  Channel(s) to operate on (cell array of 3 strings) or
%                new channel to create (cell aray of 1 string)
%
% NOTES
% - This function wil merge three exploded channels e.g. 'a_x', 'a_y','a_z' into 'a'
%
% See also mergechannel_data, bmech_explode

% Revision history
%
% Created by Philippe C. Dixon July 2016

cd(fld);
fl = engine('path',fld,'extension','zoo');

if nargin == 1
    ch = {'all'};
end

% Error check
%
if ~iscell(ch)
    ch = {ch};
end



for i = 1:length(fl)
    data = zload(fl{i});
    
    if ismember(ch, 'all')
        ch = get_all_exploded_channels(data);
    end
    
    batchdisp(fl{i},'merging exploded data');
    for j = 1:length(ch)
        ch_ex  = explodelist({ch{j}});
        data = mergechannel_data(data,ch_ex);
    end
    zsave(fl{i},data);
end


function ch = get_all_exploded_channels(data)

chns = setdiff(fieldnames(data), 'zoosystem');
ch = cell(length(chns));
for i = 1:length(chns)
    chn = chns{i};
    if strfind(chn, '_x')
        indx =strfind(chn, '_x');
        ch{i} = chn(1:indx-1);
    end
end

ch(cellfun(@isempty,ch)) = [];   % That's some hot programming
ch = ch';

