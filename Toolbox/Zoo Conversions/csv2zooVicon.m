function data= csv2zooVicon(fld,del)

% data= CSV2ZOOVICON(fld,del)converts csv file output from vicon to zoo format.
%
% ARGUMENTS
%
% fld        ... Optional argument. Enter full path leading to folder
% del        ... Optional argument. Delete original files. Default 'no'
% resample   ... choice to downsample or upsample data. Default 'no'
% check      ... Optional argument. Check if channels listed exist. Default {}
% nans       ... keep nans at start of data. Default no.
%
% RETURNS
% data       ... Optional return
%
% NOTES
% - Files should have been exported using the "export data to ascii file" NOT "exportcsv"
% - Where possible c3d export is quicker and provides more meta information to the user


% Revision history
%
% Created by Philippe C. Dixon Oct 2011
%
% Updated by Philippe C. Dixon Dec 2011
% - use of the function 'readtext' instead of 'xlsread' improves handling of
%   large data sets
% - data without any vicon events can be handled
%
% Updated by Philippe C. Dixon January 2012
% - works with data containing analysis output (ignored)
%
% Updated by Philippe C. Dixon June 19th 2012
% - if delete is 'yes' then source files will be deleted as soon as the zoo file is created
%
% Updated by Philippe C. Dixon Sept 28th 2012
% - works with files having up to 3 forceplates
%
% Updated by Philippe C. Dixon Jan 4th 2013
% - removal of embedded function
%
% Updated by Philippe C. Dixon Oct 2016
% - revised to work with biomechZoo v1.3




%---LOAD DEFAULT SETTINGS AND CHECK ARGIN
%
tic

if nargin==0
    fld = uigetfolder;
    del = false;
end

if nargin==1
    del = false;
end

if strcmp(del,'yes') || strcmp(del,'on')
    del = true;
end

[fld,fl,saveFile] = checkinput(fld,'.csv');
cd(fld)


%-------LOAD EXCEL DATA--------
%

for i = 1:length(fl)
    batchdisplay(fl{i},'creating zoo file')
    zfl = extension(fl{i},'zoo');
        
    r  = readcsvVicon(fl{i});
    
         
    % Initialize zoo data structure
    %
    data = struct;
    data.zoosystem = setZoosystem(fl);
    
    data.zoosystem.Analog.Freq = r.Analog.Freq;

    % Add video channels to data struct
    %
    ch = r.Video.Channels;   
    indx = r.Video.data(:,1); % remove (and save) frame info column
    r.Video.data = r.Video.data(:,2:end);
        
    for j = 1:length(ch)
        ch{j} = makevalidfield(ch{j});                 % fixes invalid fieldnames
        if isfield(data,ch{j})
            disp(['WARNING: Repeated channel name ',ch{j}, ' to be renamed ',ch{j},num2str(j)])
        end
        temp = r.Video.data(:,3*j-2:3*j);
        data = addchannel_data(data,ch{j},temp,'Video');
    end
    
    data.zoosystem.Video.Channels = ch;
    data.zoosystem.Video.Freq = r.Video.Freq;
    data.zoosystem.Video.Indx = makecolumn(1:1:length(indx));
    data.zoosystem.Video.ORIGINAL_START_FRAME = [indx(1) 0 0];
    data.zoosystem.Video.ORIGINAL_END_FRAME = [indx(end) 0 0];
    data.zoosystem.Video.CURRENT_START_FRAME = [1 0 0];
    data.zoosystem.Video.CURRENT_END_FRAME = [length(indx) 0 0];
    
    
    % Add force plate channels to data struct
    %
    if isfield(r,'Forces')   % these are force plate channels
        ch = r.Forces.Channels;
        indx = r.Forces.data(:,1); % remove (and save) frame info column
        r.Forces.data = r.Forces.data(:,2:end);
        count = 1;
        
        for j = 1:length(ch)
            post = num2str(count);
            ch{j} = [ch{j},post];
            ch{j} = makevalidfield(ch{j});                 % fixes invalid fieldnames
            
            if isfield(data,ch{j})
                count = count+1;
                ch{j} = strrep(ch{j},post,num2str(count));
            end
            
            temp = r.Forces.data(:,j);
            data = addchannel_data(data,ch{j},temp,'Analog');
        end
        
        data.zoosystem.Analog.Channels = ch;
        data.zoosystem.Analog.Freq = r.Video.Freq;
        data.zoosystem.Analog.Indx = makecolumn(1:1:length(indx));
        data.zoosystem.Analog.ORIGINAL_START_FRAME = [indx(1) 0 0];
        data.zoosystem.Analog.ORIGINAL_END_FRAME = [indx(end) 0 0];
        data.zoosystem.Analog.CURRENT_START_FRAME = [1 0 0];
        data.zoosystem.Analog.CURRENT_END_FRAME = [length(indx) 0 0];
        
    end
    
    % Add analog (e.g. EMG)
    %
    if ~isfield(r,'Analog')
        
           ch = r.Forces.Channels;
        indx = r.Forces.data(:,1); % remove (and save) frame info column
        r.Forces.data = r.Forces.data(:,2:end);
        count = 1;
        
        for j = 1:length(ch)
            post = num2str(count);
            ch{j} = [ch{j},post];
            ch{j} = makevalidfield(ch{j});                 % fixes invalid fieldnames
            
            if isfield(data,ch{j})
                count = count+1;
                ch{j} = strrep(ch{j},post,num2str(count));
            end
            
            temp = r.Forces.data(:,j);
            data = addchannel_data(data,ch{j},temp,'Analog');
        end
        
        
        if ~isfield(data.zoosystem.Analog,'Channels')     
            data.zoosystem.Analog.Channels = ch;
            data.zoosystem.Analog.Freq = r.Video.Freq;
            data.zoosystem.Analog.Indx = makecolumn(1:1:length(indx));
            data.zoosystem.Analog.ORIGINAL_START_FRAME = [indx(1) 0 0];
            data.zoosystem.Analog.ORIGINAL_END_FRAME = [indx(end) 0 0];
            data.zoosystem.Analog.CURRENT_START_FRAME = [1 0 0];
            data.zoosystem.Analog.CURRENT_END_FRAME = [length(indx) 0 0];
        else
            temp = data.zoosystem.Analog.Channels;
            data.zoosystem.Analog.Channels = [ch;temp]; % add on the other analog
        end
    end


    
    
     
    % Save all into to file
    %
    if saveFile
        zsave(zfl,data)
    else
        disp(' ')
        disp('zoo file loaded to workspace')
        disp(' ')
    end
    
    if del
        delete(fl{i})
    end
    
end




%---SHOW END OF PROGRAM-------
%
disp(' ')
disp('****************************')
disp('Finished converting data in: ')
toc
disp('****************************')







