function bmech_combinezoofiles(fld1,fld2,method)

% BMECH_COMBINEZOOFILES(fld1,fld2,method) will combine data from 2 separate zoo files.
%
% ARGUMENTS
%  fld1      ...  folder for first data set. Files saved to fld1
%  fld2      ...  folder for second data set
%  method   ...   determines if you want to upsample the signal with the lower frequency ('up'),
%                 if you want to downsample the signal with the  highest frequency ('down'), or
%                 leave them the same 'none'. Default is down if frequencies are different.
%
% Example
%  You may have collected data using 2 separate systems. As each signal was colected by a different system,
%  you have 2 sets of zoo data per trial. This file will create a sigle zoo file containing
%  all the channels in the first folder fld1
%
% NOTES
%  - make a copy of "folder 1" this is where all your data will be combined
%  - please make sure correct trials are combined. Files in each folder
%    should follow the same number sequence.
%  - You can check the zoosystem SourceFile to make sure process was completed correctly


% Revision History
%
% Created by Philippe C. Dixon and TJ Stidwill August 2008
%
% Updated by Philippe C. Dixon August 2010
% - function checks that after processing your channels are of the same
%   length. If they are different by more than 4, a warning is displayed
%
% Updated by Philippe C. Dixon March 2011
% - folder 2 is deleted automatically
%
% Updated by Philippe C. Dixon May 2015
% - improved combining of zoosystem folder metadata
% - no resampling when sampling rates are the same


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

s = filesep;    % determine slash direction based on computer type

if nargin==0
    fld1 = uigetfolder('Select Folder 1');
    fld2 = uigetfolder('Select Folder 2');
    method = 'down';
end

if nargin==2
    method = 'down';
end

cd(fld1)
fl1 = engine('path',fld1,'extension','zoo');
fl2 = engine('path',fld2,'extension','zoo');



%-----------ERROR CHECKING---------
%
stk1 = cell(size(fl1));

for k = 1:length(fl1)
    indx1 = strfind(fl1{k},s);
    indx1 = indx1(end-2);
    
    stk1{k} = fl1{k}(indx1:end);
end


stk2 = cell(size(fl2));

for l = 1:length(fl2)
    indx1 = strfind(fl2{l},s);
    indx1 = indx1(end-2);
    
    stk2{l} = fl2{l}(indx1:end);
end

a = ismember(stk1,stk2);
b = find(a==0);     %different files

if ~isempty(b);
    
    for l = 1:length(b)
        disp([stk1{b(l)},' and ', stk2{b(l)}, ' have different file names'])
    end
    
    disp(' ')
    disp(' **************program ended****************')
    disp(' ')
    
    return
    
end




%----------RUN PROGRAM-----------


for i = 1:length(fl1)
    
    data = zload(fl1{i});
    data1 = data;
    
    data = zload(fl2{i});
    data2 = data;
    
    indx1 = strfind(fl1{i},s);
    indx1 = indx1(end-1);
    
    indx2 = strfind(fl2{i},s);
    indx2 = indx2(end-1);
    
    disp('combining...')
    disp(fl1{i})
    disp(fl2{i})
    disp(' ')
    
    if strcmp(fl1{i}(indx1:end),fl1{i}(indx1:end))==0
        disp ('*****file name error*********')
        disp(' ')
        disp(fl1{i})
        disp(fl1{i})
        
        return
    end
    
    data = combine(data1,data2,method);
    
    save(fl1{i},'data');
end


disp (['all files saved in ',fld1])



function data = combine (data1,data2,method)

fsamp1 = data1.zoosystem.Video.Freq;
fsamp2 = data2.zoosystem.Video.Freq;

data = struct;

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
                data.(ch2{i}).line = resamp_nofilter(data2.(ch2{i}).line,fsamp1/fsamp2);
                data.(ch2{i}).event = data2.(ch2{i}).event;
            end
            
            for i = 1:length(ch1)
                data.(ch1{i}) = data1.(ch1{i});
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
        
        disp(['no resampling, keeping ',num2str(fsamp1),' Hz sampling rate'])
        
        ch1 = setdiff(fieldnames(data1),'zoosystem');
        ch2 = setdiff(fieldnames(data2),'zoosystem');
        
        for i = 1:length(ch1)
            data.(ch1{i}) = data1.(ch1{i});
        end
      
        for i = 1:length(ch2)
            data.(ch2{i}) = data2.(ch2{i});
        end
        
         fsamp = fsamp1;

end


% check process
%
if abs(length(data.(ch1{1}).line)-length(data.(ch2{1}).line))>5
    disp('*********WARNING**************')
    disp('there may be a sync problem with your data: after combining data are of different lengths')
    disp(['length of file 1 ', num2str(length(data.(ch1{1}).line))])
    disp(['length of file 2 ', num2str(length(data.(ch2{1}).line))])
    error('ending program')
end


% add the zoosystem channels
%
data.zoosystem = struct;
data.zoosystem.SourceFile.File2 = data2.zoosystem.SourceFile;
data.zoosystem.SourceFile.File1 = data1.zoosystem.SourceFile;

% determine fields in each dataset
%
zch1  = setdiff(fieldnames(data1.zoosystem),{'SourceFile'}); 
zch2  = setdiff(fieldnames(data2.zoosystem),{'SourceFile'}); 

zch_int = intersect(zch1,zch2);

zch1_only = setdiff(zch1,zch_int);
zch2_only = setdiff(zch2,zch_int);


% Add fields from each zoosystem
%
for i = 1:length(zch1_only)
    data.zoosystem.(zch1_only{i}) = data1.zoosystem.(zch1_only{i});
end

for i = 1:length(zch2_only)
    data.zoosystem.(zch2_only{i}) = data2.zoosystem.(zch2_only{i});
end

% Add common fields
%
for i =1:length(zch_int)
    
    sch1 = fieldnames(data1.zoosystem.(zch_int{i}));
    sch2 = fieldnames(data2.zoosystem.(zch_int{i}));
    
    sch_int = intersect(sch1,sch2);
    
    sch1_only = setdiff(sch1,sch_int);
    sch2_only = setdiff(sch2,sch_int);
    
    for j = 1:length(sch1_only)
        data.zoosystem.(zch_int{i}).(sch1_only{j}) = data1.zoosystem.(zch_int{i}).(sch1_only{j});
    end
    
    for j = 1:length(sch2_only)
        data.zoosystem.(zch_int{i}).(sch2_only{j}) = data2.zoosystem.(zch_int{i}).(sch2_only{j});
    end
   
    if ismember('Channels',sch_int)
        ch1 = data1.zoosystem.(zch_int{i}).Channels;
        ch2 = data2.zoosystem.(zch_int{i}).Channels;
        
        if ~isempty(intersect(ch1,ch2))
           error('same channel names in each dataset') 
        end
        
        ch = [ch1;ch2];
        
        data.zoosystem.(zch_int{i}).Channels = ch;
        data.zoosystem.(zch_int{i}).Indx = data1.zoosystem.(zch_int{i}).Indx;
        data.zoosystem.(zch_int{i}).Freq = fsamp;
        
    end
    
    
   
end





