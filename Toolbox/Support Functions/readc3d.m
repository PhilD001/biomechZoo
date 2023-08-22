function data =readc3d(fname)

% DATA = READC3D(FNAME) will read a .c3d file and output the data in a structured array
%
% ARGUMENTS
%  fname     ... the c3d file and path (as a string) eg: 'c:\documents\myfile.c3d'
%
% RETURNS
%  data      ...  structured array
%
% Notes
% - Machinetype variable may not be correct for intel or MIPS C3D files.
%   This m-file needs to be tested with C3D files of these types.
%   This m-file was tested and passed with DEC (VAX PDP-11) C3D files
% - Only character, integer, and real numbers have been tested.
%   see http://www.c3d.org/HTML/default.htm for information
% - Residuals of 3D data are not handled


% Revision History
%
% Created by JJ Loh  Sept 10th 2006
%
% Updated by JJ loh March 8th 2008
% -video channels can handle NaN's
%
% Updated by JJ Loh April 10th 2008
% -header can be outputed alone
%
% Updated by JJ Loh April 30th 2014
% - header input variable removed
% - clean field names so that it is compatible with matlab structured arrays
% - default analog format is signed integer
%
% Updated by Philippe C. Dixon May 3rd 2014
% - cleaning of fieldnames via existing 'makevalidfield' function
% (validfieldname embedded function remains, but is unused)
%
% Updated by JJ Loh Sept 23rd 2014
%- c3d files with large amount of channels will store the labels in
%  multiple locations.  Now this function can consolidate the label names.
%
% Updated by Philippe C. Dixon May 19th 2015
% - removed unused embedded function
%
% Updated by Philippe C. Dixon Aug 24th 2015
% - Fixed bug in the 'GEN_SCALE' field experienced by some users
%
% Updated by Philippe C. Dixon April 2017
% - Fixed bug for c3d files without any analog fields
% - Added error check for files that can't be opened
%
% Updated by Philippe C. Dixon December 2017
% - bug fix for c3d files without 'ANALOG' field in parameter info
%
% Updated by Philippe C. Dixon May 2019
% - invalid fields that cannot be fixed are displayed and skipped via try 
%   and catch statement
%
% Updated by Philippe C. Dixon March 2022
% - updated reading of header to deal with long trials. See: 
% https://www.mathworks.com/matlabcentral/answers/79368-use-of-the-fread-function
%
% Updated by Oussama Jlassi Aug 2023
% -Reduce the function findzeros' run time
% -------------------------------------------

mtype = getmachinecode(fname);
switch mtype
    case 84  %intel
        machinetype = 'ieee-le';
    case 85 %DEC (VAX PDP-11)
        machinetype = 'vaxd';
    case 86 %MIPS
        machinetype = 'ieee-be';
    otherwise
        error('unknown machinetype')
end
fid=fopen(fname,'r',machinetype);

%--------------------HEADER SECTION----------------------------------------
%  Reading record number of parameter section
pblock=fread(fid,1,'int8');         %getting the 512 block number where the paramter section is located block 1 = first 512 block of the file
fread(fid,1,'int8');           %code for a C3D file

%  Getting all the necessary parameters from the header record
%                                  word     description
U16 = 'uint16';   
F32 = 'float32';
H.ParamterBlockNum = pblock;
H.NumMarkers =fread(fid,1,U16);             %2      number of markers
H.SamplesPerFrame =fread(fid,1,U16);        %3      total number of analog measurements per video frame
H.FirstVideoFrame =fread(fid,1,U16);        %4      # of first video frame
H.EndVideoFrame =fread(fid,1,U16);          %5      # of last video frame
H.MaxIntGap =fread(fid,1,U16);              %6      maximum interpolation gap allowed (in frame)

Scale =fread(fid,1,F32);                    %7-8    floating-point scale factor to convert 3D-integers to ref system units
% If scale is negative, the data is stored in float format:
H.FloatMode = (Scale < 0.0);
H.Scale     = abs(Scale);

H.StartRecord =fread(fid,1,U16);            %9      starting record number for 3D point and analog data
H.SamplesPerChannel =fread(fid,1,U16);      %10     number of analog samples per channel
H.VideoHZ =fread(fid,1,F32);                %11-12  frequency of video data
fseek(fid,2*148,'bof');                         %13-147 reserved for future use
H.LablePointer =fread(fid,1,'int16');           %label and range data pointer

if nargin == 2
    data = H;
    return
end


%---------------------PARAMETER SECTION-------------------------------------
fseek(fid,(pblock-1)*512,'bof');  %the start of the parameter block

%parameter header
fseek(fid,2,'cof');  %ignore the first two bytes of the header
numpblocks = fread(fid,1,'uint8'); %number of parameter blocks
processor = fread(fid,1,'uint8'); %processor type 84 = intel, 85 = DEC (VAX PDP-11), 86 = MIPS processor (SGI/MIPS)
switch processor
    case 84 %intel
        machinetype = 'ieee-le';
    case 85 %DEC (VAX PDP-11)
        machinetype = 'vaxd';
    case 86 %MIPS
        machinetype = 'ieee-be';
end
Pheader.NumberOfBlocks = numpblocks;
Pheader.MachineType = processor;
%getting group list
P = struct;
while 1
    numchar = fread(fid,1,'int8');                  %number of characters in the group name
    id = fread(fid,1,'int8');                       %group/parameter id
    gname = char(fread(fid,abs(numchar),'uint8')'); %group/parameter name
    index = ftell(fid);                             %this is the starting point for the offset
    nextgroup = fread(fid,1,'int16');               %nextgroup = offset to the next group/parameter
    if numchar < 0                                 %a negative character length means the group is locked
        islock = 1;
    else
        islock = 0;
    end
    fld = [];                                   %fld = structured field to add to the output
    fld.id = id;                                %fld has fields id and description
    fld.islock = islock;
    
    if id < 0                                       %groups always have id <0 parameters are always >0
        dnum = fread(fid,1,'uint8');                %number of characters of the desctription
        desc = char(fread(fid,dnum,'uint8')');      %description of the group/parameter
        fld.description = desc;
        
        try 
            P.(gname)=fld;
        catch
            disp(['skipping invalid field found:' gname])
            continue
        end
                                      %add the field to the variable P
    else %it is a parameter
        dtype = fread(fid,1,'int8');                %what type of data -1 = char 1 = byte  2 = 16 bit integer 3 = 32 bit floating point
        numdim = fread(fid,1,'uint8');              %number of dimensions (0 to 7 dimensions)
        fld.datatype = dtype;                       %data type of the parameter -1=character, 1=byte, 2=integer, 3= floting point, 4=real
        fld.numberDIM = numdim;                     %number of dimensions (0-7) 0 = scalar, 1=vector, 2=2D matrix,3=3D matrix,...etc
        fld.DIMsize = fread(fid,numdim,'uint8');    %size of each dimension eg [2,3]= 2d matrix with 2 rows and 3 columns
        dsize = fld.DIMsize';                       %the fread function only reads row vectors
        
        if isempty(dsize)                           %if dsize is empty then we read a scalar
            dsize = 1;
        end
        if length(dsize) > 2
            dsize = prod(dsize);                    %fread can only handle up to 2 dimensions
        end                                         %if it is greater than 2 dimensions, then just read all data in a single vector.
        
        switch dtype
            case -1 %character data
                pdata = char(fread(fid,dsize,'uint8'));
            case 1 %byte data  !!!Not tested
                pdata = fread(fid,dsize,'bit8');
            case 2 %16 bit integer
                pdata = fread(fid,dsize,'int16',machinetype);
            case 3 %32 bit floating point
                pdata = fread(fid,dsize,'float32',machinetype);
            case 4 %REAL data
                pdata = fread(fid,dsize,'float32',machinetype);
        end
        dnum = fread(fid,1,'uint8');             %number of characters in the description
        desc = char(fread(fid,dnum,'uint8')');      %description string
        fld.description = desc;
        fld.data = pdata;                            %add data to parameter structured var
        P = setparameter(P,gname,fld);              %add parameter to the appropriate group
    end
    if nextgroup == 0
        break
    end
    fseek(fid,index+nextgroup,'bof');               %go to next group/parameter.
    
end
data.Header = H;
data.ParameterHeader = Pheader;
data.Parameter = P;


%------------------------3D & Analogue DATA SECTION----------------

%first position
fseek(fid,(data.Parameter.POINT.DATA_START.data-1)*512,'bof');
%Analogue data parameters

if ~isfield(data.Parameter,'ANALOG')                       % PD update for Optitrak
    numAnalogue = 0;
    Alabels = [];
    Ascale = [];
    Gscale = [];
    Aoffset = [];
    
elseif data.Parameter.ANALOG.USED.data                      % PD update March 2017
    numAnalogue = data.Parameter.ANALOG.USED.data;
    Alabels = cellstr(data.Parameter.ANALOG.LABELS.data');
    Ascale = data.Parameter.ANALOG.SCALE.data;
    
    if isfield(data.Parameter.ANALOG,'EN_SCALE')
        Gscale = data.Parameter.ANALOG.EN_SCALE.data;
    else
        Gscale = data.Parameter.ANALOG.GEN_SCALE.data;
    end
    
    Aoffset = data.Parameter.ANALOG.OFFSET.data;
    if isfield(data.Parameter.ANALOG,'FORMAT')
        issigned = data.Parameter.ANALOG.FORMAT.data';
    else
        issigned = 'SIGNED';
    end
    if strcmp(issigned,'SIGNED')
        issigned = 1;
    else
        issigned = 0;
    end
else
    numAnalogue = 0;
    Alabels = [];
    Ascale = [];
    Gscale = [];
    Aoffset = [];
end

%Video (3D) data parameters
numVideo = data.Parameter.POINT.USED.data;
if isfield(data.Parameter.POINT,'LABELS')
    Vlabels = cellstr(data.Parameter.POINT.LABELS.data');
else
    Vlabels = {};
end

for i = 2:length(fieldnames(data.Parameter.POINT))
    fieldName = ['LABELS',num2str(i)];
    if isfield(data.Parameter.POINT,fieldName)
        Vlabels = [Vlabels;cellstr(data.Parameter.POINT.(fieldName).data')];
    else
        break
    end
end
Vscale = data.Parameter.POINT.SCALE.data;
% numFrames = data.Parameter.POINT.FRAMES.data;     % old JJ code
numFrames = H.EndVideoFrame - H.FirstVideoFrame + 1;

inc = 4*numVideo+H.SamplesPerFrame;
%inc is the increment.  Increment is the number of elements in a video
%frame and this consist of:
%The number of Video Channels*4 (xdata,ydata,zdata,and residual) + The
%number of Analogue Measurements per frame;
%Note: the number of Analogue Measurements does NOT always equal the number
%of analogue channels.

numdatapts = numFrames*inc;
%number of data points to read this is:
%(Number of frames)*(Number of data per frame)


%READING the DATA
if Vscale >= 0   %integer format
    AVdata = fread(fid,numdatapts,'int16',machinetype);
else            %floating point format
    AVdata = fread(fid,numdatapts,'float32',machinetype);
end

V = struct;
%data for all Video channels
offset = 1;
for i = 1:numVideo
    xd = AVdata(offset:inc:end);
    yd = AVdata(offset+1:inc:end);
    zd = AVdata(offset+2:inc:end);
    residual = AVdata(offset+3:inc:end);
    if i > length(Vlabels)
        Vdata.label = ['MRK ',num2str(i)];
    else
        Vdata.label = Vlabels{i};
    end
    indx = findzeros([makecolumn(xd),makecolumn(yd),makecolumn(zd)]);
    Vdata.xdata = videoconvert(xd,Vscale,indx);
    Vdata.ydata = videoconvert(yd,Vscale,indx);
    Vdata.zdata = videoconvert(zd,Vscale,indx);
    Vdata.residual = residual;
    offset = offset+4;
    V.(['channel',num2str(i)]) = Vdata;
end

offset = 4*numVideo;  %offset is a pointer to the first data point of the first channel of Analog data
A = struct;
for i = 1:numAnalogue
    Adata.label = Alabels{i};
    Aframedata = [];
    %A given analog channel can have multiple samples per frame of video
    for j = 0:H.SamplesPerChannel-1
        stindx = offset+i+j*numAnalogue;
        plate = AVdata(stindx:inc:end);
        Aframedata = [Aframedata,plate];
    end
    Adata.data = analogconvert(merge(Aframedata),Aoffset(i),Ascale(i),Gscale,issigned);  %recombine the multiple samples to one vector
    A.(['channel',num2str(i)]) = Adata;
end

data.VideoData = V;
data.AnalogData= A;

fclose(fid);


function r = setparameter(g,name,info)
%this function will add a parameter to the appropriate group (based on the
%id)  Note if no group is found, the parameter will not be added.
fld = fieldnames(g);
r = g;
for i = 1:length(fld)
    d = getfield(g,fld{i});
    if abs(info.id) == abs(d.id)
        r = setfield(g,makevalidfield(fld{i}),setfield(d,makevalidfield(name),info));
        break
    end
end

function r = merge(data)
%this function will recombine the analogue data because the potential for multiple
%samples per frame of video.
%each row of "data" corresponds to a single video frame;
[rw,cl] = size(data);
r = zeros(rw*cl,1);
for i = 1:cl
    r(i:cl:end) = data(:,i);
end

function r = videoconvert(data,scale,indx)
%convert the video channels to real data values
if scale >0
    r = data*scale;
else
    r = data;
end
r(indx) = NaN;

function r = analogconvert(data,offset,chscale,gscale,issigned)
%convert analog channesl to real data values
if ~issigned
    data = unsign(data);
end
r = (data-offset)*chscale*gscale;

function r = unsign(data)
indx = find(data<0);
data(indx) = 2^16+data(indx);
r = data;

function r = getmachinecode(fname)
fid = fopen(fname,'r');
if fid==-1
    error(['unable to open file: ',fname])
end
pblock=fread(fid,1,'int8')-1;         %getting the 512 block number where the paramter section is located block 1 = first 512 block of the file
fseek(fid,pblock*512+3,'bof');
r = fread(fid,1,'uint8');
fclose(fid);

function r = findzeros(data)
% Find indices of rows where all columns have zero values
allZeroRows = all(data == 0, 2);
%Get indices of the rows with all zeros
r = find(allZeroRows);