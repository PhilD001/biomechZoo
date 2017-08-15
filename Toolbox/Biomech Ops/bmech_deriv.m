function bmech_deriv(fld,ch,filt)

% BMECH_DERIV(fld,ch,f) batch process differentiation of given channel(s) with filter options
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string). 
%  ch       ...  Channel(s) to operate on (single string or cell array of strings) 
%  filt     ...  Filter options
%                filt = 0: do not filter (default)
%                filt = 1: filter data using 4th order butterworth low-pass with 10 Hz cutoff
%                filt = struct: filter according to struc fields (see bmech_filter)
%                
% Notes
%  -Sampling rate will be extracted from zoofile according to channel type (Video or Analog)
%  -Differentiated channel(s) will be appended with suffix '_dot'
%  -To compute nth derivative, run function n times 
%
% See also deriv_data, deriv_line, gradient, filter_line

% Revision History
%
% Created based on earlier functions from JJ Loh 2006
%
% Updated by Philippe C. Dixon July 2008:
%  - Use of function gradient. Gradient conserves length of input vector.
%  - can handle vectors as columns or rows
%
% Updated by Philippe C. Dixon 2013,2014
% - clean up for for better readability
% - allow choice of cutoff frequency for filtering
% - preallocation of deriv_stk
% - full customization of filtering properties possible by setting f as a struct
%
% Part of the bmechZoo toolbox v1.3 Copyright (c) 2006-2016 (Main contributors) 
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh


% Set defaults/check arguments
%
if nargin==0
    fld = uigetfolder('select folder to process');
end

if nargin ==1
   error('missing channel arguments')
end

if nargin == 2
    filt = 0;
end

if isnumeric(filt) && filt ==1
    filt = struct;
    filt.type   = 'butterworth';
    filt.order  = 4;
    filt.pass   = 'lowpass';
    filt.cutoff = 10;
end

if ~iscell(ch)
   ch = {ch}; 
end



% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'differentiating:');
    data = deriv_data(data,ch,filt);
    zsave(fl{i},data, ch);
end


