function data= generic2zoo(fld,chHeaderRow,ext,delim,section,del)  

% data = GENERIC2ZOO(fld,chHeaderRow,ext,del) converts data from generic spreadsheet
% type files to .zoo format
%
% ARGUMENTS
%  fld           ...  Folder (batch process) or full path to individual file (string).
%  chHeaderRow   ...  Row where channel headers appear
%  ext           ...  Extension of files to convert. 
%  delim         ...  Delimiter in file. Default '\n'
%  section       ...  Section of zoo file 'video' or 'analog'. Default 'video'
%  del           ...  option to delete c3d file after creating zoo file. 
%                     Default:'no' or false
%
% RETURNS
%  data  ...  zoo data. Return if fld is individual file 
%
% NOTES
% - text style documents with the following elecments will be properly read by this
%   function: 
%   a) 'n' rows of headers: If these rows are of the form 'x = y'. The
%   element on the left of the equal sign will be stored as a name while the element on 
%   the right of the equal sign will be stored as its value. e.g. 
%   data.zoosystem.CompInfo.x = y. 
% 
%   b) 1 row of channel names of n elements 'a b c d ... n'. Each column will form a channel
%   name in the zoo file. e.g. data.a, data.b, data.c, ...data.n. These channels will be 
%   considered video channels. 
%   c) n rows of data. Each column in the data field is assumed to be related to the columns
%   in the channel names 
% - If the text file does not meet these criteria, it should be possible to modify this function
%   relatively easily
%
% See also c3d2zoo, readcsv


% Created by Philippe C. Dixon October 2016


% SET DEFAULTS / ERROR CHECK -----------------------------------------------------------------
%
tic                                                      % start timer

FreqNames = {'SamplingRate','SampleRate','Frequency'}; % possible names for freq in header
numSampNames = {'NumberOfSamples','Samples'};           % possible names for num samps in header

nHeaderLines = chHeaderRow-1;                          % all rows above chHeaderRow are header

if nargin==3
    delim = '\n';
    section = 'Video';
    del = false;
end

if nargin ==4
    section = 'Video';
    del = false;
end

if nargin==5
    del = false;
end

if strcmp(del,'yes') || strcmp(del,'on')
    del = true;
end


[fld,fl,saveFile] = checkinput(fld,ext);
cd(fld)


%-------LOAD DATA--------
%

for i = 1:length(fl)
    batchdisp(fl{i},'creating zoo file')
    zfl = extension(fl{i},'zoo');
      
    % Read file and extract header, channel names, and data
    %
    fid= fopen(fl{i});
    
    header = textscan(fid,'%s',nHeaderLines,'Delimiter',delim); % header is first nHeaderLines
    header = header{:};                                         % cleanup header
    
    chnames = textscan(fid,'%s',1,'Delimiter',delim);           % channel names are next
    chnames = strsplit(char(chnames{:}));                       % clean channel names
    
    r = textscan(fid, '%f', 'delimiter', '\n');                 % data cols are next
    r = r{:};                                                   % clean up data 
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
        
        temp = r(:,v);
        data = addchannel_data(data,chnames{v},temp,section);
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

