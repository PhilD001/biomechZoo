function bmech_filter(fld,ch,filt)

% BMECH_FILTER(fld,ch,filt) batch process filtering of given channel(s) with multiple options
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string). Default: folder selection window. 
%  ch       ...  Channel(s) to filter (single string or cell array of strings).
%                Use 'Video','Analog',or 'all' to filter video, analog, or
%                all channels. Default 'all'.
%  filt     ...  Filter options (struct). Default: 4th order butterworth low-pass filter
%                with 10Hz cutoff.
%                filt can contain the following fields:
%                filt.type   = 'butterworth','chebychev I/II','eliptic','bessel'
%                filt.cutoff =  integer cutoff frequency.
%                filt.order  =  interger filter order
%                filt.pass   = 'lowpass','highpass'
%                filt.srip   =  stopband ripple (see 'cheby1,cheby2,ellip)
%                filt.prip   =  peak-to-peak ripple (see 'ellip')
%
% NOTES
% - Sampling rate will be read from zoo file.
%
% See also filter_data, filter_line, butter, cheby1, cheby2, ellip,besself


% Revision history:
%
% Created by JJ Loh 2006
%
% Updated by Philippe C Dixon 2007-2016
% - improved functionality
% - improved help
% - additional settings


% Default settings/error checking
%
if nargin==0
    fld = uigetfolder('select folder to process');
    ch = 'all';
    filt.cutoff = 10;
    filt.type = 'butterworth';
    filt.order = 4;
    filt.pass = 'lowpass';
end

if nargin==1
    ch = 'all';
    filt.cutoff = 10;
    filt.type = 'butterworth';
    filt.order = 4;
    filt.pass = 'lowpass';
end

if nargin==2
    filt.cutoff = 10;
    filt.type = 'butterworth';
    filt.order = 4;
    filt.pass = 'lowpass';
end


% Display filter summary
%
disp('----------------Filter settings------------')
disp(['Filter type:                    ',filt.type])
disp(['Filter Order:                   ',num2str(filt.order)])
disp(['Filter Pass Range:              ',filt.pass]);
disp(['Filter Cutoff Frequency:        ', num2str(filt.cutoff)])
if ismember(filt.type,{'chebychev I','chebychev II','eliptic'})
    disp(['Filter stopband ripple:     ', num2str(filt.srip)])
end

if ismember(filt.type,{'eliptic'})
    disp(['Filter peak-to-peak ripple: ', num2str(filt.prip)])
end
disp(' ')
disp('Channels to be filtered:')
if iscell(ch)
    disp(makecolumn(ch));
else
    disp(ch)
end
disp(' ')

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');
msg = prepmsg(filt,ch);

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'filtering')
    data = filter_data(data,ch,filt);
    zsave(fl{i},data,msg);
end



function msg = prepmsg(filt,ch)

msg = [filt.type,' ',num2str(filt.cutoff),'Hz ',num2str(filt.pass),'pass ',num2str(filt.order),'th order',];

if ismember(filt.type,{'chebychev I','chebychev II','eliptic'})
    msg = [msg, 'stopband ripple',num2str(filt.srip)];
end

if ismember(filt.type,{'eliptic'})
    msg = [msg, 'peak ripple',num2str(filt.prip)];
end

if iscell(ch)
    msg = [msg, ' on channels:'];
    for i = 1:length(ch)
        msg = [msg,' ',ch{i}]; %#ok<AGROW>
    end
    
else
    msg = [msg, ' on channels: ',ch];
end


