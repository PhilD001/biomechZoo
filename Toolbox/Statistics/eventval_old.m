function eventval(varargin)
%
% eventval(varargin) will transfer the values of all channels at given events to
% an excel sheet for inspection. Careful setup must be followed
%
% ARGUMENTS
% 'fld'          ... path to data folder as string
% 'ch'           ... list of channels as cell array of strings
% 'localevts'    ... list of local events as cell array of strings
% 'globalevts'   ... list of global events as cell array of strings
% 'subprefix'    ... subject code prefix as string. e.g. 'subject','P'
%
%
% PREREQUISITES:
%
% 1-Create an excel file names 'dim1.xls' which contains the Conditions in
%   your study
%
%   ex. if your study has the Conditions 'pre' and 'post' enter 'pre' and
%   'post' (no quotes) in cells A1 and A2 of your excel sheet.
%   ex. if your study design in more complicated, where two groups (rec and
%   elite) perform 3 tasks (wrist shot, snap shot and slap shot). you would
%   then write in column A the following rec\wrist, rec\snap, rec\slap,
%   elite\wrist, elite\snap, elite\slap
%
%   NOTE: -your Condition folder names and dim1 names must be identical
%         - your structure should be group/subject/condition
%           e.g   rec/subject01/wrist
%                              /snap
%                              /slap
%                     subject02/wrist
%                               /...
%                  elite/subject03/wrist
%                               /...
%
%
% 2-create an excel file names 'dim2.xls' which contains the names of the subjects in
%   your study
%   ex. if your study has 5 subjects called 'subject01', 'subject02',...'subject05' then enter
%   'subject01', 'subject02',...'subject05'(no quotes) in cells A1,A2,...A5 of your excel sheet.
%
%   NOTES: - Your subject folder names and dim2 names must be identical.
%          - Do not use spaces or capitals in your subject folders.
%          - Always name your subjects beginning with subject01,...
%          - for between subject designs write all possible subject names
%            in dim file
%
% 3-create a blank excel file to write data to. Name it as you wish.
%
%
% BACKGROUND INFO:
%
% This function will ask you to select the events you are interested in
% extracting. Following the zoosystem, there are two kinds of events to
% choose from.
%
% 'Local Events' are events tagged in each channel. ex. an event 'max' may
% exist in each channel that specifies the maximum data point and its index for a given
% channel.
%
% 'Global Events' are events tagged in a single channel, but for which we
% require info in all channels. ex. an event 'heel strike' may exist in a
% force plate channel. If it is selected as a global event, this function
% wil return the value of every channel at the index of heel strike.


% Revision History
%
% Created by Philippe C. Dixon 2007 based on 'thebigone' by JJ Loh
%
% Updated by Philippe C. Dixon 2009
% - added extra columns to write to excel to allow more events to be extracted
% - bug fixes for subjects/Conditions
%
% Updated by Philippe C. Dixon January 2010
% - function speed has been increased by using 'xlswrite1.m'
%   for more details, please see: http://www.mathworks.com/matlabcentral/fileexchange/10465-xlswrite1
%
% Updated by Philippe C. Dixon August 2010
% - added error checking
%
% Updated March 2011
% - eventval attempts to find your statistics folder. If it cannot, user will be prompted to select it
% - varagin style input implemented .
%
% Updated November 2012
% - can process 'events' in the anthro branch of zoosystem
%
% Updated November 2013
% - bugs fixed in complex designs invloving groups/conditons
% - allows greater flexibility in choosing of condition folders
%
% Updated June 2015
% - improved searching location of stats folder
%  - improved condition/subject seraching


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

%============PART 1: DEFAULT SETTINGS DO NOT EDIT============
%
fld = '';
ch = '';
localevts = '';
globalevts = '';

%===========PART 2: CHANGE DEFAULTS BASED ON USER INPUTS============
%
%
for i = 1:2:nargin
    
    switch varargin{i}
        case 'fld'
            fld = varargin{i+1};
        case 'ch'
            ch = varargin{i+1};
        case 'localevts'
            localevts = varargin{i+1};
        case 'globalevts'
            globalevts = varargin{i+1};
     
    end
end


%============PART 3: LOADING REQUIRED INFO=================
%
%

% a) Load folder
%
if isempty(fld)
    fld = uigetfolder('select root of data');
    cd(fld);
end

fl = engine('path',fld,'extension','zoo');


% b) load channels and events------------------
%
data = load(fl{2},'-mat');
data = data.data;


if isempty(ch)
    ch = setdiff(fieldnames(data),'zoosystem');
    chnames = listdlg('liststring',ch,'name','choose channels','ListSize',[300 300]);
    chnames = ch(chnames);
else
    chnames = ch;
end

if isempty(localevts)
    lev = [];
    for i = 1:length(chnames)
        plate = fieldnames(data.(chnames{i}).event);
        lev = [lev; plate];
    end
    
    if isempty(lev)
        localevtnames = '';
    else
        localevtnames = listdlg('liststring',lev,'name','choose local events','ListSize',[300 300]);
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

if isempty(globalevts)
    gev = [];
    for i = 1:length(ch)
        plate = fieldnames(data.(ch{i}).event);
        gev = [gev; plate];
    end
    
    globalevtnames = listdlg('liststring',gev,'name','choose global events','ListSize',[300 300]);
    globalevtnames = gev(globalevtnames);
    
    
elseif ismember('none',globalevts)
    globalevtnames = {};
    
else
    globalevtnames = globalevts;
end


if ~iscell(globalevtnames)
    globalevtnames = {globalevtnames};
end


%c) find name of subjects, Conditions----------
%
%
% s = slash;
% indx = strfind(fld,s);
% subfld1 = [fld(1:indx(end)),'Statistics']; % 1st try
% subfld2 = [fld(1:indx(end-1)),'Statistics']; % 2nd try
% subfld3 = [fld(1:indx(end-2)),'Statistics']; % 2nd try

s = slash;
indx = strfind(fld,s);
subfld = fld(1:indx(end-1)); 

dim_fl = engine('fld',subfld,'search file','dim1');

if isempty(dim_fl)
    error('you must create your dim files before running program')
else
    [sfld,f] =  fileparts(dim_fl{1});
end

% 
% if exist(subfld1,'dir')==7
%     sfld = subfld1;
% elseif exist(subfld2,'dir')==7
%     sfld = subfld2;
% elseif exist(subfld3,'dir')==7
%     sfld = subfld3;
% else
%     sfld = uigetfolder('open stats folder');
% end

% d) Open Excel Server----------
%
%
Excel = actxserver ('Excel.Application');
File=[sfld,s,'eventval.xls'];
if ~exist(File,'file')
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(File,1);
    ExcelWorkbook.Close(false);
    
else
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs('eventval2.xls',1);
    ExcelWorkbook.Close(false);
end
invoke(Excel.Workbooks,'Open',File);


% e) search for correct xls files
%
%
xfl =  engine('path',sfld,'extension','xls');

cd(sfld)
xlsfile = '';
d1count=0;
d2count=0;

for i = 1:length(xfl)
    
    if ~isempty(strfind(xfl{i},'dim1.xls'))
        [~,Conditions] = xlsread(xfl{i});
        disp(['searching for dim1.xls file located at ',xfl{i}]);
        d1count = 1;
        
        if~isempty(find(ismember(Conditions,'subject01')==1)) %#ok<*EFIND>
            disp('you have put subject names in dim1, this is reserved for Conditions. Please correct and rerun eventval')
            disp(' ')
            disp('*** program terminating***')
            return
        end
        
    end
    
    if ~isempty(strfind(xfl{i},'dim2.xls'))
        [~,subjects] = xlsread(xfl{i});
        disp(['searching for dim2.xls file located at ',xfl{i}]);
        d2count = 1;
    end
    
    if ~isempty(strfind(xfl{i},'eventval.xls'))
        xlsfile = xfl{i};
    end
    
    
end

% f) Error checking---
%
%
if d1count==0
    disp(' ')
    disp('you do not have a dim1 excel file or it is in wrong format (.xlsx)')
    disp('exiting eventval...')
    return
end

if d2count==0
    disp(' ')
    disp('you do not have a dim2 excel file or it is in wrong format (.xlsx)')
    disp('exiting eventval...')
    return
end




%=========PART 4: EXTRACT DATA FROM CHANNELS AT REQUIRED EVENTS===============
%

% List of cells for excel
%
ecell1 = {'D','F','H','J','L','N','P','R','T','V','X','Z','AB','AD','AF','AH','AJ','AL','AN','AP','AR','AT','AV','AX','AZ','BB','BD','BF','BH','BJ','BL','BN','BP','BR','BT','BV','BX','BZ','CB','CD','CF','CH','CJ','CL','CN','CP','CR','CT','CV','CX','CZ'};
ecell2 = {'E','G','I','K','M','O','Q','S','U','W','Y','AA','AC','AE','AG','AI','AK','AM','AO','AQ','AS','AU','AW','AY','BA','BC','BE','BG','BI','BK','BM','BO','BQ','BS','BU','BW','BY','CA','CC','CE','CG','CI','CK','CM','CO','CQ','CS','CU','CW','CY'}; 


for i = 1:length(fl)
    
    disp(['Extracting data to excel from :',fl{i}])
    
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
    fl_temp = strrep(fl{i},[slash,subject],'');
    for j = 1:length(Conditions)
    
        if isin(fl_temp,Conditions{j})
        con = Conditions{j};
        end
        
    end
        
        
    % Check subject conditon and name
    %
    if ~ismember(con,Conditions)
        error(['condition ',con, ' not in list of conditions'])
    end
    
    if ~ismember(subject,subjects)
        error(['subject ',subject, ' not in list of subjects'])
    end
    
    
    
    for j = 1:length(chnames)  %set the basic structure of xls sheet
        
        initialpos = 0;
        chname = chnames{j};
        
        if length(chname)>31
            disp(['channel ',chname ,'contains too manu characters: ','reducing'])
            chname = chname(1:31);
        end
        
        xlswrite1(xlsfile,{'SUBJECT'},chname,'A1');
        xlswrite1(xlsfile,{'CONDITION'},chname,'B1');
        xlswrite1(xlsfile,{'TRIAL'},chname,'C1');
        xlswrite1(xlsfile,{'EVENT'},chname,'F1');
        xlswrite1(xlsfile,{fname},chname,['C',num2str(initialpos+3+i)]);
        xlswrite1(xlsfile,{subject},chname,['A',num2str(initialpos+3+i)]);
        xlswrite1(xlsfile,{con},chname,['B',num2str(initialpos+3+i)]);
        
        
        for k = 1:length(globalevtnames)
            evt = findfield(data,globalevtnames{k});     %GLOBAL EVENT: First one found in the right one
            
            if isempty(evt)
                error(['missing ',globalevtnames{k},' event']);
            end
            
           
            
            xd = evt(1);           
            yd= data.(chnames{j}).line(evt(1));
            
            if isnan(yd)
                yd=999;
                disp(' ')
                disp(['the global event ',globalevtnames{k}, ' corresponds to a NaN value in the local channel ',chnames{j}])
                disp('replacing your event with NaNs')
                disp(' ')
            end
            
            xlswrite1(xlsfile,{globalevtnames{k}},chname,[ecell1{k},'2']);
            xlswrite1(xlsfile,{'xdata'},chname,[ecell1{k},'3']);
            xlswrite1(xlsfile,{'ydata'},chname,[ecell2{k},'3']);
            
            xlswrite1(xlsfile,xd,chname,[ecell1{k},num2str(3+i)]);
            xlswrite1(xlsfile,yd,chname,[ecell2{k},num2str(3+i)]);
            
        end
        
        for n = 1:length(localevtnames)            %LOCAL EVENTS: All channels should have this event
            
            offset = length(globalevtnames);
            
            
            
            if isfield(data.zoosystem.Anthro,localevtnames{n})
                
                evt = data.zoosystem.Anthro.(localevtnames{n});
                
                if ~isnumeric(evt)
                    evt = str2double(evt);
                end
                
                evt = [1 evt 0];
                
                xd = evt(1);
                yd = evt(2);
                
            elseif isfield(data.(chnames{j}).event,localevtnames{n})
                
                evt = data.(chnames{j}).event.(localevtnames{n});
                xd = evt(1);
                yd = evt(2);
                
                
                
            else
                
                disp(['no event ',localevtnames{n},' in channel ',chnames{j}])
                xd = 999;
                yd = 999;
            end
            
            if isnan(yd)
                yd =999;
            end
            
            xlswrite1(xlsfile,{localevtnames{n}},chname,[ecell1{n+offset},'2']);
            xlswrite1(xlsfile,{'xdata'},chname,[ecell1{n+offset},'3']);
            xlswrite1(xlsfile,{'ydata'},chname,[ecell2{n+offset},'3']);
            
            xlswrite1(xlsfile,xd,chname,[ecell1{n+offset},num2str(3+i)]);
            xlswrite1(xlsfile,yd,chname,[ecell2{n+offset},num2str(3+i)]);
        end
        
    end
    
end


%----------CLOSE EXCEL SERVER----------

invoke(Excel.ActiveWorkbook,'Save');
Excel.Quit
Excel.delete
clear Excel


%---SHOW END OF PROGRAM-------

disp(' ')
disp('****************************')
disp('Finished running data for: ')
disp(' ')
disp(xlsfile)
toc
disp('****************************')




%============EMBEDDED FUNCTIONS ============

function [ch,ev] = listchannel_event(fl)
t = load(fl,'-mat');
data = t.data;
ev = {};
ch = fieldnames(data);
ch = setdiff(ch,{'zoosystem'});
for i = 1:length(ch)
    vl = getfield(data,ch{i});
    if isstruct(vl)
        if isstruct(vl.event);
            ev = union(ev,fieldnames(vl.event));
        end
    end
end


