function data = c3d2zoo(fld,del)

% data = C3D2ZOO(fld,del) Converts .c3d files to .zoo format
%
% ARGUMENTS
%  fld   ...  Folder (batch process) or full path to individual file (string).
%  del   ...  option to delete c3d file after creating zoo file.
%             Default:'no' or false
%
% RETURNS
%  data  ...  zoo data. Return if fld is individual file (mostly used by 'director')
%
% See also csv2zoo, readc3d
%
% NOTES:
% - The function attempts to fix invalid fielnames via the makevalidfield.m function


% Revision History
%
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon Nov 2008
% - reorganised to match zoo system
%
% Updated by Philippe C. Dixon May 2014
% - This function has been reintroduced as the main c3d converter after recent update
%   of the readc3d function by JJ Loh
% - reintroduction of the 'return' of the function for use with director
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.Processing'
% - c3d files with no 'EVENT' information can now be read without error
% - updated algorithm to find force plate locations. Unlimited number of
%   force plates can now be used
%
% Updated by Philippe C. Dixon Oct 2015
% - bug fix for c3d files with two or more channels with same labels.
%   e.g. If a marker set has channels 'RKNE' and 'RKNEjointcenter', the c3d file saves
%        both channel labels as 'RKNE' (First four characters only). This led to a deletion
%        of the first channel in the c3d2zoo function. Now c3d2zoo will append the channel number
%        to the nth channel with a repeated label. In this example the channels would be 'RKNE' and
%        'RKNEn' where n is the channel number from the c3d file
%
% Updated by Philippe C. Dixon March 2016
% - added additional meta info describing force plate channel names
% - added a copy of ALL c3d meta info to data.zoosystem.OriginalC3dMetaInfo
% - renamed units subfiled 'moments' to 'Moments'
%
% Updated by Philippe C. Dixon July 2016
% - version 1.3 of the zoosystem
% - checks that channels are appropriate for storage in a structured array
%   using 'makevalidfield'
%
% Updated by Philippe C. Dixon Nov 2016
% - cleaned up code to be more consistent with recent biomechZoo updates
% - added units for EMG (voltage)


% SET DEFAULTS / ERROR CHECK -----------------------------------------------------------------
%
tic                                                                          % start timer


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

[fld,fl,saveFile] = checkinput(fld,'.c3d');
cd(fld)


% FIND AND LOAD .C3D FILES
%
for i = 1:length(fl)
    
    % Extract info from c3d file
    %
    batchdisplay(fl{i},'converting to zoo');
    r = readc3d(fl{i});
    zfl = extension(fl{i},'zoo');
    
    % Initialize zoo data structure
    %
    data = struct;
    data.zoosystem = setZoosystem(fl{i});
    
    % Add video channels to data struct
    %
    vfld = fieldnames(r.VideoData);
    vlbl = cell(size(vfld));
    
    for v = 1:length(vfld)
        vlbl{v} = makevalidfield(r.VideoData.(vfld{v}).label);                 % fixes invalid fieldnames
        
        if isfield(data,vlbl{v})
            disp(['WARNING: Repeated channel name ',vlbl{v}, ' to be renamed ',vlbl{v},num2str(v)])
        end
        
        temp = [makecolumn(r.VideoData.(vfld{v}).xdata),makecolumn(r.VideoData.(vfld{v}).ydata),...
            makecolumn(r.VideoData.(vfld{v}).zdata)];
        data = addchannel_data(data,vlbl{v},temp,'video');
    end
    
    % Add analog channels to data struct
    %
    afld = fieldnames(r.AnalogData);
    albl = cell(size(afld));
    
    for a = 1:length(afld)
        albl{a} = makevalidfield(r.AnalogData.(afld{a}).label);                                  % fixes all invalid fieldnames
        
        if isfield(data,albl{a})
            disp(['WARNING: Repeated channel name ',albl{a}, ' to be renamed ',albl{a},num2str(v)])
        end
        
        temp =  makecolumn(r.AnalogData.(afld{a}).data);
        data = addchannel_data(data,albl{a},temp,'analog');
    end
    
    
    % Set frequency information
    %
    data.zoosystem.Video.Freq = r.Header.VideoHZ;
    
    if isfield(r.Parameter,'ANALOG')
        data.zoosystem.Analog.Freq = r.Parameter.ANALOG.RATE.data;
    else
        data.zoosystem.Analog.Freq = 0;
    end
    
    data.zoosystem.AVR =   data.zoosystem.Analog.Freq/data.zoosystem.Video.Freq;
    
    
    % Set frame information
    %
    startVid = r.Header.FirstVideoFrame;                                % write zoo system info
    finVid = r.Header.EndVideoFrame;
    
    startAnal = startVid*data.zoosystem.AVR;
    finAnal = finVid*data.zoosystem.AVR;
    
    data.zoosystem.Video.Indx = makecolumn(linspace(startVid,finVid,(finVid-startVid+1))) ;
    data.zoosystem.Video.ORIGINAL_START_FRAME = [startVid 0 0];
    data.zoosystem.Video.ORIGINAL_END_FRAME   = [finVid 0 0];
    data.zoosystem.Video.CURRENT_START_FRAME  = [1 0 0];
    data.zoosystem.Video.CURRENT_END_FRAME    = [finVid-startVid+1 0 0];
    
    data.zoosystem.Analog.Indx  =  makecolumn(linspace(startAnal,finAnal,(finAnal-startAnal+1))) ;
    data.zoosystem.Analog.ORIGINAL_START_FRAME = [startAnal 0 0];
    data.zoosystem.Analog.ORIGINAL_END_FRAME   = [finAnal 0 0];
    data.zoosystem.Analog.CURRENT_START_FRAME  = [1 0 0];
    data.zoosystem.Analog.CURRENT_END_FRAME    = [finAnal-startAnal+1 0 0];
    
    
    % set header information
    %
    data.zoosystem.Header = setHeader(r);
    
    
    % Set unit information
    %
    data.zoosystem.Units = setUnits(r,data);
    
    
    % set force plate information
    %
    data.zoosystem.Analog.FPlates = setFPinfo(r);
    
    
    % set anthro metainformation (if available) to zoosystem branch of data struct
    %
    data.zoosystem.Anthro = setAnthro(r);
    
    
    % set events metainformation (if available) to zoosystem branch of data struct
    %
    data = setEvents_data(data,r);
    
   
    % set all other meta info
    %
    mch = setdiff(fieldnames(r),{'VideoData','AnalogData'});
    
    for m = 1:length(mch)
        data.zoosystem.OtherMetaInfo.(mch{m}) = r.(mch{m});
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

%---SHOW END OF PROGRAM-------------------------------------------------------------------------
%
disp(' ')
disp('**********************************')
disp('Finished converting data in: ')
toc
disp('**********************************')



function Header = setHeader(r)

Header = struct;

Header.SubName =  makerow(deblank(r.Parameter.SUBJECTS.NAMES.data));
Header.Date = '';
Header.Time = '';
Header.Description = '';  % this remains empty


function Units = setUnits(r,data)

pch = fieldnames(r.Parameter.POINT);

 %       data.zoosystem.Units.Forces = makerow(r.Parameter.POINT.FORCE_UNITS.data);


for j = 1:length(pch)
    
    if strfind(pch{j},'UNITS')
        
        if strfind(pch{j},'_')
            type = strrep(pch{j},'_UNITS','');
            type = lower(type);
            type(1) = upper(type(1));
        else
            type= 'Markers';
        end
        
        Units.(type) = makerow(r.Parameter.POINT.(pch{j}).data);
    end
end

if isfield(Units,'Power')
    Units.Power = 'W/kg'; % Vicon is lying r.Parameter.POINT.POWER_UNITS
end

ach = data.zoosystem.Analog.Channels;
check = true;
count = 1;
while check && count < length(ach)
    if strfind(ach{count},'Voltage')
        Units.EMG = 'Voltage';
        check = false;
    else
        count = count+1;
    end
end


function FPlates = setFPinfo(r)

if isfield(r.Parameter,'FORCE_PLATFORM')
    a =r.Parameter.FORCE_PLATFORM.CORNERS.data;
    a= reshape(a,3,[]);
    ln = length(a);
    
    b = zeros(3,4,ln/4);
    
    for j = 1:ln/4
        
        if j ==1
            b(:,:,1) = a(:,1:4);
        else
            b(:,:,j) = a(:,4*(j-1)+1:4*j);
        end
    end
    
    if ~isempty(b)
        FPlates.CORNERS = b;
        FPlates.LOCALORIGIN = r.Parameter.FORCE_PLATFORM.ORIGIN.data;
        FPlates.NUMUSED = r.Parameter.FORCE_PLATFORM.USED.data;
        
        a = r.Parameter.ANALOG.LABELS.data;
        
        temp = cell(r.Parameter.FORCE_PLATFORM.USED.data*6,1);
        for j = 1:(r.Parameter.FORCE_PLATFORM.USED.data)*6
            temp{j} = makevalidfield(deblank(a(:,j)'));
        end
        FPlates.LABELS = temp;
        
    else
        FPlates.CORNERS = [];
        FPlates.LOCALORIGIN = [];
        FPlates.NUMUSED = 0;
    end
end


function Anthro = setAnthro(r)

if isfield(r.Parameter,'PROCESSING')
    ach = setdiff(fieldnames(r.Parameter.PROCESSING),{'id','islock'});
    
    for j = 1:length(ach)
        rr = r.Parameter.PROCESSING.(ach{j});
        
        if isstruct(rr)
            rr = rr.data;
        end
        
        Anthro.(ach{j}) =  rr;
    end
   
else
    Anthro = struct;  
end

function data = setEvents_data(data,r)

if isfield(r.Parameter,'EVENT')

    vidFreq = data.zoosystem.Video.Freq;
    vch = data.zoosystem.Video.Channels{1};
    
    if isfield(r.Parameter.EVENT,'TIMES')
        
        if ~isempty(r.Parameter.EVENT.TIMES.data)
            
            times = r.Parameter.EVENT.TIMES.data(2,:);
            sides = r.Parameter.EVENT.CONTEXTS.data;
            type =  r.Parameter.EVENT.LABELS.data;
            
            [~,cols] = size(sides);
            
            events = struct;            
            for s = 1:cols
                ech = [sides(:,s)','_',type(:,s)'];
                ech = strrep(ech,' ','');
                events.(ech).lines(s) = times(s);
            end
            
            ech = fieldnames(events);
            
            for e = 1:length(ech)
                temp = sort(events.(ech{e}).lines);
                indx = temp==0;
                temp(indx) = [];
                events.(ech{e}) = temp;   % this output should match  btkGetEvents(H)
                
                for j = 1:length(events.(ech{e}))
                    
                    frame = round(events.(ech{e})(j)*vidFreq) - data.zoosystem.Video.ORIGINAL_START_FRAME(1) +1;
                    if ~isfield(data,'SACR')
                        data.(vch).event.([ech{e},num2str(j)]) = [frame 0 0];
                    else
                        data.SACR.event.([ech{e},num2str(j)]) = [frame 0 0];
                    end
                    
                end
                
            end
        end
    end
   

end

