function data = lokomat2zoo(fld,cols,del)  

% data = LOKOMAT2ZOO(fld,del) converts data from lokomat generated text file
% to .zoo format
%
% ARGUMENTS
%  fld           ...  Folder (batch process) or full path to individual file (string).
%  cols          ...  number of columns in file. Default 26  
%  del           ...  option to delete c3d file after creating zoo file. 
%                     Default:'no' or false
%
% RETURNS
%  data  ...  zoo data. Return if fld is individual file 
%
% NOTES
% - 
%
% See also c3d2zoo, readcsv


% Created by Philippe C. Dixon May 2017
% - tested on ~\biomechZoo-help\examples\file conversions\example data
% (processed)\Recording_160621_110816

% SET DEFAULTS / ERROR CHECK -----------------------------------------------------------------
%
tic

if nargin==0
    cols = 26;
    fld = uigetfolder;
    del = false;
end

if nargin==1
    cols = 26;
    del = false;
end

if nargin==2
    del = false;
end

nHeaderLines = 1; % number of header lines
delim = ';';
ext = 'txt';
strings = repmat('%s',1,cols);
floats  = repmat('%f',1,cols);

if strcmp(del,'yes') || strcmp(del,'on')
    del = true;
elseif strcmp(del,'no') || strcmp(del,'off')
    del = false;
end

[fld,fl,saveFile] = checkinput(fld,ext);
cd(fld)


% Batch process
%
for i = 1:length(fl)
    batchdisp(fl{i},'creating zoo file')
    zfl = extension(fl{i},'zoo');
      
    % Read file and extract header, channel names, and data
    %
    fid= fopen(fl{i});

    header = textscan(fid,'%s%s',nHeaderLines,'Delimiter',delim); % header is first nHeaderLines
    header = header{:};                                           % cleanup header
    
    chnames = textscan(fid,strings,1,'Delimiter',delim);           % channel names are next
    chnames = [chnames{:}]';

    scan = true;
    count = 1;
    while scan
        curMat = textscan(fid,floats,count,'Delimiter',delim);
        curMat = [curMat{:}];
        if isempty(curMat)
            scan = false;
        else
            r = curMat;
            count = count+1;
        end
    end
    
    % clean up data 
    cols = length(chnames);                                     % reshape data
    rows = length(r)/cols;                                      % to correct size
    r = reshape(r,cols,rows)';
   
    st = fclose(fid);                                           % close file
    if st
        error('unable to close file')
    end
    
    % Initialize zoo data structure
    %
    data = struct;
    data.zoosystem = setZoosystem(fl);

   
    % Add channels data to proper section
    %
    for v = 1:length(chnames)
        chnames{v} = makevalidfield(chnames{v});
        
        if isfield(data,chnames{v})
            disp(['WARNING: Repeated channel name ',chnames{v}, ' to be renamed ',chnames{v},num2str(v)])
        end
        
        curMat = r(:,v);
        data = addchannel_data(data,chnames{v},curMat,section);
    end

    % Add metainfo to zoosystem
    %
    for m = 1:length(header)
        cheader = header{m};
        
        if ~isempty(strfind(cheader,'=')) 
           indx = strfind(cheader,'=');
           metaname = cheader(1:indx-1);
           metadata = cheader(indx+1:end);  
           if ~isnumeric(metadata)
               metadata = str2double(metadata);
           end
        else
            metaname = cheader;
            metadata = cheader;
        end
            
        metaname = makevalidfield(metaname);
        
         if isfield(data.zoosystem.CompInfo,metaname)
            disp(['WARNING: Repeated channel name ',metaname, ' to be renamed ',metaname,num2str(m)])
         end
        
         if ismember(metaname,FreqNames)
             data.zoosystem.(section).Freq = metadata;
         end
         
         if ismember(metaname,numSampNames)
             data.zoosystem.(section).Indx = (1:1:metadata)';
         end
         
        data.zoosystem.CompInfo.(metaname) = metadata;
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

