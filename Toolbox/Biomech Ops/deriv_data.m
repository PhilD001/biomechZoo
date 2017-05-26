function data = deriv_data(data,ch,filt)

% data = DERIV_DATA(data,ch,f) differentiation of given channel(s) with filter options
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channel(s) to operate on (single string or cell array of strings)
%  filt     ...  Filter options
%                filt = 0: do not filter (default)
%                filt = 1: filter data using 4th order butterworth low-pass with 10 Hz cutoff
%                filt = struct: filter according to struc fields (see bmech_filter)
%  
% RETURNS
%  data    ...  Zoo data with differentiated channels appended with suffix '_dot'
%
% Notes
%  - see BMECH_DERIV for general function notes 
%
% See also bmech_deriv, deriv_line, gradient, filter_line

% Revision History
%
% Created by Philippe C. Dixon July 2016 
%
% Updated by Philippe C. Dixon May 2017


% Set defaults/check arguments
%
if nargin ==1
   error('missing channel arguments')
end

if nargin == 2
    filt =0;
end

if isnumeric(filt) 
    if filt ==1
    filt = struct;
    filt.type   = 'butterworth';
    filt.order  = 4;
    filt.pass   = 'lowpass';
    filt.cutoff = 10;
    end
end

if ~iscell(ch)
   ch = {ch}; 
end

suff = '_dot';


% Process channels
%
for i = 1:length(ch)
    section = getsection(data,ch{i});
    fsamp = data.zoosystem.(section).Freq;
    r = deriv_line(data.(ch{i}).line,fsamp,filt);
    data = addchannel_data(data,[ch{i},suff],r,section);    
end


