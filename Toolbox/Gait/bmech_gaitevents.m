function bmech_gaitevents(fld,sfld,delta)

% BMECH_GAITEVENTS(fld) estimates foot strike (FS) and foot off (FO) events during gait 
%
% ARGUMENTS
%  fld     ...    Folder to operate on
%  delta   ...    Threshold for peak detection. Default 100. See peakdet
%                 for more details
%  sfld    ...    Folder not to process. For example, this could be a static folder
%                 without any events
%
% See also gaitevents_data, ZeniEventData, peakdet
%
% NOTES
% - Algorithm based on oscillation of the heel marker about the sacrum (coord method) 
%   acording to the Zeni method. See 'Two simple methods for determining gait events 
%   during treadmill and overground walking using kinematic data'. 
%   Zeni, Richards, Higginson. Gait Posture. 2008 May; 27(4): 710–714.


% Revision History
%
% Created by Philippe C. Dixon August 12th 2017
% - Based on existing m-file from DPhil thesis 2015




% Set peak detection threshold 
%
if nargin==1
    sfld = 'Static';
    delta = 100;
end

if nargin==2
    delta = 100;
end


% Find files
% - Try to ignore any static type files
cd(fld)
fl_static = engine('path',fld,'extension','zoo','search path',sfld);
fl = engine('path',fld,'extension','zoo');
fl = setdiff(fl,fl_static);

% Batch process
%
for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'identifying gait events');
    data = gaitevents_data(data,delta); 
    zsave(fl{i},data);
end