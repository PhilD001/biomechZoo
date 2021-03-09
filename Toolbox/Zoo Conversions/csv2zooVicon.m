function data= csv2zooVicon(fld,del)

% data= CSV2ZOOVICON(fld,del)converts csv file output from vicon to zoo format.
%
% ARGUMENTS
%  fld        ... Optional argument. Enter full path leading to folder
%  del        ... Optional argument. Delete original files. Default 'no'
%
% RETURNS
%  data       ... Optional return
%
% NOTES
% - Files should have been exported using the "export data to ascii file" NOT "exportcsv"
% - Where possible c3d export is quicker and provides more meta information to the user
% - Force plate channel names are changed to reflect expected names from
%   c3d files (e.g. 'ForcesFx1','MomentMx1')

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
% Updated by Philippe C. Dixon Nov 2016
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
    batchdisp(fl{i},'creating zoo file')
    zfl = extension(fl{i},'zoo');
        
    r  = readcsvVicon(fl{i});
        
    % Initialize zoo data structure
    %
    data = struct;
    data.zoosystem = setZoosystem(fl);
    
    % Add video channels to data struct
    %
    ch = r.Video.Channels;   
    indx = r.Video.Data(:,1); % remove (and save) frame info column
    r.Video.Data = r.Video.Data(:,2:end);
        
    for j = 1:length(ch)
        ch{j} = makevalidfield(ch{j});                 % fixes invalid fieldnames
        if isfield(data,ch{j})
            disp(['WARNING: Repeated channel name ',ch{j}, ' to be renamed ',ch{j},num2str(j)])
        end
        temp = r.Video.Data(:,3*j-2:3*j);
        data = addchannel_data(data,ch{j},temp,'Video');
    end
    
    data.zoosystem.Video.Channels = ch;
    data.zoosystem.Video.Freq = r.Video.Freq;
    data.zoosystem.Video.Indx = makecolumn(1:1:length(indx));
    data.zoosystem.Video.ORIGINAL_START_FRAME = [indx(1) 0 0];
    data.zoosystem.Video.ORIGINAL_END_FRAME = [indx(end) 0 0];
    data.zoosystem.Video.CURRENT_START_FRAME = [1 0 0];
    data.zoosystem.Video.CURRENT_END_FRAME = [length(indx) 0 0];
    
   
    % Add event data
    %
    if isfield(r,'Events')
        if isfield(data,'SACR')
            data.SACR.event = r.Events;
        else
            data.(ch{1}).event = r.Events;
        end
    end
    
    
    % Add force plate channels to data struct
    %
    % - force plate channel names are changed to agree with c3d style
    % outputs
    
    if isfield(r,'Forces')   % these are force plate channels
        ch = r.Forces.Channels;
        indx = r.Forces.Data(:,1); % remove (and save) frame info column
        r.Forces.Data = r.Forces.Data(:,2:end);
        count = 1;
        lbl = cell(size(ch));
        for j = 1:length(ch)
            post = num2str(count);
            
            if strfind(ch{j},'COP')
                ch{j} = strrep(ch{j},'_',[post,'_']);
            else
            ch{j} = [ch{j},post];
            end
            
            ch{j} = makevalidfield(ch{j});                 % fixes invalid fieldnames
            
            if isfield(data,ch{j})
                count = count+1;
                ch{j} = strrep(ch{j},post,num2str(count));
            end
            
            if ~isempty(strfind(ch{j},'Force')) || ~isempty(strfind(ch{j},'Moment'))
                lbl{j} = ch{j};
            end
            
            temp = r.Forces.Data(:,j);
            data = addchannel_data(data,ch{j},temp,'Analog');
        end
        
     
        
        lbl(cellfun(@isempty,lbl)) = [];
        data.zoosystem.Analog.FPlates.LABELS = lbl;

        
        data.zoosystem.Analog.Channels = ch;
        data.zoosystem.Analog.Freq = r.Forces.Freq;
        data.zoosystem.Analog.Indx = makecolumn(1:1:length(indx));
        data.zoosystem.Analog.ORIGINAL_START_FRAME = [indx(1) 0 0];
        data.zoosystem.Analog.ORIGINAL_END_FRAME = [indx(end) 0 0];
        data.zoosystem.Analog.CURRENT_START_FRAME = [1 0 0];
        data.zoosystem.Analog.CURRENT_END_FRAME = [length(indx) 0 0];   
    
       
        data.zoosystem.Analog.FPlates.CORNERS = r.Forces.FPlates.CORNERS;
        data.zoosystem.Analog.FPlates.NUMUSED = r.Forces.FPlates.NUMUSED;
       
        % fix COP names
        numPlates = data.zoosystem.Analog.FPlates.NUMUSED;
        for j = 1:numPlates
            cch = {['COP',num2str(j),'_x'],['COP',num2str(j),'_y'],['COP',num2str(j),'_z']};
            data = mergechannel_data(data,cch);                       % use existing for csv
        end
        
    end
    
    % Add analog (e.g. EMG)
    %
    if isfield(r,'Analog')
        ch = r.Analog.Channels;
        indx = r.Analog.Data(:,1); % remove (and save) frame info column
        ch = ch(2:end);
        r.Analog.Data = r.Analog.Data(:,2:end);
        
        for j = 1:length(ch)
            ch{j} = makevalidfield(ch{j});                 % fixes invalid fieldnames
            temp = r.Analog.Data(:,j);
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
            if ~isequal(r.Forces.Freq,r.Analog.Freq)
                error('Force and Analog sampling frequencies should be equal')
            end
            
            temp = data.zoosystem.Analog.Channels;
            data.zoosystem.Analog.Channels = [ch;temp]; % add on the other analog
        end
    end

    % add header information
    %
    if isfield(r,'Header')
        ch = fieldnames(r.Header);
        for j = 1:length(ch)
            if i==1
            data.zoosystem.Header.SubName = r.Header.(ch{j});
            else
            data.zoosystem.Header.(ch{j}) = r.Header.(ch{j}); 
            end    
        end 
    end
    
    data.zoosystem.AVR = data.zoosystem.Analog.Freq / data.zoosystem.Video.Freq;
    
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