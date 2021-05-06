function evalFile = eventval(varargin)
%
% evalFile = eventval(varargin) will transfer the values of all channels at given events to
% a spreadsheet for further analysis
%
% ARGUMENTS
% 'fld'             ... path to data folder as string
% 'dim1'            ... list of conditions as cell array of strings
% 'dim2'            ... list of subjects in study as cell array of strings
% 'ch'              ... list of channels as cell array of strings
% 'localevts'       ... list of local events as cell array of strings
% 'globalevts'      ... list of global events as cell array of strings
% 'anthroevts'      ... list of anthro events as cell array of strings
% 'ext'             ... Spreadsheet file type .xls, .xlsx, and .csv are possible. Default is .xls
% 'excelserver'     ... Choice to use excel server. Default 'off'
% 'eventvalfilename ... Custom name for eventval spreadsheet. Default 'eventval'
%
% RETURNS
% evalFile           ... Path leading to exported spreadsheet
%
% NOTES:
% - 'dim1' refers to the condition folders in your study
%   e.g. if your study has the Conditions 'pre' and 'post' then
%   dim1 = {'pre','post'}
%   e.g. if your study design in more complicated, where two groups (rec and
%   elite) perform 3 tasks (wrist shot, snap shot and slap shot). you would
%   then write dim1 = {'rec\wrist','rec\snap','rec\slap','elite\wrist','elite\snap',
%   'elite\slap'};
%
% - 'dim2' refers to the subjects in your study
%   e.g. if your study has 5 subjects called 'subject01', 'subject02',...'subject05' then
%   enter dim2 = {'subject01', 'subject02',...'subject05'};
% - For between subject designs write all possible subject names in dim2 file
%
% - 'Local Events' are events tagged in each channel.
%   e.g. an event 'max' may exist in each channel that specifies the maximum data point
%   and its index for a given channel.
%
% - 'Global Events' are events tagged in a single channel, but for which we require info in
%   another channel
%   e.g. an event 'heel strike' may exist in a force plate channel. If it is selected as a
%   global event for the HEE marker, this function wil return the value of HEE marker
%   at the index of heel strike.


% Revision History
%
% Created by Philippe C. Dixon 2007 based on 'thebigone' by JJ Loh
%
% Updated by Philippe C. Dixon 2009
% - added extra columns to write to excel to allow more events to be extracted
% - bug fixes for subjects/Conditions
%
% Updated Philippe C. Dixon March 2011
% - varagin style input implemented
%
% Updated Philippe C. Dixon November 2012
% - can process 'events' in the anthro branch of zoosystem
%
% Updated Philippe C. Dixon November 2013
% - bugs fixed in complex designs invloving groups/conditons
% - allows greater flexibility in choosing of condition folders
%
% Updated Philippe C. Dixon June 2015
% - improved condition/subject searching
%
% Updated Philippe C. Dixon Jan 2016
% - dim1 and dim2 excel files replaced by simple cell array of string inputs
% - Full functionality on mac OS platform and platforms without excel installed
%   thanks to xlwrite by Alec de Zegher's (uses java POI)
%   see: http://www.mathworks.com/matlabcentral/fileexchange/38591-xlwrite--generate-xls-x
%        --files-without-excel-on-mac-linux-win
% - Use of excel server can be forced by choosing excelserver = 'on' as an argument.
%   This approach is faster than using java fix thanks to 'xlswrite1 by Matt Swartz
%   see: http://www.mathworks.com/matlabcentral/fileexchange/10465-xlswrite1
% - Additional summary sheet 'info' added. This sheet records processing info about files
% - localevents that are not found in a local event are skipped. Previous
%   version wrote full columns of 999 to spreadsheet. Update speeds up processing
% - 'anthro' events automatically added
%
% Updated by Philippe C. Dixon Feb 2016
% - Bug fix: Anthro data was appearing in eventval.xls as cell {yd}. This caused a problem
%   with eventval2mixedANOVA reading 999 (empty)
% - Clean up for input arguments
% - Additional information on 'info' sheet
% - Bug fix: skips files with missing conditions
%
% Updated by Philippe C. Dixon May 2017
% - error check for forgetting '.' in extension
%
% Updated by Philippe C. Dixon March 2018
% - added 'summary' sheet with all events from all channels grouped
% - not verified with global events
%
% Updated by Philippe C. Dixon Nov 2018
% - increased length of cells for writing to excel (see ecell1, ecell2) to
%   avoid error. Permanent fix still needed
%
% Updated by Philippe C. Dixon Jan 2020
% - reduced the number of calls to excel to speed up processing
% - merged all events by type into three sheets (anthro, global, local)
%
% Updated by Philippe C. Dixon October 2020
% - replaced 'isin' with 'contains'
% - add comments regarding anthro input
%
% Updated by Philippe C. Dixon November 2020
% - improved support for non-numeric anthro events(e.g. 'M', 'F')
%
% Updated by Philippe C. Dixon November 25, 2020
% - optimized code based on input from Vaibhav Shaw. Runs 2.5 times faster
%   on sample data set


% == SETTINGS ==============================================================================
%
fld = '';                                      % if not included in arguments will be empty
ch = '';
localevts = '';                                % manual selection window appears
globalevts = '';                               % manual selection window appears
anthroevts = {'none'};                         % no manual selection window appears
ext = '.xls';                                  % default extension for eventval spreadsheet
s = filesep;                                   % slash direction based on platform
excelserver = 'off';                           % users with excel can speed up process
evalfilename = 'eventval';

for i = 1:2:nargin
    
    switch varargin{i}
        case 'fld'
            fld = varargin{i+1};
        case 'ch'
            ch = varargin{i+1};
        case {'localevts','local','localevents'}
            localevts = varargin{i+1};
        case {'globalevts','global','globalevents'}
            globalevts = varargin{i+1};
        case {'anthroevts','anthro','anthroevents'}
            anthroevts = varargin{i+1};
        case 'dim1'
            conditions = varargin{i+1};
        case 'dim2'
            subjects = varargin{i+1};
        case 'ext'
            ext = varargin{i+1};
        case 'excelserver'
            excelserver = varargin{i+1};
        case 'eventvalfilename'
            evalfilename = varargin{i+1};
    end
end


% == ERROR CHECKING ========================================================================
%
if isempty(fld)
    fld = uigetfolder;
end

if ~strcmp(ext(1),'.')
    ext = ['.',ext];
end

if strcmp(excelserver,'on') && ~strcmp(ext,'.xls')
    disp('when using excel server, extension must be .xls')
    disp(['changing extension type for eventval from ',ext, ' to .xls'])
    ext = '.xls';
elseif strcmp(excelserver,'off') && ~strcmp(ext,'.xls')
    disp('when excel server not used, extension must be .xls')
    disp(['changing extension type for eventval from ',ext, ' to .xls'])
    ext = '.xls';
end

if isin(computer,'MACI')
    disp('Full excel server functionality not available on Mac platforms')
    disp('using java...')
    excelserver = 'off';
    ext = '.xls';
end

% Load excel server or java path
%
if strcmp(excelserver,'on')
    disp('loading excel server')
    Excel = actxserver ('Excel.Application');
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(evalfilename,1);
    ExcelWorkbook.Close(false);
    invoke(Excel.Workbooks,'Open',evalfilename);
else
    disp('Adding Java paths');
    r = which('xlwrite.m');
    pp = fileparts(r);
    jfl = engine('path',pp,'search path','poi_library','extension','.jar');
    
    for i = 1:length(jfl)
        javaaddpath(jfl{i});
    end
    
end

conditions = strrep(conditions,'/',filesep);
conditions = strrep(conditions,'\',filesep);


% == LOADING REQUIRED INFO==================================================================
%

% Set up path for eventval spreadsheet
%
r = strfind(lower(fld),'data');
indx = strfind(fld,filesep);

if isempty(r) && ~isempty(strfind(fld,'example data (processed)')) %#ok<STREMP>
    pth = [fld(1:indx(end)),'Statistics'];
elseif isempty(r)
    warning('study data should be stored in a subfolder with name ''Data''')
    pth = [fld,filesep, 'Statistics'];    % stats folder
else
    pth = [fld(1:r-1),'Statistics'];    % stats folder
end

if ~exist(pth,'dir')
    disp(['Creating folder for stats: ',pth])
    mkdir(pth)
end


% Check if file exists
%
evalFile=[pth,s,evalfilename,ext];    % name of eventval file

if exist(evalFile,'file')
    [~,evalFileShort] = fileparts(evalFile);
    answer=questdlg(['Stats file: ',evalFile,' already exists'], 'overwrite?','Yes','No','No');
    
    if strcmp(answer,'No')
        evalFile=inputdlg('new stats file name','Enter new name',1,{[evalFileShort,'_new',extension(evalFile)]});
        evalFile = [pth,s,evalFile{1}];
    end
    
end

tic  % start calculation timer

% Load zoo files
%
fl = engine('path',fld,'extension','zoo');


% load channels
%
data = zload(fl{2});       % load any file (all same struct)

if isempty(ch)
    ch = setdiff(fieldnames(data),'zoosystem');
    chnames = listdlg('liststring',ch,'name','choose channels','ListSize',[300 300]);
    chnames = ch(chnames);
else
    chnames = ch;
end


% load local events
%
if isempty(localevts)
    lev = [];
    for i = 1:length(chnames)
        plate = fieldnames(data.(chnames{i}).event);
        lev = [lev; plate];                             %#ok<AGROW>
    end
    lev = unique(lev);
    
    if isempty(lev)
        localevtnames = '';
    else
        localevtnames = listdlg('liststring',lev,'name','select local events','ListSize',[300 300]);
        localevtnames = lev(localevtnames);
    end
    
elseif ismember('none',localevts)
    localevtnames = {};
else
    localevtnames = localevts;
end

if ~iscell(localevtnames)
    localevtnames = {localevtnames};
end

% load global events
%
if isempty(globalevts)
    gev = [];
    chn = setdiff(fieldnames(data),'zoosystem');
    
    for i = 1:length(chn)
        plate = fieldnames(data.(chn{i}).event);
        gev = [gev; plate];                              %#ok<AGROW>
    end
    
    gev = unique(gev);
    
    globalevtnames = listdlg('liststring',gev,'name','global events','ListSize',[300 300]);
    globalevtnames = gev(globalevtnames);
    
elseif ismember('none',globalevts)
    globalevtnames = {};
    
else
    globalevtnames = globalevts;
end

if ~iscell(globalevtnames)
    globalevtnames = {globalevtnames};
end


% Load anthro events
%
if ismember('none',anthroevts)
    anthroevtnames = {};
elseif isempty(anthroevts)
    aev = fieldnames(data.zoosystem.Anthro);
    anthroevtnames = listdlg('liststring',aev,'name','anthro events','ListSize',[300 300]);
    anthroevtnames = aev(anthroevtnames);
else
    anthroevtnames = anthroevts;
end

if ~iscell(anthroevtnames)
    anthroevtnames = {anthroevtnames};
end


% == EXTRACT DATA FROM CHANNELS AT REQUIRED EVENTS =========================================
%


Global_Block=[];
Local_Block=[];
Anthro_Block=[];
sheet_info = [];
Grun=1;
Arun=1;
Lrun=1;
for i = 1:length(fl)
    batchdisp(fl{i},'Extracting data to spreadsheet')
    
    % Load zoo file and extract filename
    %
    data = zload(fl{i});
    [~,fname] = fileparts(fl{i});
    
    % write additional meta-info
    %
    if i==1
        info = {'Summary info related to data';
            ' ';
            'folder processed: ';
            fld;
            'date processed: ';
            date;
            'missing events tagged as 999';
            'Processing steps'};
        
        if isfield(data.zoosystem, 'Processing')
            process = data.zoosystem.Processing;
        else
            process = 'process information not available';
        end
    end
    
    % find subject code
    %
    check = true;
    count = 1;
    while check
        if contains(fl{i},subjects{count})
            subject = subjects{count};
            check = false;
        else
            count=count+1;
        end
    end
    
    % find subject condition
    %
    fl_temp = strrep(fl{i},[subject,s],'');
    check = true;
    count = 1;
    while check
        if contains(fl_temp,conditions{count})
            con = conditions{count};
            check = false;
        else
            count = count+1;
        end
        
        if count > length(conditions)
            disp('no match for conditions, skipping file')
            check = false;
        end
    end
    
    if count > length(conditions)
        continue
    end
    
  
    
    % Check subject conditon and name
    %
    if ~ismember(con,conditions)
        error(['condition ',con, ' not in list of conditions'])
    end
    
    if ~ismember(subject,subjects)
        error(['subject ',subject, ' not in list of subjects'])
    end
    
    global_offset = 1;
    local_offset = 1;
    anthro_offset = 1;
    sheet_header = {'SUBJECT', 'CONDITION', 'TRIAL', '', '', 'EVENT'};
    
    for j = 1:length(chnames)               % set the basic structure of spreadsheet
        
        chname = chnames{j};
        
        if length(chname)>31
            disp(['channel ',chname ,'contains too many characters: ','reducing'])
            chname = chname(1:31);
        end
        
        if j==1
            sheet_info = [sheet_info;{subject, con, fname}];
        end
        
        % write global events
        %
        for g = 1:length(globalevtnames)
            evt = findfield(data,globalevtnames{g});          % 1st found is right one
            
            if isempty(evt)
                error(['missing ',globalevtnames{g},' event']);
            end
            
            xd = evt(1);
            
            if xd == 999
                yd = 999;
            else
                yd= data.(chnames{j}).line(evt(1));
            end
            
            if isnan(yd)
                yd=999;
                disp(' ')
                disp(['the global event ',globalevtnames{g}, ' corresponds to a NaN in the local ch ',chnames{j}])
                disp('replacing your event with NaNs')
                disp(' ')
            end
            
            if i == 1
                global_block = {[chname, '_', globalevtnames{g}], ''; 'xdata', 'ydata'};
                Global_Block=[Global_Block,global_block];
            end
            
            global_offset = global_offset+1;
            if ~isempty(xd)
                Global.(cell2mat({chname, '_', globalevtnames{g}}))(Grun,:)=[xd,yd];
                if j==length(chnames)
                    if g ==length(globalevtnames)
                        Grun=Grun+1;
                    end
                end
            end
        end
        
        if isempty(g)
            g = 0;
        end
        
        % Write local events
        %
        offset = length(globalevtnames);
        
        for n = 1:length(localevtnames)            %LOCAL EVENTS: All channels should have this event
            
            if isfield(data.(chnames{j}).event,localevtnames{n})
                evt = data.(chnames{j}).event.(localevtnames{n});
                xd = evt(1);
                yd = evt(2);
                
                if isnan(yd)
                    yd =999;
                end
                
                if i == 1
                    local_block = {[chname, '_', localevtnames{n}], ''; 'xdata', 'ydata'};
                    Local_Block=[Local_Block,local_block];
                end
                
                if ~isempty(yd)
                    Local.(cell2mat({chname, '_', localevtnames{n}}))(Lrun,:)=[xd,yd];
                    if j==length(chnames)
                        if n==length(localevtnames)
                            Lrun=Lrun+1;
                        end
                    end
                end
                local_offset = local_offset+1;
                
            else
                disp(['no event ',localevtnames{n},' in channel ',chnames{j}])
                offset = offset-1;
                if j==length(chnames)
                    if n==length(localevtnames)
                        Lrun=Lrun+1;
                    end
                end
            end
        end
    end
    
    % Write Anthro data
    %
    if ~isempty(anthroevtnames)
        
        for k = 1:length(anthroevtnames)
            
            evt = findfield(data,anthroevtnames{k});          % 1st found is right one
            
            if isempty(evt)
                disp(['missing ',anthroevtnames{k},' event']);
                evt = 999;
            end
            
            xd = 1;
            yd = evt;
            
            if iscell(anthroevtnames)
                canthroevtnames = anthroevtnames{k};
            else
                canthroevtnames = anthroevtnames(k);
            end
            
            if i == 1
                anthro_block = {canthroevtnames, ''; 'xdata', 'ydata'};
                Anthro_Block=[Anthro_Block,anthro_block];
            end
            
            if ~isempty(yd)
                anthro.(canthroevtnames)(Arun,:)=[xd,yd];
                if k==length(anthroevtnames)
                    Arun=Arun+1;
                end
            end
            anthro_offset = anthro_offset+1;
        end
    end
end


% write basic info
xls_write(evalFile,info,'info','A1', excelserver)
xls_write(evalFile,process,'info','A9', excelserver)

% write anthro events if they exist
if~isempty(anthroevtnames)
    anthroall = table2array(struct2table(anthro));
    xls_write(evalFile,sheet_header,'anthro','A1', excelserver)
    xls_write(evalFile,sheet_info,'anthro','A4', excelserver)
    xls_write(evalFile,Anthro_Block,'anthro','D2', excelserver)
    xls_write(evalFile,anthroall,'anthro','D4', excelserver)
end

% write global events if they exist
if~isempty(globalevtnames)
    globalall = table2array(struct2table(Global));
    xls_write(evalFile,sheet_header,'global','A1', excelserver)
    xls_write(evalFile,sheet_info,'global','A4', excelserver)
    xls_write(evalFile,Global_Block,'global','D2', excelserver)
    xls_write(evalFile,globalall,'global','D4', excelserver)
end

% write local events if they exist
if~isempty(localevtnames)
    localall = table2array(struct2table(Local));
    xls_write(evalFile,sheet_header,'local','A1', excelserver)
    xls_write(evalFile,sheet_info,'local','A4', excelserver)
    xls_write(evalFile,Local_Block,'local','D2', excelserver)
    xls_write(evalFile,localall,'local','D4', excelserver)
end


disp(['eventval completed in ', num2str(toc), ' seconds'])
disp(['events saved to ', evalFile])


function xls_write(file_name,sheet_data,sheet_name, cell_name, excelserver)

% xls_write is an internal util allowing to switch between excel writers
% based on sysrtem

if nargin == 4
    
    if isin(computer,'MACI')
        excelserver = 'off';
    end
end

if strcmp(excelserver,'on')
    xlswrite1(file_name,sheet_data,sheet_name, cell_name);
else
    xlwrite(file_name,sheet_data,sheet_name, cell_name);
end 



