function data = biometricsEMG2zoo(fld,nHeaderRows,del)  

% data = biometricsEMG2zoo(fld,nHeaderRows,del) converts EMG data collected with a 
% biometrics data logger to zoo files
%
%
% ARGUMENTS
%  fld           ...  Folder (batch process) or full path to individual file (string).
%  nHeaderRows   ...  Total number of rows in the header. This could change based on 
%                     number of muscles collected. Default, nHeaderRows = 16
%  del           ...  option to delete csv file after creating zoo file. 
%                     Default, del = false
%
% RETURNS
%  data  ...  zoo data. Return if fld is individual file 
%
% NOTES
% - Data logger does not record sampling rate information in the files,
%   this information is manually added in the 'set defaults' section on
%   this code


% Created by Aiden Hallihan May 2017
%
% Updated by Philippe C. Dixon June 2017
% - bug fixes to get correct formats for zoo files
% - changed function arguments


% SET DEFAULTS / ERROR CHECK -----------------------------------------------------------------
%
ext = 'csv';                                                          % always this extension
section = 'Analog';                                                   % where to store zoo info
fsamp = 1000;                                                         % sampling rate 
if nargin==0
    fld = uigetfolder;
    nHeaderRows = 16;                                                  % this can change later
    del = false;
end

tic                                                                   % start timer

[fld,fl,saveFile] = checkinput(fld,ext);
cd(fld)


% LOAD DATA
%
for i = 1:length(fl)
    batchdisp(fl{i},'creating zoo file')
    zfl = extension(fl{i},'zoo');
      
    % Read file and extract header, channel names, and data
    %
    fid= fopen(fl{i});
    
    header = textscan(fid,'%s',nHeaderRows,'Delimiter','\n');         % header is first nHeaderLines
    header = header{1};
     
    chnames = header(2:nHeaderRows-1);                                % get channel names from file
    chnames = strrep(chnames,'"','');                                 % clean up names
    chnames = strrep(chnames,'''','');    

    r = textscan(fid, '%s', 'Delimiter', ',');                        % data cols are next
    r = r{:};                                                         % clean up data 
    r = r(15:end,:);                                                  % first line is blank
    r = str2double(r);                                                % convert to numbers
    cols = length(chnames);                                           % get number of cols 
    rows = length(r)/cols;                                            % get number of rows
    r = reshape(r,cols,rows)';                                        % reshape matrix 
   
    st = fclose(fid);                                                 % close file
    if st
        error('unable to close file')
    end
    
    % Initialize zoo data structure
    %
    data = struct;
    data.zoosystem = setZoosystem(fl);

   
    % Add channels data to proper section
    %
    for a = 1:length(chnames)
        ch = makevalidfield(chnames{a});                              % more channel clean up
        temp = r(:,a);                                                % each column is channel data
        ch = ch(11:13);                                               % THIS IS THE NEW LINE, JUST EXTRACT THE NAME
        data = addchannel_data(data,ch,temp,section);                 % add to zoo branches
    end

    % Add metainfo to zoosystem
    %
    data.zoosystem.(section).Freq = fsamp;                            % make sure you know correct value
    data.zoosystem.(section).Indx = (1:1:rows)';                      % index of frames recorded
    data.zoosystem.CompInfo.otherInfo = header{end};                  % might be important?
    
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



% SHOW END OF PROGRAM
%
disp(' ')
disp('****************************')
disp('Finished converting data in: ')
toc
disp('****************************')

