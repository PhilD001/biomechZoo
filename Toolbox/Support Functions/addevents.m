function data = addevents(data,chs,ename,type)

% data = addevents(data,chs,ename,type) called by bmech_addevent to add data to event branches.
%
% NOTES
% - Users are encouraged to modify event functions for specific needs
% - Not all events have been tested


% Revision notes
%
% Updated by Philippe C. Dixon Sept 2015
% - Additional argument 'sfld' can be used to exclude folder 'sfld' from
%   addevent algorithm. This can be useful when events do not 'make sence' for
%   a particular sub folder. e.g. a subfolder of static pose cannot have a
%   foot strike event. For these files the event would show [1 NaN 0]
%
% Updated by Philippe C. Dixon March 2016
% - added ability to identify gait events using force plate data 
%   (see FPevents)


% Part of the Zoosystem Biomechanics Toolbox
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.



% Some settings
%
FP_thresh = 10;         % threshold (Newtons) for finding force plate events
peakSign = -1;          % sign of peak vertial force


if strcmp(chs{1},'all')
    chs = fieldnames(data);
    chs = setdiff(chs,{'zoosystem'});
    chs = setdiff(chs,{'contacttime'});
end

chs = setdiff(chs,{'zoosystem'});

for i = 1:length(chs)
    ch = chs{i};
    
    if isempty(ename)
        data.(ch).event = struct;
        continue
    end
    
   
    
    if ~isfield(data,ch)
        error(['channel : ',ch, ' does not exist'])
    end
    
    yd = data.(ch).line;
    
    switch type
        
        case 'first'
            exd = 1;
            eyd = yd(exd);
            
        case 'last'
            exd = length(yd);
            eyd = yd(exd);
            
        case 'max'
            eyd = max(yd);
            exd = find(yd==eyd);
            
        case 'min'
            eyd = min(yd);
            exd = find(yd==eyd);
            
        case 'rom'
            eyd = max(yd)-min(yd);
            exd = 1;
            
        case 'FS FP'
            units = data.zoosystem.Units.Forces;
            if strcmp(units,'N/kg')
                m = data.zoosystem.Anthro.Bodymass;
            else
                m = 1;
            end
            exd = find(peakSign*yd*m>FP_thresh,1,'first');
            eyd = yd(exd);
            
        case 'FO FP'
            units = data.zoosystem.Units.Forces;
            if strcmp(units,'N/kg')
                m = data.zoosystem.Anthro.Bodymass;
            else
                m = 1;
            end
            exd = find(peakSign*yd*m>FP_thresh,1,'last');
            eyd = yd(exd);
                        
        case {'RFS','RFO','LFS','LFO'}
            exd = ZeniEventDetect(data,type(1),type(2:end));
            
            if isnan(exd)
                eyd = NaN;
                ename = [ename,'1'];
            elseif length(exd)==1
                eyd = yd(exd);
                ename = [ename,'1'];
            end
            
        otherwise
            error(['event type: ',type,' does not exist'])
            
    end
    
    if isempty(exd)
        error('no event found')
    end
    
    
    if length(exd) > 1 % many events
        
        for j = 1:length(exd)
            eyd = yd(exd(j));
            data.(ch).event.([ename,num2str(j)]) = [exd(j),eyd,0];
        end
        
    else
        data.(ch).event.(ename) = [exd,eyd,0];
    end
    
    
end


