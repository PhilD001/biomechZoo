function data = filter_data(data,ch,filt)

% data = FILTER_DATA(data,ch,filt) filtering of given channel(s) with filter options
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channel(s) to operate on (single string or cell array of strings).
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
% RETURNS
%  data    ...   Zoo data with chosen channels filtered
%
% NOTES
% - Sampling rate will be read from zoo file.
%
% See also bmech_filter, filter_line, butter, cheby1, cheby2, ellip,besself


% Revision history:
%
% Created by JJ Loh 2006
%
% Updated by Philippe C Dixon July 2017
% - made consistent with zoosystem v1.3 updates
% - for force plates, replaces leading and trailing 'pure' zeros by NaNs
%   before filtering to remove filter dip effects. Zeros are replaced after
%   filtering
%
% Updated by philippe C. Dixon Dec 2016
% - fixed bug to allow missing channels to be bypassed

% Set defaults/check arguments
%

if ismember(ch,{'Video','Analog'})                         % extract all video or
    ch = data.zoosystem.(ch).Channels;                     % analog channels
end

if ismember(ch,'all')
    ch = setdiff(fieldnames(data),'zoosystem');
end

if ~iscell(ch)                                             % convert single channel string
    ch = {ch};                                             % to cell array of strings
end

if nargin==2
    filt = setFilt;
end

% filter each channel
%
for j = 1:length(ch)
    
    if strcmp(ch{j},'zoosystem')
        disp('skipping zoosystem channel')
        continue
    
    elseif isfield(data,ch{j})
        oline = data.(ch{j}).line;

        if ismember(ch{j},data.zoosystem.Analog.Channels)
            fsamp = data.zoosystem.Analog.Freq;
        elseif ismember(ch{j},data.zoosystem.Video.Channels)
            fsamp = data.zoosystem.Video.Freq;
        else
            error('channel not in zoosystem list')
        end
        
        if ismember(ch{j},data.zoosystem.Analog.FPlates.LABELS)
            indx = find(data.(ch{j}).line == 0);                               % find all zeros
            data.(ch{j}).line(indx) = NaN;                                                 
            data.(ch{j}).line = filter_line(data.(ch{j}).line,filt,fsamp);
            data.(ch{j}).line(indx) = 0;
        else
            data.(ch{j}).line = filter_line(data.(ch{j}).line,filt,fsamp);
        end
        
        evt = fieldnames(data.(ch{j}).event);
        for e = 1:length(evt)
            edata = data.(ch{j}).event.(evt{e});
            exd = edata(1);
%             eyd = edata(2);
            
            if exd > 1 && exd <= length(oline)            
                disp(['WARNING: event ',evt{e},' may not be updated in ',ch{j}])
%                 if eyd == oline(exd);
%                     neyd = data.(ch{j}).line(exd);
%                     data(ch{j}).event.(evt{e}) = [exd neyd 0];
%                 end
            end
        end
        
        
  
    else
        disp(['ch ',ch{j},' does not exist'])
    end
end

