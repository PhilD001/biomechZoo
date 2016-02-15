function evalFile = eventval(varargin)
%
% eventval(varargin) will transfer the values of all channels at given events to
% a spreadsheet for further analysis
%
% ARGUMENTS
% 'fld'          ... path to data folder as string
% 'dim1'         ... list of conditions as cell array of strings
% 'dim2'         ... list of subjects in study as cell array of strings
% 'ch'           ... list of channels as cell array of strings
% 'localevts'    ... list of local events as cell array of strings
% 'globalevts'   ... list of global events as cell array of strings
% 'ext'          ... Spreadsheet file type .xls, .xlsx, and .csv are possible.
%                    Default is .xls
% 'excelserver'  ... Choice to use excel server
%
% RETURNS
% evalFile       ... Path leading to exported spreadsheet
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
% with eventval2mixedANOVA reading 999 (empty)


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.


tic  % start calculation timer

% == SETTINGS ==============================================================================
%
fld = '';                                      % if not included in arguments will be empty
ch = '';
localevts = '';
globalevts = '';
anthroevts = '';
ext = '.xls';                                  % default extension for eventval spreadsheet
s = filesep;                                   % slash direction based on platform
excelserver = 'off';                           % users with excel server can speed up process

for i = 1:2:nargin
    
    switch varargin{i}
        case 'fld'
            fld = varargin{i+1};
        case 'ch'
            ch = varargin{i+1};
        case {'localevts','local'}
            localevts = varargin{i+1};
        case {'globalevts','global'}
            globalevts = varargin{i+1};
        case {'anthroevts','anthro'}
            anthroevts = varargin{i+1};
        case 'dim1'
            conditions = varargin{i+1};
        case 'dim2'
            subjects = varargin{i+1};
        case 'ext'
            ext = varargin{i+1};
        case 'excelserver'
            excelserver = varargin{i+1};
            
    end
end


% == ERROR CHECKING ========================================================================
%
if isempty(fld)
    fld = uigetfolder;
end

if strcmp(excelserver,'on') && ~strcmp(ext,'.xls')
    disp('when using excel server, extension must be .xls')
    disp(['changing extension type for eventval from ',ext, ' to .xls'])
    ext = '.xls';
end

if strcmp(excelserver,'on') && isin(computer,'MACI')
    disp('Full excel server functionality not available on Mac platforms')
    disp('switching to java...')
    excelserver = 'off';
end

conditions = strrep(conditions,'/',filesep);
conditions = strrep(conditions,'\',filesep);


% == LOADING REQUIRED INFO==================================================================
%

% Set up path for eventval spreadsheet
%
r = strfind(fld,'Data');
pth = [fld(1:r-1),'Statistics'];    % stats folder
if ~exist(pth,'dir')
    disp(['Creating folder for stats: ',pth])
    mkdir(pth)
end
evalFile=[pth,s,'eventval',ext];    % name of eventval file

% Load excel server or java path
%
if strcmp(excelserver,'on')
    disp('loading excel server')
    Excel = actxserver ('Excel.Application');
    
    if exist(evalFile,'file')
        error('excel file already exists in current location')
    else
        ExcelWorkbook = Excel.workbooks.Add;
        ExcelWorkbook.SaveAs(evalFile,1);
        ExcelWorkbook.Close(false);
    end
    invoke(Excel.Workbooks,'Open',evalFile);
    
else
    display('Adding Java paths');
    r = which('xlwrite.m');
    p = fileparts(r);
    jfl = engine('path',p,'search path','poi_library','extension','.jar');
    
    for i = 1:length(jfl)
        javaaddpath(jfl{i});
    end
end


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
        lev = [lev; plate];
    end
    
    if isempty(lev)
        localevtnames = '';
    else
        localevtnames = listdlg('liststring',lev,'name','local events','ListSize',[300 300]);
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
    for i = 1:length(ch)
        plate = fieldnames(data.(ch{i}).event);
        gev = [gev; plate];
    end
    
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
if isempty(anthroevts) && isfield(data.zoosystem,'Anthro')
    aev = fieldnames(data.zoosystem.Anthro);
    anthroevtnames = listdlg('liststring',aev,'name','anthro events','ListSize',[300 300]);
    anthroevtnames = aev(anthroevtnames);
    
elseif ismember('none',anthroevts)
    anthroevtnames = {};
    
else
    anthroevtnames = anthroevts;
end

if ~iscell(anthroevtnames)
    anthroevtnames = {anthroevtnames};
end


% == EXTRACT DATA FROM CHANNELS AT REQUIRED EVENTS =========================================
%

% List of cells for excel
%
ecell1 = {'D','F','H','J','L','N','P','R','T','V','X','Z','AB','AD','AF','AH','AJ','AL','AN',...
    'AP','AR','AT','AV','AX','AZ','BB','BD','BF','BH','BJ','BL','BN','BP','BR','BT','BV',...
    'BX','BZ','CB','CD','CF','CH','CJ','CL','CN','CP','CR','CT','CV','CX','CZ'};
ecell2 = {'E','G','I','K','M','O','Q','S','U','W','Y','AA','AC','AE','AG','AI','AK','AM','AO',...
    'AQ','AS','AU','AW','AY','BA','BC','BE','BG','BI','BK','BM','BO','BQ','BS','BU','BW',...
    'BY','CA','CC','CE','CG','CI','CK','CM','CO','CQ','CS','CU','CW','CY'};

for i = 1:length(fl)
    disp(['Extracting data to spreadsheet for: ',fl{i}])
    
    % Load zoo file and extract filename
    %
    data = zload(fl{i});
    [~,fname] = fileparts(fl{i});
    
    % find subject code
    %
    for j = 1:length(subjects)
        if isin(fl{i},subjects{j})
            subject = subjects{j};
        end
    end
    
    % find subject condition
    %
    fl_temp = strrep(fl{i},[subject,s],'');
    for j = 1:length(conditions)
        if isin(fl_temp,conditions{j})
            con = conditions{j};
        end
        
    end
    
    % write additional meta-info
    %
    if i==1
        process = data.zoosystem.processing;
        
        if strcmp(excelserver,'on')
            xlswrite1(evalFile,{'Summary info related to data'},'info','A1');
            xlswrite1(evalFile,{'folder processed: '},'info','A3');
            xlswrite1(evalFile,{fld},'info','A4');
            xlswrite1(evalFile,{'date processed: '},'info','A6');
            xlswrite1(evalFile,{date},'info','A7');
            xlswrite1(evalFile,{'Processing steps'},'info','A9');
            xlswrite1(evalFile,process,'info','A10');
        else
            xlwrite(evalFile,{'Summary info related to data'},'info','A1');
            xlwrite(evalFile,{'folder processed: '},'info','A3');
            xlwrite(evalFile,{fld},'info','A4');
            xlwrite(evalFile,{'date processed: '},'info','A6');
            xlwrite(evalFile,{date},'info','A7');
            xlwrite(evalFile,{'Processing steps'},'info','A9');
            xlwrite(evalFile,process,'info','A10');
        end
    end
    
    % Check subject conditon and name
    %
    if ~ismember(con,conditions)
        error(['condition ',con, ' not in list of conditions'])
    end
    
    if ~ismember(subject,subjects)
        error(['subject ',subject, ' not in list of subjects'])
    end
    
    for j = 1:length(chnames)               % set the basic structure of spreadsheet
        initialpos = 0;
        chname = chnames{j};
        
        if length(chname)>31
            disp(['channel ',chname ,'contains too manu characters: ','reducing'])
            chname = chname(1:31);
        end
        
        if strcmp(excelserver,'on')
            xlswrite1(evalFile,{'SUBJECT'},chname,'A1');
            xlswrite1(evalFile,{'CONDITION'},chname,'B1');
            xlswrite1(evalFile,{'TRIAL'},chname,'C1');
            xlswrite1(evalFile,{'EVENT'},chname,'F1');
            xlswrite1(evalFile,{fname},chname,['C',num2str(initialpos+3+i)]);
            xlswrite1(evalFile,{subject},chname,['A',num2str(initialpos+3+i)]);
            xlswrite1(evalFile,{con},chname,['B',num2str(initialpos+3+i)]);
        else
            xlwrite(evalFile,{'SUBJECT'},chname,'A1');
            xlwrite(evalFile,{'CONDITION'},chname,'B1');
            xlwrite(evalFile,{'TRIAL'},chname,'C1');
            xlwrite(evalFile,{'EVENT'},chname,'F1');
            xlwrite(evalFile,{fname},chname,['C',num2str(initialpos+3+i)]);
            xlwrite(evalFile,{subject},chname,['A',num2str(initialpos+3+i)]);
            xlwrite(evalFile,{con},chname,['B',num2str(initialpos+3+i)]);
        end                               % create headers
        
        % write global events
        %
        for k = 1:length(globalevtnames)
            evt = findfield(data,globalevtnames{k});          % 1st found is right one
            
            if isempty(evt)
                error(['missing ',globalevtnames{k},' event']);
            end
            
            xd = evt(1);
            yd= data.(chnames{j}).line(evt(1));
            
            if isnan(yd)
                yd=999;
                disp(' ')
                disp(['the global event ',globalevtnames{k}, ' corresponds to a NaN in the local ch ',chnames{j}])
                disp('replacing your event with NaNs')
                disp(' ')
            end
            
            if strcmp(excelserver,'on')
                xlswrite1(evalFile,{globalevtnames(k)},chname,[ecell1{k},'2']);
                xlswrite1(evalFile,{'xdata'},chname,[ecell1{k},'3']);
                xlswrite1(evalFile,{'ydata'},chname,[ecell2{k},'3']);
                xlswrite1(evalFile,xd,chname,[ecell1{k},num2str(3+i)]);
                xlswrite1(evalFile,yd,chname,[ecell2{k},num2str(3+i)]);
            else
                xlwrite(evalFile,{globalevtnames(k)},chname,[ecell1{k},'2']);
                xlwrite(evalFile,{'xdata'},chname,[ecell1{k},'3']);
                xlwrite(evalFile,{'ydata'},chname,[ecell2{k},'3']);
                xlwrite(evalFile,xd,chname,[ecell1{k},num2str(3+i)]);
                xlwrite(evalFile,yd,chname,[ecell2{k},num2str(3+i)]);
            end
            
            
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
                
                if strcmp(excelserver,'on')
                    xlswrite1(evalFile,{localevtnames{n}},chname,[ecell1{n+offset},'2']);
                    xlswrite1(evalFile,{'xdata'},chname,[ecell1{n+offset},'3']);
                    xlswrite1(evalFile,{'ydata'},chname,[ecell2{n+offset},'3']);
                    xlswrite1(evalFile,xd,chname,[ecell1{n+offset},num2str(3+i)]);
                    xlswrite1(evalFile,yd,chname,[ecell2{n+offset},num2str(3+i)]);
                else
                    xlwrite(evalFile,{localevtnames{n}},chname,[ecell1{n+offset},'2']);
                    xlwrite(evalFile,{'xdata'},chname,[ecell1{n+offset},'3']);
                    xlwrite(evalFile,{'ydata'},chname,[ecell2{n+offset},'3']);
                    xlwrite(evalFile,xd,chname,[ecell1{n+offset},num2str(3+i)]);
                    xlwrite(evalFile,yd,chname,[ecell2{n+offset},num2str(3+i)]);
                    
                end
                
            else
                disp(['no event ',localevtnames{n},' in channel ',chnames{j}])
                
                offset = offset-1;
                
                
            end
            
        end
        
    end
    
    % Write Anthro data
    %
    if ~isempty(anthroevtnames)
        initialpos = 0;
        chname = 'Anthro';
        
        if strcmp(excelserver,'on')
            xlswrite1(evalFile,{'SUBJECT'},chname,'A1');
            xlswrite1(evalFile,{'CONDITION'},chname,'B1');
            xlswrite1(evalFile,{'TRIAL'},chname,'C1');
            xlswrite1(evalFile,{'EVENT'},chname,'F1');
            xlswrite1(evalFile,{fname},chname,['C',num2str(initialpos+3+i)]);
            xlswrite1(evalFile,{subject},chname,['A',num2str(initialpos+3+i)]);
            xlswrite1(evalFile,{con},chname,['B',num2str(initialpos+3+i)]);
        else
            xlwrite(evalFile,{'SUBJECT'},chname,'A1');
            xlwrite(evalFile,{'CONDITION'},chname,'B1');
            xlwrite(evalFile,{'TRIAL'},chname,'C1');
            xlwrite(evalFile,{'EVENT'},chname,'F1');
            xlwrite(evalFile,{fname},chname,['C',num2str(initialpos+3+i)]);
            xlwrite(evalFile,{subject},chname,['A',num2str(initialpos+3+i)]);
            xlwrite(evalFile,{con},chname,['B',num2str(initialpos+3+i)]);
        end
        
        for k = 1:length(anthroevtnames)
            
            evt = findfield(data,anthroevtnames{k});          % 1st found is right one
            
            if isempty(evt)
                error(['missing ',anthroevtnames{k},' event']);
            end
            
            xd = 1;
            yd = evt;
            
            if ~isnumeric(yd)
                yd = 999;
            end
            
            if strcmp(excelserver,'on')
                xlswrite1(evalFile,{anthroevtnames(k)},chname,[ecell1{k},'2']);
                xlswrite1(evalFile,{'xdata'},chname,[ecell1{k},'3']);
                xlswrite1(evalFile,{'ydata'},chname,[ecell2{k},'3']);
                xlswrite1(evalFile,xd,chname,[ecell1{k},num2str(3+i)]);
                xlswrite1(evalFile,yd,chname,[ecell2{k},num2str(3+i)]); % edit {yd}
            else
                xlwrite(evalFile,{anthroevtnames(k)},chname,[ecell1{k},'2']);
                xlwrite(evalFile,{'xdata'},chname,[ecell1{k},'3']);
                xlwrite(evalFile,{'ydata'},chname,[ecell2{k},'3']);
                xlwrite(evalFile,xd,chname,[ecell1{k},num2str(3+i)]);
                xlwrite(evalFile,yd,chname,[ecell2{k},num2str(3+i)]); % edit {yd}
            end
            
        end
        
    end
    
end



% == CLOSE EXCEL SERVER (if open) ==========================================================
%
if strcmp(excelserver,'on')
    invoke(Excel.ActiveWorkbook,'Save');
    Excel.Quit
    Excel.delete
    clear Excel
end

% == SHOW END OF PROGRAM ===================================================================
%
disp(' ')
disp('****************************')
disp('Finished running data for: ')
disp(' ')
disp(evalFile)
disp(' ')
toc
disp('****************************')



