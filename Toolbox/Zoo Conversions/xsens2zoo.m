function data = xsens2zoo(fld, ftype, del)

% XSENS2ZOO converts files created by XSens Inertial measurement unit
% sensors to biomechZoo format
%
% ARGUMENTS
% fld    ...   string, folder to operate on
% ftpye  ...   string, file type. Default 'xlsx'. Future versions will
%              support .mnvx files
% del    ...   bool, option to delete c3d file after creating zoo file.
%              Default: false
% RETURNS
%  data  ...  zoo data. Return if fld is individual file 
%
%
% Created by Vaibhav Shah June 7th, 2021
%
% Updated by Philippe C. Dixon June 8th, 2021


% set defaults
if nargin == 0
    fld = uigetfolder;
    ftype = '.xlsx';
    del = false;
end

if nargin == 1
    ftype = '.xlsx';
    del = false;
end

if nargin ==2
    del = false;
end

% check input (file or folder)
[~,fl,saveFile] = checkinput(fld,ftype);

tic
for i=1:length(fl)
    [fpath,fname]=fileparts(fl{i});
    sname=sheetnames(fl{i});
    disp(' ')
    batchdisp(fl{i},'converting Xsens file to zoo format')
    data=struct;
    for j=1:length(sname)
        disp(['... extracting sheet ', sname{j}])
        if contains(sname{j},'General Information')
            data=GI_sheet(data,fl{i},sname(j));
        elseif contains(sname{j},'Markers')
            continue;
        else
            data=other_sheets(data,fl{i},sname(j));
        end
    end
    
    
    if del
        delete(fl{i})
    end
    
    if saveFile
        zfl=[fpath,filesep,fname,'.zoo'];
        zsave(zfl,data)
    else
        disp(' ')
        disp('zoo file loaded to workspace')
        disp(' ')
    end
    
    
    
end
disp(' ')
disp('**********************************')
disp('Finished converting data in: ')
toc
disp('**********************************')


function data=GI_sheet(data,filename,sheetname)
[~,~,num] = xlsread(filename,sheetname);
data.zoosystem = setZoosystem(filename);
data.zoosystem.Units = struct;
data.zoosystem.Header.Subname = {};
data.zoosystem.Header.TrialNum = {};
data.zoosystem.Header.TrialDuration = [];
data.zoosystem.Header.RecordedDate = datestr(num{4,2});
data.zoosystem.Header.MVN_version = num{1,2};
data.zoosystem.Header.Suit_Label = num{3,2};
data.zoosystem.Header.Processing_Quality = num{6,2};
data.zoosystem.Video.Freq = num{5,2};
data.zoosystem.AVR = 0;
data.zoosystem.Video.ORIGINAL_START_FRAME = 1;
data.zoosystem.Video.CURRENT_START_FRAME  = 1;

function data=other_sheets(data,filename,sheetname)
[num,txt,~] = xlsread(filename,sheetname);
str = regexprep(sheetname, {'-',' ','_','/'},{''});
str=char(str);
if contains(sheetname,'Segment Orientation - Quat')
    ch_name='Frames';
    ch_data=num(:,1);
    data=addchannel_data(data,ch_name,ch_data,'Video');
    data.zoosystem.Video.CURRENT_END_FRAME = length(ch_data);
    data.zoosystem.Video.ORIGINAL_END_FRAME = length(ch_data);
end
for i=2:length(txt)
    txtn = regexprep(txt{i}, {'-',' ','_','/'},{'_'});
    ch_name = [str, '_',txtn];
    ch_data = num(:,i);
    data = addchannel_data(data, ch_name, ch_data, 'Video');
end

