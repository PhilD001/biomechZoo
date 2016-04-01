function bmech_resample(fld,ch,p,q,filt)

% bmech_resample(p,q,fld,ch,filt) resamples data 'down' or 'up'
%
% ARGUMENTS
%
% fld     ...   folder to operate on
% ch      ...   List of channel names. These should be all of same type.
%               If 'Analog' or 'Video', then all channels of that type will
%               be resampled to the rate of the other type. e.g. 'Analog'
%               resamples all Analog channels to the 'Video' sampling rate
% p       ...   numerator of fraction of sampling rate
% q       ...   denominator of fraction of fraction of sampling rate
%               i.e., all 'Analog' or 'Video' at same sampling rate
% filt    ...   allow filtering. Default no
%
%
% NOTES:
%
% 1)Samples at p/q of the initial sample rate
% 2)p and q must be positive integers


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


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

% Set defaults
%
if nargin==2
    filt = 'no';
end

if nargin==4
    filt = 'no';
end


fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl);
    
    batchdisplay(fl{i},'resampling')
    data = zload(fl{i});
    
    if data.zoosystem.AVR == 1
        error('Video and Analog data at same sampling rate')
    end
    
    if sum(strcmp(ch,'Video'))==1  && i ==1
        ch = data.zoosystem.Video.Channels;
        q = data.zoosystem.Video.Freq;
        p = data.zoosystem.Analog.Freq;
    elseif sum(strcmp(ch,'Analog'))==1  && i ==1
        ch = data.zoosystem.Analog.Channels;
        p = data.zoosystem.Video.Freq;
        q = data.zoosystem.Analog.Freq;
    end
    
    
    for j = 1:length(ch)
        
        if isin(filt,'no')
            
            if isfield(data,ch{j})
                data.(ch{j}).line = resamp_nofilter(data.(ch{j}).line,p/q);
            end
            
        else
            
            if isfield(data,ch{j})
                data.(ch{j}).line = resample(data.(ch{j}).line,p,q);
            end
        end
        
        evts = fieldnames(data.(ch{j}).event);
        
        for e =1:length(evts)
            r =  data.(ch{j}).event.(evts{e});
            r(1) = round(r(1)*p/q);
            data.(ch{j}).event.(evts{e}) = r;
        end
        
        
    end
    
    if ismember(ch{1},data.zoosystem.Video.Channels)     % We are resampling video data
        currentSection = 'Video';
        otherSection = 'Analog';
    elseif ismember(ch{1},data.zoosystem.Analog.Channels) % we are resampling analog data
        currentSection = 'Analog';
        otherSection = 'Video';
    else
        error('Channel to resample not part of zoosystem channel list')
    end
    
    data.zoosystem.(currentSection).Freq = data.zoosystem.(currentSection).Freq*p/q;
    data.zoosystem.(currentSection).CURRENT_START_FRAME = data.zoosystem.(otherSection).CURRENT_START_FRAME;
    data.zoosystem.(currentSection).CURRENT_END_FRAME = data.zoosystem.(otherSection).CURRENT_END_FRAME;
    data.zoosystem.(currentSection).Indx = data.zoosystem.(otherSection).Indx;

    data.zoosystem.AVR = 1;
    
    zsave(fl{i},data, ['Freq: ',num2str(p),' to ',num2str(q), ' Hz, Filt: ',filt]);
    
end

