function bmech_combinezoofiles(fld1,fld2,method)

% BMECH_COMBINEZOOFILES(fld1,fld2,method) will combine data from 2 separate zoo files.  
%
% ARGUMENTS
%  fld1      ...  folder for first data set. Files saved to fld1
%  fld2      ...  folder for second data set
%  method   ...   determines if you want to upsample the signal with the lower frequency ('up')
%                 or if you want to downsample the signal with the  highest frequency ('down'). 
%                 Default is 'down'. If signals are of equal sampling rate, no resampling occurs
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
% Aduts and Children. Rome, Italy.Sept 29-Oct 4th 2014. 


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
    indx1 = strfind(fl1{k},slash);
    indx1 = indx1(end-2);
     
    stk1{k} = fl1{k}(indx1:end);    
end


stk2 = cell(size(fl2));

for l = 1:length(fl2)
    indx1 = strfind(fl2{l},slash);
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
    
    indx1 = strfind(fl1{i},slash);
    indx1 = indx1(end-1);
    
    indx2 = strfind(fl2{i},slash);
    indx2 = indx2(end-1);
    
    disp('combining...')
    disp(['... ',fl1{i}(indx1-8:end),' &'])
    disp(['... ',fl2{i}(indx2-8:end)])
    disp(' ')
    
    if strcmp(fl1{i}(indx1:end),fl1{i}(indx1:end))==0
        disp ('*****file name error*********')
        disp(' ')
        disp(fl1{i}(indx1:end))
        disp(fl1{i}(indx1:end))
        
        return
    end
    
    data = combine(data1,data2,fld1,fld2,fl2{i},method);
    
    save(fl1{i},'data');
end


rmdir(fld2,'s');

disp (['all files saved in ',fld1])

   

    


function data = combine (data1,data2,fld1,fld2,fl2,method)

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
            
            
            if abs(length(data.(ch1{1}).line)-length(data.(ch2{1}).line))>4
                disp('*********WARNING**************')
                disp('there may be a sync problem with your data: after combining data are of different lengths')
                disp(['length of file 1 ', num2str(length(data.(ch1{1}).line))])
                disp(['length of file 2', num2str(length(data.(ch2{1}).line))])
            end
                      
            
            %-------add the zoosystem channels------------
            
            if ~isempty(strfind(data2.zoosystem.SourceFile,'analog_capture'))
                data.zoosystem.SourceFile.File2 = fl2;
                
            else
                
                data.zoosystem.SourceFile.File2 = data2.zoosystem.SourceFile;
                
            end
            data.zoosystem.SourceFile.File1 = data1.zoosystem.SourceFile;
            data.zoosystem.Fsamp = fsamp2;
            
            
            
        else
            
            disp(['resampling from ',num2str(fsamp2),' to',num2str(fsamp1)])
            
            ch1 = setdiff(fieldnames(data1),'zoosystem');
            ch2 = setdiff(fieldnames(data2),'zoosystem');
            
            
            for i = 1:length(ch2)
                
                data.(ch2{i}).line = resamp_nofilter(data2.(ch2{i}).line,fsamp1/fsamp2);
                data.(ch2{i}).event = data2.(ch2{i}).event;
                
            end
            
            for i = 1:length(ch1)
                data.(ch1{i}) = data1.(ch1{i});
            end
            
            
            
            if abs(length(data.(ch1{1}).line)-length(data.(ch2{1}).line))>5
                disp('*********WARNING**************')
                disp('there may be a sync problem with your data: after combining data are of different lengths')
                disp(['length of file 1 ', num2str(length(data.(ch1{1}).line))])
                disp(['length of file 2', num2str(length(data.(ch2{1}).line))])
                
            end
            
            
            %-------add the zoosystem channels------------
            
            
            
            if ~isempty(strfind(data2.zoosystem.SourceFile,'analog_capture'))
                data.zoosystem.SourceFile.File2 = fl2;
                
            else
                
                data.zoosystem.SourceFile.File2 = data2.zoosystem.SourceFile;
                
            end
            
            data.zoosystem.SourceFile.File1 = data1.zoosystem.SourceFile;
            
            data.zoosystem.Fsamp = fsamp1;
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
            
            
            
            if abs(length(data.(ch1{1}).line)-length(data.(ch2{1}).line))>5
                disp('*********WARNING**************')
                disp('there may be a sync problem with your data: after combining data are of different lengths')
                disp(['length of file 1 ', num2str(length(data.(ch1{1}).line))])
                disp(['length of file 2', num2str(length(data.(ch2{1}).line))])          
            end
            
            
            %-------add the zoosystem channels------------
            
            if ~isempty(strfind(data2.zoosystem.SourceFile,'analog_capture'))
                data.zoosystem.SourceFile.File2 = fl2;
                
            else
                
                data.zoosystem.SourceFile.File2 = data2.zoosystem.SourceFile;
                
            end
            data.zoosystem.SourceFile.File1 = data1.zoosystem.SourceFile;
            data.zoosystem.Freq = fsamp1;
            
                        
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
            
            
            
            if abs(length(data.(ch1{1}).line)-length(data.(ch2{1}).line))>5
                disp('*********WARNING**************')
                disp('there may be a sync problem with your data: after combining data are of different lengths')
                disp(['length of file 1 ', num2str(length(data.(ch1{1}).line))])
                disp(['length of file 2', num2str(length(data.(ch2{1}).line))])     
            end
                
            
            %-------add the zoosystem channels------------
            
            
            
            if ~isempty(strfind(data2.zoosystem.SourceFile,'analog_capture'))
                data.zoosystem.SourceFile.File2 = fl2;
                
            else
                
                data.zoosystem.SourceFile.File2 = data2.zoosystem.SourceFile;
                
            end
            
            data.zoosystem.SourceFile.File1 = data1.zoosystem.SourceFile;
            
            data.zoosystem.Freq = fsamp2;
        end
        
end


