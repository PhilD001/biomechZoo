function data = partitiondata(data,evt1,evt2,ch)

% data = PARTITIONDATA(data,evt1,evt2,ch) standalone function to partition data
%
% ARGUMENTS
%  data ...  zoo data file
%  evt1 ...  name of event for start of partition
%  evt2 ...  name of event for end of partition
%  ch   ... list of channels to partition. Default all channels partitioned
%
% RETURNS
%  data ... partitionned zoo data
%


% Revision History
%
% Created by Philippe C. Dixon based on old code
%
% Updated by Philippe C. Dixon Feb 2012
% - events with index 1 will keep this index, others will be modifed
%
% Updated by Philippe C. Dixon Oct 2012
% - partitionning can occur only for select channels
%
% Updated by Philippe C. Dixon January 2014
% - use with 4 arguments fixed
%
% Updated by Philippe C. Dixon February 26th 2014
% - current frame field of zoosystem updated.
%
% Updated by Philippe C. Dixon June 2015
% - events for outliers (999) are unchanged
%
% Updated by Philippe C. Dixon March 2016
% - Fixed CURRENT_START_FRAME and CURRENT_END_FRAME bug so that format:
%  [frame 0 0] is resepcted


% Part of the Zoosystem Biomechanics Toolbox v1.2
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



% Set Defaults
%
if nargin<4
    ch = setdiff(fieldnames(data),{'zoosystem'});
end


[e1,ch1] = findfield(data,evt1);   % both events must be for data of the same tyle
e2 = findfield(data,evt2);         % either analog or video




%-----check if events are present-----
%
if isempty(e1)
    disp(['event ',e1, ' not found']);
    return
end

if isempty(e2)
    disp(['event ',e2, ' not found']);
    return
end



a = 0;
v = 0;
for i = 1:length(ch)
    
    if isfield(data.(ch{i}),'line')~=1
        disp(['the channel ',ch{i}, ' is missing the line field'])
        
    elseif length(data.(ch{i}).line)<(e2(1)-e1(1))
        disp(['the channel ',ch{i}, ' has insufficient data points for partitionning'])
        
    elseif e1(1) > e2(1)
        disp(['event 1: ',evt1, ' occurs after event 2: ',evt2])
        
    else
        r = data.(ch{i}).line(e1(1):e2(1),:);
        data.(ch{i}).line = r;
    end
    event = fieldnames(data.(ch{i}).event);
    
    if ~isempty(event)
        
        for e = 1:length(event)
            
            if data.(ch{i}).event.(event{e})(1)==1
                continue
            elseif data.(ch{i}).event.(event{e})(1)==999
                continue
            else
                data.(ch{i}).event.(event{e})(1) = data.(ch{i}).event.(event{e})(1)-e1(1)+1;
            end
        end
    end
    
    % update zoosystem
    %
    if ismember(ch{i},data.zoosystem.Video.Channels) && v==0
        data.zoosystem.Video.CURRENT_START_FRAME = [e1(1) 0 0];
        data.zoosystem.Video.CURRENT_END_FRAME = [e2(1) 0 0];
        %data.zoosystem.Video.Indx = e1(1):1:e2(2);
        v = 1;
    elseif ismember(ch{i},data.zoosystem.Analog.Channels) && a ==0
        data.zoosystem.Analog.CURRENT_START_FRAME = [e1(1) 0 0];
        data.zoosystem.Analog.CURRENT_END_FRAME = [e2(1) 0 0];   
        %data.zoosystem.Analog.Indx = e1(1):1:e2(2);

    end
    
end


