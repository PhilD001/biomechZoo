function data = combine_data (data1,data2,method)

% data = COMBINE_DATA(data1,data2,method)
%
% see also bmech_combine
%
% NOTES
%
% - resampling options do not work with zoo v1.3
%
fsamp1 = data1.zoosystem.Video.Freq;
fsamp2 = data2.zoosystem.Video.Freq;

fl = data1.zoosystem.SourceFile;

data = struct;
data.zoosystem = setZoosystem(fl);  
data.zoosystem.Video.Sync = true;
data.zoosystem.Analog.Sync = true;

switch method
    
    case 'down'
        
        if fsamp1>fsamp2
            disp(['resampling from ',num2str(fsamp1),' to ',num2str(fsamp2)])
            
            ch1 = setdiff(fieldnames(data1),'zoosystem');
            ch2 = setdiff(fieldnames(data2),'zoosystem');
            
            for i = 1:length(ch2)
                data.(ch2{i}) = data2.(ch2{i});
            end
            
            for i = 1:length(ch1)
                data1.(ch1{i}).line = resamp_nofilter(data1.(ch1{i}).line,fsamp2/fsamp1);
                data.(ch1{i}) = data1.(ch1{i});
            end
            
            fsamp = fsamp2;
            
        else
            
            disp(['resampling from ',num2str(fsamp2),' to ',num2str(fsamp1)])
            
            ch1 = setdiff(fieldnames(data1),'zoosystem');
            ch2 = setdiff(fieldnames(data2),'zoosystem');
            
                   

            for i = 1:length(ch2)
                section = getChannelSection(data2,ch2{i});
                fsamp2 = data2.zoosystem.(section).Freq;
                r= resamp_nofilter(data2.(ch2{i}).line,fsamp1/fsamp2);
                
                data = addchannel_data(data,ch2{i},r,section);
                data.(ch2{i}).event = data2.(ch2{i}).event;
            end
            
            for i = 1:length(ch1)
                section = getChannelSection(data1,ch1{i});
                r = data1.(ch1{i}).line;
                data = addchannel_data(data,ch1{i},r,section);
                data.(ch1{i}).event = data1.(ch1{i}).event;
            end
        
            fsamp = fsamp1;

            
        end
        
        
        
        
    case 'up'
        
        if fsamp1>fsamp2
            
            disp(['upsampling from ',num2str(fsamp2),' to ',num2str(fsamp1)])
            
            ch1 = setdiff(fieldnames(data1),'zoosystem');
            ch2 = setdiff(fieldnames(data2),'zoosystem');
            
            for i = 1:length(ch1)
                data.(ch1{i}) = data1.(ch1{i});
            end
            
            
            for i = 1:length(ch2)
                data2.(ch2{i}).line = resamp_nofilter(data2.(ch2{i}).line,fsamp1/fsamp2);
                data.(ch2{i}) = data2.(ch2{i});
            end
            
            fsamp = fsamp1;

            
        else
            
            disp(['upsampling from ',num2str(fsamp1),' to ',num2str(fsamp2)])
            
            ch1 = setdiff(fieldnames(data1),'zoosystem');
            ch2 = setdiff(fieldnames(data2),'zoosystem');
            
            for i = 1:length(ch1)
                data.(ch1{i}).line = resamp_nofilter(data1.(ch1{i}).line,fsamp2/fsamp1);
                data.(ch1{i}).event = data1.(ch1{i}).event;
            end
            
            for i = 1:length(ch2)
                data.(ch2{i}) = data2.(ch2{i});
            end
            
            fsamp = fsamp2;
        end
        
    case 'none'
               
        ch1Vid = data1.zoosystem.Video.Channels;
        ch1Anal = data1.zoosystem.Analog.Channels;

        ch2Vid = data2.zoosystem.Video.Channels;
        ch2Anal = data2.zoosystem.Analog.Channels;
                
        % add all the video fields from data1
        for i = 1:length(ch1Vid)
            if i==length(ch1Vid)
                data.zoosystem.Video.Freq =  data1.zoosystem.Video.Freq;
                data.zoosystem.Video.Indx = (1:1:length(r))';
                data.zoosystem.Video.CURRENT_START_FRAME = [1 0 0];
                data.zoosystem.Video.CURRENT_END_FRAME = [length(r) 0 0];
            end
            r = data1.(ch1Vid{i}).line;
            data = addchannel_data(data,ch1Vid{i},r,'Video');
            data.(ch1Vid{i}).event = data1.(ch1Vid{i}).event;     % in case there are events
        end
        
        % add all the analog fields from data1
        for i = 1:length(ch1Anal)
            if i==length(ch1Vid)
                data.zoosystem.Analog.Freq =  data1.zoosystem.Analog.Freq;
                data.zoosystem.Analog.Indx = (1:1:length(r))';
                data.zoosystem.Analog.CURRENT_START_FRAME = [1 0 0];
                data.zoosystem.Analog.CURRENT_END_FRAME = [length(r) 0 0];
            end
            r = data1.(ch1Anal{i}).line;
            data = addchannel_data(data,ch1Anal{i},r,'Analog');
            data.(ch1Anal{i}).event = data1.(ch1Anal{i}).event;     % in case there are events
        end
        
        % check if there is a mismatch between video freqs across systems
        if ~isempty(data.zoosystem.Video.Freq) && ~isempty(data2.zoosystem.Video.Freq)
             if ~isequal(data1.zoosystem.Video.Freq,data2.zoosystem.Video.Freq)
                 error('Video data from the two systems have different frequencies')
             end 
        end 
        
        % add all the video fields from data2
        for i = 1:length(ch2Vid)
             if i == length(ch2Vid)
               if length(r) ~= length(data.zoosystem.Video.Indx)
                data.zoosystem.Video.Sync = false;
               end
            end
            r = data2.(ch2Vid{i}).line;
            data = addchannel_data(data,ch2Vid{i},r,'Video');
            data.(ch2Vid{i}).event = data2.(ch2Vid{i}).event;     % in case there are events
        end
        
        
         % check if there is a mismatch between analog freqs across systems
        if ~isempty(data.zoosystem.Analog.Freq) && ~isempty(data2.zoosystem.Analog.Freq)
             if ~isequal(data1.zoosystem.Analog.Freq,data2.zoosystem.Analog.Freq)
                 error('Analog data from the two systems have different frequencies')
             end 
        end 
        
        % add all the analog fields from data2
        for i = 1:length(ch2Anal)
            if i == length(ch2Anal)
               if length(r) ~= length(data.zoosystem.Analog.Indx)
                data.zoosystem.Analog.Sync = false;
               end
            end
            r = data2.(ch2Anal{i}).line;
            data = addchannel_data(data,ch2Anal{i},r,'Video');
            data.(ch2Anal{i}).event = data2.(ch2Anal{i}).event;     % in case there are events
        end
        

end


% check process
%
if ~data.zoosystem.Analog.Sync
    disp('*********WARNING**************')
    disp('there may be a sync problem with your Analog: after combining data are of different lengths')
    disp(['length of file 1 ', num2str(length(data.(ch1Anal{1}).line))])
    disp(['length of file 2 ', num2str(length(data.(ch2Anal{1}).line))])
    disp(' ')
end

if ~data.zoosystem.Video.Sync
    disp('*********WARNING**************')
    disp('there may be a sync problem with your Video: after combining data are of different lengths')
    disp(['length of file 1 ', num2str(length(data.(ch1Vid{1}).line))])
    disp(['length of file 2 ', num2str(length(data.(ch2Vid{1}).line))])
end


% add the zoosystem channels
%
% data.zoosystem = struct;
% data.zoosystem.SourceFile.File2 = data2.zoosystem.SourceFile;
% data.zoosystem.SourceFile.File1 = data1.zoosystem.SourceFile;
% 
% % determine fields in each dataset
% %
% zch1  = setdiff(fieldnames(data1.zoosystem),{'SourceFile'}); 
% zch2  = setdiff(fieldnames(data2.zoosystem),{'SourceFile'}); 
% 
% zch_int = intersect(zch1,zch2);
% 
% zch1_only = setdiff(zch1,zch_int);
% zch2_only = setdiff(zch2,zch_int);
% 
% 
% % Add fields from each zoosystem
% %
% for i = 1:length(zch1_only)
%     data.zoosystem.(zch1_only{i}) = data1.zoosystem.(zch1_only{i});
% end
% 
% for i = 1:length(zch2_only)
%     data.zoosystem.(zch2_only{i}) = data2.zoosystem.(zch2_only{i});
% end
% 
% % Add common fields
% %
% for i =1:length(zch_int)
%     
%     sch1 = fieldnames(data1.zoosystem.(zch_int{i}));
%     sch2 = fieldnames(data2.zoosystem.(zch_int{i}));
%     
%     sch_int = intersect(sch1,sch2);
%     
%     sch1_only = setdiff(sch1,sch_int);
%     sch2_only = setdiff(sch2,sch_int);
%     
%     for j = 1:length(sch1_only)
%         data.zoosystem.(zch_int{i}).(sch1_only{j}) = data1.zoosystem.(zch_int{i}).(sch1_only{j});
%     end
%     
%     for j = 1:length(sch2_only)
%         data.zoosystem.(zch_int{i}).(sch2_only{j}) = data2.zoosystem.(zch_int{i}).(sch2_only{j});
%     end
%    
%     if ismember('Channels',sch_int)
%         ch1 = data1.zoosystem.(zch_int{i}).Channels;
%         ch2 = data2.zoosystem.(zch_int{i}).Channels;
%         
%         if ~isempty(intersect(ch1,ch2))
%            error('same channel names in each dataset') 
%         end
%         
%         ch = [ch1;ch2];
%         
%         data.zoosystem.(zch_int{i}).Channels = ch;
%         data.zoosystem.(zch_int{i}).Indx = data1.zoosystem.(zch_int{i}).Indx;
%         data.zoosystem.(zch_int{i}).Freq = fsamp;
%         
%     end
%     
%     
%    
% end