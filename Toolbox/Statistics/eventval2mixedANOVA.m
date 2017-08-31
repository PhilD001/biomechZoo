function eventval2mixedANOVA(varargin)

% eventval2mixedANOVA (varargin) will output data to a spreadsheet for mixed ANOVA 
% analysis in third party software
%
% ARGUMENTS
% 'eventvalFile'   ...  File path to spreadsheet created by eventval.m
% 'excelserver'    ...  Choice to use excel server. Default is 'off'
%
% NOTES
% - Data must have been run through eventval.m
% - The format of the 'all data' sheet summarizes all data for analysis in SPSS. The
%   format may also be useful for other programs
% - excel server has been causing some problems in newer versions of
%   Matlab. If you experience this error, try using with excelserver set to 'off'



% Revision History
%
% Created by Philippe C. Dixon March 2010
%
% Updated by Philippe C. Dixon August 2012
% - Fixed bug when header name is too long
%
% Updated by Philippe C. Dixon October 2014
% - Added summary sheet called 'alldata'
%
% Updated by Philippe C. Dixon Jan 2016
% - full functionality on mac OS platform and platforms without excel installed
%   thanks to xlwrite by Alec de Zegher's (uses java POI)
%   see: http://www.mathworks.com/matlabcentral/fileexchange/38591-xlwrite--generate-xls-x
%        --files-without-excel-on-mac-linux-win
% - use of excel server can be forced by choosing excelserver = 'on' as an argument.
%   This approach is faster than using java fix thanks to 'xlswrite1 by Matt Swartz
%   see: http://www.mathworks.com/matlabcentral/fileexchange/10465-xlswrite1
% - Additional summary sheet 'info' added. This sheet records processing info about files
%
% Updated by Philippe C. Dixon Jan 2016
% - use 'raw' output from xlsread to avoid bug with certain sheets being read with NaNs
%
% Updated by Philippe C. Dixon Jan 2017
% - fixed help regarding use of 'eventvalFile' argument
% - fixed bug when using  'eventvalFile' argument
%
% Updated by Philippe C. Dixon March 2017
% - bug fix for mac platform
%
% Updated by Philippe C. Dixon August 2017
% - Reorganised to avoid reading the excel file after starting the write
%   process. This avoids errors on some platforms and should be quicker. 
% - Users should set the excel server to 'off'. Future versions may
%   depreciate the excel server option as java seems to handle all
%   situations/platforms


% == SETTINGS ==============================================================================
%
eventvalFile = '';                                            % empty by default
excelserver = 'off';                                          % for excel users (faster)

for i = 1:2:nargin
    
    switch varargin{i}
        
        case 'eventvalFile'
            eventvalFile = varargin{i+1};
            
        case 'excelserver'
            excelserver = varargin{i+1};
            
    end
end


tic                                                           % start function timer

% == LOAD DATA FROM eventval.m AND SET UP NEW SPREADSHEET ==================================
%
if isempty(eventvalFile)
    [f,p] = uigetfile('*.xls','select eventval xls file');
    eventvalFile = [p,f];
else
    [p,f] = fileparts(eventvalFile);
    ext = extension(eventvalFile);
    f = [f,ext];
    if isempty(strfind(p(end),filesep))
        p = [p,filesep];
    end
    
end
cd(p)


% read and save all info from eventval file then force excel server close
%
[~, ch] = xlsfinfo(eventvalFile);                            % all sheets in spreadsheet
[~,info_txt] = xlsread(eventvalFile,'info');

ch = setdiff(ch,'info');
indx = cellfun(@isempty,regexp(ch,'Sheet'));                 % remove blank sheets
ch = ch(indx);

estruct = struct;
for j = 1:length(ch)
    [num,txt,xlsdata] = xlsread(eventvalFile,ch{j});
    estruct.num.(ch{j}) = num;
    estruct.txt.(ch{j}) = txt;
    estruct.xlsdata.(ch{j}) = xlsdata;
end
system('taskkill /F /IM EXCEL.EXE');


% set up new sheet
%
disp('setting up new spreadsheet...')

[~,evalFile,ext] = fileparts(f);
evalFile = [p,evalFile,'2mixedANOVA',ext];                   % new spreadsheet


% Load excel server or java path
%
if strcmp(excelserver,'on')
    disp('loading excel server')
    Excel = actxserver ('Excel.Application');
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(evalFile,1);
    ExcelWorkbook.Close(false);
    invoke(Excel.Workbooks,'Open',evalFile);
else
    disp('Adding Java paths');
    r = which('xlwrite.m');
    pp = fileparts(r);
    jfl = engine('path',pp,'search path','poi_library','extension','.jar');
    
    for i = 1:length(jfl)
        javaaddpath(jfl{i});
    end
    
end




% == GROUP DATA FOR SPREADSHEET ============================================================
%


% get all column names for excel from 'A' to  'Z'
%
cols1 = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',...
    'U','V','W','X','Y','Z'}';
cols = cell(length(cols1)^2,1);
cols = [cols1(2:end); cols];

count = length(cols1);
for c = 1:length(cols1)
    for d = 1:length(cols1)
        cols{count} = [cols1{c},cols1{d}];
        count = count+1;
    end
end


% Extract data from 'info sheet'
%

if strcmp(excelserver,'on')
    xlswrite1(evalFile,info_txt,'info','A1');
    xlswrite1(evalFile,{'Original file'},'info','A3');
    xlswrite1(evalFile,{eventvalFile},'info','A4');
    xlswrite1(evalFile,{date},'info','A7');
else
    xlwrite(evalFile,info_txt,'info','A1');
    xlwrite(evalFile,{'Original file'},'info','A3');
    xlwrite(evalFile,{eventvalFile},'info','A4');
    xlwrite(evalFile,{date},'info','A7');
end




nch = {};
acount = 0;
for j = 1:length(ch)
    count = 1;
    
    %[num,txt,xlsdata] = xlsread([p,f],ch{j});
    
    num = estruct.num.(ch{j});
    txt = estruct.txt.(ch{j}) ;
    xlsdata = estruct.xlsdata.(ch{j});
    
    [~,dcols] = size(num);                             % dcols = number of data columns
    
    xlsdata = xlsdata(4:end,4:end);
    xlsdata = cell2mat(xlsdata);
    xlsdata = xlsdata(:,1:dcols);
    
    events = txt(2,4:end);
    events(cellfun(@isempty,events)) = [];   % cell array of strings for evts for ch j
    
    txt = txt(4:end,1:3);                    % ignore meta data rows
    
    conditions = unique(txt(:,2));           % cell array of strings for con names for ch j
    subjects = unique(txt(:,1));             % cell array of strings for sub names for ch j
    
    if length(strfind(conditions{1},filesep)) >1
        cons = conditions;
    else
        cons = cell(size(conditions));
        
        for a = 1:length(conditions)
            r = conditions{a};
            indx = strfind(r,filesep);
            cons{a} = r(indx(1)+1:end);
        end
    end
    cons= unique(cons);
    
    if j ==1
        group = {};
    end
    
    alldata = struct;
    for k = 1:length(subjects)
        sub_stk = [];
        
        for n = 1:length(txt)
            
            if ~isempty(strmatch(txt(n,1),subjects(k,:))) %#ok<MATCH2>
                plate = xlsdata(n,:);
                sub_stk = [sub_stk;plate];     %#ok<*AGROW> % stack of data for each subject
                grp = txt(n,2);
                grp = grp{1};
                indxx = strfind(grp,filesep);
                grp = grp(1:indxx(1)-1);
            end
        end
        
        if j ==1
            group = [group;grp];
        end
        
        for l = 1:length(cons)
            sub_con_stk = [];
            
            for n = 1:length(txt)
                r = txt(n,2);  
                if  isin(r{1},cons{l}) && isin(cons{l},grp)
                    plate = xlsdata(n,:);
                    sub_con_stk = [sub_con_stk;plate];             % all data for subject k, condition l
                end
            end
            
            if ~isempty(sub_con_stk)
                sub_con_stk = intersect(sub_stk, sub_con_stk,'rows'); % note rows are sorted increasingly
            end
            
            for m = 1:length(events)
                
                if isempty(sub_con_stk)
                    mean_sub_con_evt = [999 999];
                else
                    sub_con_evt = sub_con_stk(:,[2*m-1 2*m] );        % all data for subjectk, condition l , event m
                    indx = find(sub_con_evt ==999);                   % data with 999 are outliers;
                    sub_con_evt(indx)=NaN;
                    mean_sub_con_evt = nanmean(sub_con_evt,1);
                    
                    indx = find(isnan(mean_sub_con_evt));                 % data with 999 are outliers;
                    
                    if ~isempty(indx)
                        mean_sub_con_evt(2) =999;                           %if all sub con  evt are Nan write 999
                    end
                end
                
                disp(['writing data for ',ch{j},' ',subjects{k},' ',cons{l},' ',events{m}])
                
                name = [ch{j},events{m}];
                
                if length(name) >31
                    disp('name too long for xlswrite...shrinking name')
                    name = name(1:30);
                end
                
                if l==1
                    if strcmp(excelserver,'on')
                        xlswrite1(evalFile,{'Subject'},name,'A1');               % Headers
                        xlswrite1(evalFile,cons',name,'C1');                     % Headers
                        xlswrite1(evalFile,{'group'},name,'B1');                 % Headers
                    else
                        xlwrite(evalFile,{'Subject'},name,'A1');                 % Headers
                        xlwrite(evalFile,cons',name,'C1');                       % Headers
                        xlwrite(evalFile,{'group'},name,'B1');                   % Headers
                    end
                end
                if strcmp(excelserver,'on')
                    xlswrite1(evalFile,{subjects(k)},name,['A',num2str(count+1)]);
                    xlswrite1(evalFile,{grp},name,['B',num2str(k+1)]);
                    xlswrite1(evalFile,mean_sub_con_evt(2),name,[cols{l+1},num2str(k+1)]);
                else
                    xlwrite(evalFile,{subjects(k)},name,['A',num2str(count+1)]);
                    xlwrite(evalFile,{grp},name,['B',num2str(k+1)]);
                    xlwrite(evalFile,mean_sub_con_evt(2),name,[cols{l+1},num2str(k+1)]);
                end
                nch = [nch;name];
                temp = zeros(length(subjects),length(cons));
                
                if ~isfield(alldata,name)
                    alldata.(name).data = temp;
                end
                alldata.(name).data(k,l) = mean_sub_con_evt(2);

            end
        end
        
        count = count +1;
        
    end
    
    % == CREATE SUMMARY SHEET "ALL DATA" ========================================================
    %
    if j==1
        disp(' ')
        disp('Preparing summary sheet')
        disp(' ')
        
        nsheet = 'alldata';
        ugroup = unique(group,'stable');
        subjects = ['Subjects';subjects];
        
        str = '';
        for i = 1:length(ugroup)
            indx = ismember(group,ugroup(i));
            group(indx) = {num2str(i)};
            plate = [num2str(i),'=',ugroup{i},' '];
            str = [str plate];
        end
        
        gheader = ['group:', str];
        
        if strcmp(excelserver,'on')
            xlswrite(evalFile,subjects,nsheet,'A1');               % write subject column
            xlswrite(evalFile,{gheader},nsheet,'B1');              % write group header with id key
            xlswrite(evalFile,str2double(group),nsheet,'B2');      % write group id column
        else
            xlwrite(evalFile,subjects,nsheet,'A1');                % write subject column
            xlwrite(evalFile,{gheader},nsheet,'B1');               % write group header with id key
            xlwrite(evalFile,str2double(group),nsheet,'B2');       % write group id column
        end
        
    end
    
    
    % add information to the summary sheet called 'name'
    %
    names = fieldnames(alldata);
    for n = 1:length(names)
        xlsdata = alldata.(names{n}).data;   % info that would be contained in first sheet
        
        for c=1:length(cons)
            ncon = [names{n},'_',cons{c}];
            disp(['writing summary data for ',nch{j}])
            
            if strcmp(excelserver,'on')
                xlswrite(evalFile,{ncon},nsheet,[cols{2+acount},'1']);          % new con header
            else
                xlwrite(evalFile,{ncon},nsheet,[cols{2+acount},'1']);           % new con header
            end
            
            if c==1
                if strcmp(excelserver,'on')
                    xlswrite(evalFile,xlsdata,nsheet,[cols{2+acount},'2']);      % data
                else
                    xlwrite(evalFile,xlsdata,nsheet,[cols{2+acount},'2']);       % data
                end
            end
            acount = acount+1;
        end
    end
end















% == END PROGRAM ===========================================================================
%

% Close excel server (if on)
%
if strcmp(excelserver,'on')
    invoke(Excel.ActiveWorkbook,'Save');
    Excel.Quit
    Excel.delete
    clear Excel
end


disp(' ')
disp('****************************')
disp('Finished running data for: ')
disp(' ')
disp(evalFile)
toc
disp('****************************')











