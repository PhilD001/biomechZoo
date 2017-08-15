function data = gaitevents_data(data,delta)

% data = GAITEVENTS_DATA(data,delta) estimates foot strike (FS) and
% foot off (FO) events during gait
%
% ARGUMENTS
%  data    ...    Zoo struct to operate on
%  delta   ...    Threshold for peak detection. Default 100. See peakdet
%                 for more details
% RETURNS
%  data    ...    Zoo struct with gait events appended to SACR or first
%                 video channel in list
%
% See also bmech_gaitevents, ZeniEventData, peakdet


% Revision history
%
% Created by Philippe C. Dixon August 12th 2017
% - Based on existing m-file from DPhil thesis 2015


% Set peak detection threshold
%
if nargin==1
    delta = 100;
end

% Extract FS and FO events
%
rFS = ZeniEventDetect(data,'R','FS',delta);
lFS = ZeniEventDetect(data,'L','FS',delta);
rFO = ZeniEventDetect(data,'R','FO',delta);
lFO = ZeniEventDetect(data,'L','FO',delta);

% Find channel to add events to
%
if isfield(data,'SACR_x')
    ch = 'SACR_x';
elseif isfield(data,'SACR')
    ch = 'SACR';
else
    ch = data.zoosystem.Video.Channels{1};
end

% Clear existing Vicon events
% evts = fieldnames(data.(ch).event);
% for i = 1:length(evts)
%     if strfind(evts{i},'Foot')
%         data = removeevent_data(data,evts{i},ch);
%     end
% end
% data.(ch).event = [];

% Add gait events to data
%
rFS1 = rFS(1);
rFO1 = rFO(1);

lFS1 = lFS(1);
lFO1 = lFO(1);

if rFS1 < rFO1   % 1st event is a foot strike
    
    for i = 1:length(rFS)
        data.(ch).event.(['RFS',num2str(i)]) =  [rFS(i) 0 0];
    end
    
    for i = 1:length(rFO)
        data.(ch).event.(['RFO',num2str(i)]) =  [rFO(i) 0 0];
    end
    
else             % 1st event is a foot off, so 1st FS is 'FS2'--> 'FS1' is missing
    for i = 1:length(rFS)
        data.(ch).event.(['RFS',num2str(i)]) =  [rFS(i) 0 0];
    end
    
    for i = 1:length(rFO)
        data.(ch).event.(['RFO',num2str(i-1)]) =  [rFO(i) 0 0];
    end
    
end


if lFS1 < lFO1   % 1st event is a foot strike
    
    for i = 1:length(lFS)
        data.(ch).event.(['LFS',num2str(i)]) =  [lFS(i) 0 0];
    end
    
    for i = 1:length(lFO)
        data.(ch).event.(['LFO',num2str(i)]) =  [lFO(i) 0 0];
    end
    
else
    
    for i = 1:length(lFS)
        data.(ch).event.(['LFS',num2str(i)]) =  [lFS(i) 0 0];
    end
    
    for i = 1:length(lFO)
        data.(ch).event.(['LFO',num2str(i-1)]) =  [lFO(i) 0 0];
    end
    
    
end

% for testing
%
% for i = 1:length(rFS)
%     if isfield(data.(ch).event,['Right_FootStrike',num2str(i)])
%         e = data.(ch).event.(['Right_FootStrike',num2str(i)]);
%         disp('Replacing Vicon event with Zeni event: ')
%         disp(['Vicon event Right_FootStrike',num2str(i),': ',num2str(e(1))])
%         disp(['Zeni event Right_FootStrike',num2str(i),' : ',num2str(rFS(i))])
%     end
%
%     data.(ch).event.(['Right_FootStrike',num2str(i)]) =  [rFS(i) 0 0];
% end
%
% for i = 1:length(lFS)
%     if isfield(data.(ch).event,['Left_FootStrike',num2str(i)])
%         e = data.(ch).event.(['Left_FootStrike',num2str(i)]);
%         disp('Replacing Vicon event with Zeni event: ')
%         disp(['Vicon event Left_FootStrike',num2str(i),': ',num2str(e(1))])
%         disp(['Zeni event Left_FootStrike',num2str(i),':  ',num2str(lFS(i))])
%     end
%     data.(ch).event.(['Left_FootStrike',num2str(i)]) =  [lFS(i) 0 0];
% end
%
% for i = 1:length(rFO)
%      if isfield(data.(ch).event,['Right_FootOff',num2str(i)])
%         e = data.(ch).event.(['Right_FootOff',num2str(i)]);
%         disp('Replacing Vicon event with Zeni event: ')
%         disp(['Vicon event Right_FootOff',num2str(i),': ',num2str(e(1))])
%         disp(['Zeni event Right_FootOff',num2str(i),':  ',num2str(rFO(i))])
%     end
%     data.(ch).event.(['Right_FootOff',num2str(i)]) =  [rFO(i) 0 0];
% end
%
% for i = 1:length(lFO)
%     if isfield(data.(ch).event,['Left_FootOff',num2str(i)])
%         e = data.(ch).event.(['Left_FootOff',num2str(i)]);
%         disp('Replacing Vicon event with Zeni event: ')
%         disp(['Vicon event Left_FootOff',num2str(i),': ',num2str(e(1))])
%         disp(['Zeni event Left_FootOff',num2str(i),':  ',num2str(lFO(i))])
%     end
%     data.(ch).event.(['Left_FootOff',num2str(i)]) =  [lFO(i) 0 0];
% end