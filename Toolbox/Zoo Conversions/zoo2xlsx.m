function zoo2xlsx(fld)

% ZOO2XLSX converts zoo files to spreadsheet files
%
% ARGUMENTS
%  fld    ... Path to zoo files (string)

if nargin==0
    fld = uigetdir;
end
cd(fld)

% add java paths (do not rely on excel server)
%
disp('Adding Java paths');
r = which('xlwrite.m');
p = fileparts(r);
jfl = engine('path',p,'search path','poi_library','extension','.jar');

if length(jfl)~=6
    error('missing java files')
end

javaaddpath(jfl{1});    % for loop seems to fail on some platforms
javaaddpath(jfl{2});
javaaddpath(jfl{3});
javaaddpath(jfl{4});
javaaddpath(jfl{5});
javaaddpath(jfl{6});

% extract and process zoo files
%
fl = engine('fld',fld,'extension','zoo');
for i = 1:length(fl)
    batchdisp(fl{i},'exporting zoo files to spreadsheet')
    data = zload(fl{i});
    zoo2csv_data(data,fl{i})
end

function zoo2csv_data(data,fl)

vch = data.zoosystem.Video.Channels;
vidDataStk = [];
vidHeadStk = [];
count = 1;
for j = 1:length(vch)
    
    % extract data
    r = data.(vch{j}).line;
    vidDataStk = [vidDataStk, r];
    
    [~,cols] = size(r);
    
    % set up appropriate headers
    if cols ==3
        vidHeadStk{count}   = [vch{j},'_x'];
        vidHeadStk{count+1} = [vch{j},'_y'];
        vidHeadStk{count+2} = [vch{j},'_z'];
        count = count+3;
    else
        vidHeadStk{count} = vch{j};
        count = count+1;
    end
    
end


ach = data.zoosystem.Analog.Channels;
analogDataStk = [];
analogHeadStk = [];
count = 1;
for j = 1:length(ach)
    
    % extract data
    r = data.(ach{j}).line;
    analogDataStk = [analogDataStk, r];
    
    [~,cols] = size(r);
    
    % set up appropriate headers
    if cols ==3
        analogHeadStk{count}   = [ach{j},'_x'];
        analogHeadStk{count+1} = [ach{j},'_y'];
        analogHeadStk{count+2} = [ach{j},'_z'];
        count = count+3;
    else
        analogHeadStk{count} =  ach{j};
        count = count+1;
    end
    
end

% write information to csv file
%
[pth,file] = fileparts(fl);
ext = '.xlsx';
evalFile = [pth,filesep,file,ext];

xlwrite(evalFile,{'Summary info related to data'},'info','A1');
xlwrite(evalFile,{'zoo file: '},'info','A3');
xlwrite(evalFile,{fl},'info','A4');
xlwrite(evalFile,{'date processed: '},'info','A6');
xlwrite(evalFile,{date},'info','A7');
xlwrite(evalFile,{'Video frequency'},'info','A9');
xlwrite(evalFile,{'Analog frequency'},'info','A10');

xlwrite(evalFile,data.zoosystem.Video.Freq,'info','B9');
xlwrite(evalFile,data.zoosystem.Analog.Freq,'info','B10');

xlwrite(evalFile,{'Processing steps'},'info','A13');
xlwrite(evalFile,data.zoosystem.Processing,'info','A14');

% write video data
%
xlwrite(evalFile,vidHeadStk,'video_data','A1')
xlwrite(evalFile,vidDataStk,'video_data','A2')

% write analog video data
%
xlwrite(evalFile,analogHeadStk,'analog_data','A1')
xlwrite(evalFile,analogDataStk,'analog_data','A2')

