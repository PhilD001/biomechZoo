function event_names = bmech_feature_extraction(fld, ch, method)

% BMECH_FEATURE_EXTRACTION extracts basic statistical features from line data 
%
% ARGUMENTS
%  fld           ...   string, folder to batch process.   
%  ch            ...   string, all channel name.
%  method        ...   features extraction method 'None' currently, future updates will have PCA, LDA, etc...
%
% RETURNS
%  event_names   ...   struct, names of features extracted.


if nargin < 2
   error("missisng inputs")
end

if nargin == 2
    method = 'None';
end

fl = engine('fld', fld, 'extension', 'zoo');
for f = 1:length(fl)
    batchdisp(fl{f}, 'computing features')
    data = zload(fl{f});
    [data, event_names] = feature_extraction_data(data, ch, method);
    zsave(fl{f}, data, [num2str(length(event_names)), ' features added: ', strjoin(event_names)])
end


function [data, events]= feature_extraction_data(data,ch,method)
if contains(method,'None')
    for i = 1:length(ch)
        [data, events] = feature_extraction_line(data,ch{i});
    end
else
    error(['Not implemented error: Feature extraction method ', method, 'not available'])
end


function [data, events] = feature_extraction_line(data,ch)
disp(['Computing features for ',ch])
data.(ch).event.Min=[0 0 min(data.(ch).line)];
data.(ch).event.Max=[0 0 max(data.(ch).line)];
data.(ch).event.Sum=[0 0 sum(data.(ch).line)];
data.(ch).event.mean=[0 0 mean(data.(ch).line)];
data.(ch).event.std=[0 0 std(data.(ch).line)];
data.(ch).event.median=[0 0 median(data.(ch).line)];
data.(ch).event.lenght=[0 0 length(data.(ch).line)];
Lmax=data.(ch).line(local_max(data.(ch).line));
if isempty(Lmax)
    Lmax=1;
end
data.(ch).event.meanLmax=[0 0 mean(Lmax)];
data.(ch).event.sumLmax=[0 0 sum(Lmax)];
data.(ch).event.lenghtLmax=[0 0 length(Lmax)];
Lmin=data.(ch).line(islocalmin(data.(ch).line));
if isempty(Lmin)
    Lmin=1;
end
data.(ch).event.meanLmin=[0 0 mean(Lmin)];
data.(ch).event.sumLmin=[0 0 sum(Lmin)];
data.(ch).event.lenghtLmin=[0 0 length(Lmin)];
data.(ch).event.RatioMaxMin=[0 0 max(Lmax)/min(Lmin)];
data.(ch).event.RatioMinMax=[0 0 min(Lmax)/max(Lmax)];

events = fieldnames(data.(ch).event);