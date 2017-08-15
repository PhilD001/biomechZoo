function bmech_normalize(fld,ch,datalength,method)

% BMECH_NORMALIZE(fld,ch,datalength,method) batch process time normalization 
%
% ARGUMENTS
%  fld        ... Folder to batch process (string). Default: folder selection window.  
%  ch         ... Channel(s) to operate on (single string or cell array of strings). 
%                 Use 'Video','Analog', or 'all' to filter all video, analog or all 
%                 channels, respectively.Default 'all'
%  datalength ... Normalize data to a specific length. Data will have datalength+1 frames.
%                 Default: 100 (101 frames)
%  method     ... method to interpolate data. Default 'linear'.
%                 See interp1 for more options
%
% NOTES
% - Normalization will not recalculate an event value. It will only recalculate the 
%   event index. Thus an event may not 'lie' exactly on a normalized line. 
%
% See also interp1, normalize_data, normalize_line

% Revision history: 
%
% Updated by Philippe C. Dixon 2010
% - this function now normalizes event data as well
% - function only runs in batch file mode, 
% -Event normalization verified and improved. 
%
% Updated by Philippe C. Dixon 2015
% - Help improved
% - implemented  'zsave' procedure 
%
% Updated by Philippe C. Dixon Jan 2016 
% - Interpolation can be performed using any method available in 'interp1' function


% Set defaults
%
if nargin==0
    fld = uigetfolder('select folder to process');
    ch = 'all';
    datalength = 100;
    method = 'linear';
end

if nargin ==1
    ch = 'all';
    datalength=100;
    method = 'linear';
end

if nargin ==2
    datalength=100;
    method = 'linear';
end

if nargin ==3
    method = 'linear';
end



% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'normalizing channel(s)');
    data = normalize_data(data,ch,datalength,method);
    zsave(fl{i},data, [num2str(datalength+1) ' frames, method: ',method]);
end



