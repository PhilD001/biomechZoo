function bmech_resample(fld,ch,p,q,method)

% BMECH_RESAMPLE(fld,ch,p,q,method) batch process resampling function without filtering
%
% ARGUMENTS
%  fld     ... Folder to batch process (string).
%  ch      ... Channel(s) to operate on (single string or cell array of strings).
%              Use 'Video' or 'Analog' to resample all video or analog channels
%  p       ... Numerator of fraction of sampling rate. Default = [];
%  q       ... Denominator of fraction of fraction of sampling rate. Default = []
%  method  ... Interpolation method used during resampling. Default 'linear'
%
% NOTES:
% - If p and q are not provided, then all channels of ch type will be resampled 
%   to the rate of the other type. e.g. bmech_resampe(fld,'Analog') resamples all
%   Analog channels to the 'Video' sampling rate
% - If only select channels are provided from a given type (e.g. only 'Fz1'
%   from 'Analog' channel list. zoosystem metainfo will provide incorrect
%   information.
%
% See also resample_data, bmech_normalize, normalize_line

% Revision History
%
% Created by Ashley Hannon, Montreal, Qc, CANADA 2008
%
% Updated by Philippe C. Dixon Aug 9th 20010
% - Now functions on single vectors
%
% Updated by Philippe C. Dixon March 2014
% - added capability to resamp event
% - zoosystem freq updated
%
% Updated by Philippe C. Dixon Nov 2015
% - cleaned up function for introduction into zoosystem v1.2
%
% Updated by Philippe C. Dixon March 2016
% - ability to resamp all video or analog channels by setting
%   ch to 'Video' or 'Analog'.
% - Bug fix: CURRENT_START_FRAME and CURRENT_END_FRAME now updated during
%   resampling.
%
% Updated by Philippe C. Dixon July 2016
% - removed filtering option
% - cleaned up function for consistency with zoosystem v1.3


if nargin==2
    p = [];
    q = [];
    method = 'linear';
end

if nargin==4
    method = 'linear';
end

fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl);
    batchdisplay(fl{i},'resampling')
    data = zload(fl{i});
    data = resample_data(data,ch,p,q,method);
    zsave(fl{i},data, ['Freq: ',num2str(p),' to ',num2str(q)]);    
end
