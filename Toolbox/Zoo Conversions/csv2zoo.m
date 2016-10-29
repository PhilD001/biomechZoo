function data= csv2zoo(fld,del)

% data = CSV2ZOO(fld,del) converts motion capture generated.csv files to .zoo format
%
% ARGUMENTS
%  fld   ...  Folder (batch process) or full path to individual file (string).
%  del   ...  option to delete c3d file after creating zoo file. 
%             Default:'no' or false
%
% RETURNS
%  data  ...  zoo data. Return if fld is individual file (mostly used by 'director')
%
% See also c3d2zoo, readcsv
%
% NOTES:
% - The function attempts to fix invalid fielnames via the makevalidfield.m function
% - Files should have been exported using the "export data to ascii file" NOT "exportcsv"
%
% Created by Philippe C. Dixon Octover 2016


% SET DEFAULTS / ERROR CHECK -----------------------------------------------------------------
%
tic                                                                          % start timer

ver = '1.3';                                                                 % zoo version

if strcmp(del,'yes') || strcmp(del,'on')
    del = true;
end

if nargin==0
    fld = uigetfolder;
    del = false;
end

if nargin==1
    del = false;
end

if isin(fld,'.csv')      % for a single trial (e.g. loading c3d in director)
    pth = fileparts(fld);
    fl= {fld};
    fld = pth;
    sf = false;          % do not save output to zoo file
else
    fl = engine('path',fld,'extension','csv');
    sf = true;
end

cd(fld)

%-------LOAD EXCEL DATA--------
%
fl = engine('path',fld,'extension','.csv');
cd(fld)

for i = 1:length(fl)
    batchdisplay(fl{i},'creating zoo file')
    zfl = extension(fl{i},'zoo');
       
    r  = readcsvMoCap(fl{i});
    
    % Initialize zoo data structure
    data = struct;
    

    % Add video channels to data struct
    %
    vlbl = r.Video.Channels;

    for v = 1:length(vlbl)
        
        if isfield(data,vlbl{v})
            disp(['WARNING: Repeated channel name ',vlbl{v}, ' to be renamed ',vlbl{v},num2str(v)])
        end
        indx = 3*v -1;
        temp = r.Video.data(:,indx:indx+2);
        data = addchannel_data(data,vlbl{v},temp,'video');
    end

    % Save all into to file
    %
    if sf
        zsave(zfl,data)
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

