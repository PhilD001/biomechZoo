function data = combine_data (data1,data2,method)

% data = COMBINE_DATA(data1,data2,method)
%
% see also bmech_combine
%
% NOTES
%
% - resampling options do not work with zoo v1.3



% add all the video and analog fields from 'data1' to the new 'data' struct
%
data = data1;



% add all the video and analog fields from 'data2' to the new 'data' struct
%
section = {'Video','Analog'};



% check if there is a mismatch between video freqs across systems

data.zoosystem.Video.Sync = true;

% add all the Video and Analog fields from data2
%
for  i = 1:2
    ch2 = data2.zoosystem.(section{i}).Channels;
    freq1 = data1.zoosystem.(section{i}).Freq;
    freq2 = data2.zoosystem.(section{i}).Freq;
    
    if freq1 ~= freq2
        
        switch method
            
            case 'down'
                disp(['downsampling ',section{i},' channels for data 2 from ',num2str(freq2),' to ',num2str(freq1)])
                data2 = resample_data(data2,ch2,freq1,freq2,'linear');
                
            case 'up'
                disp(['upsampling ',section{i},' channels for data 2 from',num2str(freq2),' to ',num2str(freq1)])
                data2 = resample_data(data2,ch2,freq2,freq1,'linear');
                
            otherwise
                continue
        end
    end
    
    if ~isempty(ch2)
        
        if length(data2.(ch2{1}).line) ~= length(data.zoosystem.(section{i}).Indx)
            data.zoosystem.(section{i}).Sync = false;
        else
            data.zoosystem.(section{i}).Sync = true;
        end
        
        for j = 1:length(ch2)
            r = data2.(ch2{j}).line;
            e = data2.(ch2{j}).event;
            
            if isfield(data,ch2{j})
                temp = ch2{j};
                ch2{j} = [temp,'_b'];
            end
            
            data = addchannel_data(data,ch2{j},r,section{i});
            data.(ch2{j}).event = e;                       % in case there are events
        end
    end
    
    
    if ~data.zoosystem.(section{i}).Sync
        disp('*********WARNING**************')
        disp(['there may be a sync problem with your ',section{i}, 'channels: after combining data are of different lengths'])
        disp(' ')
    end
end









%
%
%     case 'none'
%
%         ch1Vid = data1.zoosystem.Video.Channels;
%         ch1Anal = data1.zoosystem.Analog.Channels;
%
%         ch2Vid = data2.zoosystem.Video.Channels;
%         ch2Anal = data2.zoosystem.Analog.Channels;
%
%         % add all the video fields from data1
%         for i = 1:length(ch1Vid)
%             if i==1
%                 data.zoosystem.Video = data1.zoosystem.Video;
%             end
%             data.(ch1Vid{i}).line =  data1.(ch1Vid{i}).line;
%             data.(ch1Vid{i}).event = data1.(ch1Vid{i}).event;
%         end
%
%         % add all the analog fields from data1
%         for i = 1:length(ch1Anal)
%             if i==1
%                 data.zoosystem.Analog = data1.zoosystem.Analog;
%             end
%             data.(ch1Anal{i}).line = data1.(ch1Anal{i}).line;
%             data.(ch1Anal{i}).event = data1.(ch1Anal{i}).event;     % in case there are events
%         end
%
%
%         % check if there is a mismatch between video freqs across systems
%         if ~isempty(data.zoosystem.Video.Freq) && ~isempty(data2.zoosystem.Video.Freq)
%             if ~isequal(data1.zoosystem.Video.Freq,data2.zoosystem.Video.Freq)
%                 error('Video data from the two systems have different frequencies')
%             end
%         end
%
%         % add all the video fields from data2
%         data.zoosystem.Video.Sync = true;
%         for i = 1:length(ch2Vid)
%             if i == length(ch2Vid)
%                 if length(r) ~= length(data.zoosystem.Video.Indx)
%                     data.zoosystem.Video.Sync = false;
%                 end
%             end
%
%             r = data2.(ch2Vid{i}).line;
%             e = data2.(ch2Vid{i}).event;
%
%             if isfield(data,ch2Vid{i})
%                 temp = ch2Vid{i};
%                 ch2Vid{i} = [temp,'_b'];
%             end
%
%             data = addchannel_data(data,ch2Vid{i},r,'Video');
%             data.(ch2Vid{i}).event = e;                       % in case there are events
%         end
%
%
%         % check if there is a mismatch between analog freqs across systems
%         if ~isempty(data.zoosystem.Analog.Freq) && ~isempty(data2.zoosystem.Analog.Freq)
%             if ~isequal(data1.zoosystem.Analog.Freq,data2.zoosystem.Analog.Freq)
%                 error('Analog data from the two systems have different frequencies')
%             end
%         end
%
%         % add all the analog fields from data2
%         data.zoosystem.Analog.Sync = true;
%         for i = 1:length(ch2Anal)
%             if i == length(ch2Anal)
%                 if length(r) ~= length(data.zoosystem.Analog.Indx)
%                     data.zoosystem.Analog.Sync = false;
%                 end
%             end
%
%             r = data2.(ch2Anal{i}).line;
%             e = data2.(ch2Anal{i}).event;
%             if isfield(data,ch2Anal{i})
%                 temp = ch2Anal{i};
%                 ch2Anal{i} = [temp,'_b'];
%             end
%
%             data = addchannel_data(data,ch2Anal{i},r,'Analog');
%             data.(ch2Anal{i}).event = e;                 % in case there are events
%         end
%
%
%         data.zoosystem.AVR = data.zoosystem.Analog.Freq/data.zoosystem.Video.Freq;
%
% end


% check process
%

% if ~data.zoosystem.Video.Sync
%     disp('*********WARNING**************')
%     disp('there may be a sync problem with your Video: after combining data are of different lengths')
%     disp(['length of file 1 ', num2str(length(data.(ch1Vid{1}).line))])
%     disp(['length of file 2 ', num2str(length(data.(ch2Vid{1}).line))])
% end

