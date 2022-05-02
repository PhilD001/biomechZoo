function startZoo

% STARTZOO sets up path for use of the zoosystem toolbox.
%
% Instructions:
% - Open startZoo in the Matlab editor
% - Run file (press Run button or F5 shortcut key on most systems)
% - Select 'Change Folder' or 'Add to Path'
%
% Notes: 
% -biomechZoo toolbox and help files should be installed side-by-side e.g.:
%  ~\biomechZoo\biomechZoo-master
%  ~\biomechZoo\biomechZoo-help-master

% Set defaults and paths
%
s = filesep;                                                   % platform depend file sep
zoo_fld = [fileparts(which('startZoo')),s,'Toolbox'];          % get root Zoosystem folder
pmsg = 'Loading ';                                             % prefix for message
smsg = ' ... ';                                                % suffix for message
start = strfind(zoo_fld,'biomechZoo');                         % start of short file path

pad = length(zoo_fld(start(1):end))+32;
lpad = length(pmsg) + pad + length(smsg);                      % length of longest
frmt = ['%-',num2str(lpad),'s'];                               % format output nicely


% Get Zoosystem folders and subfolders
%
sub = subdir(zoo_fld);
indx = strfind(sub{1},filesep);                                % find slashes in roots


% Welcome message
%
path([zoo_fld,filesep,'Support Functions'],path)               % quick add path
[version,date] = zooinfo;
clc
fprintf(['---------------- Welcome to the biomechZoo Toolbox ',version, ' ', date,' ----------------------\n\n'])



% restore default path
%
fprintf(frmt,['restoring default path',smsg])

restoredefaultpath;

fprintf('complete\n\n')

% Load Zoosystem folders and subfolders
%
fprintf('Loading biomechZoo folders and subfolders:\n\n')


% a) load mac fixes (MACI platform only)
mindx = strfind(sub,'Mac Fixes');
mindx = find(~cellfun(@isempty,mindx));

for i = 1:length(mindx)
    csub = sub{mindx(i)};
    if ~isempty(strfind(computer, 'MACI')) && isempty(strfind(csub,'@'))
        csub_short = csub(start:end);
        msg = [pmsg,csub_short,smsg];
        fprintf(frmt, msg)
        path(csub,path)
        fprintf('complete\n')
    end
    sub{mindx(i)} = [];
end
sub(cellfun(@isempty,sub)) = [];


% b) load all other subfolders
for i = 1:length(sub)
    csub = sub{i};
    cindx = strfind(csub,filesep);                             % num slash in current fld
    
    if isempty(strfind(csub,'obsolete'))
        if length(cindx) == length(indx)
            csub_short = csub(start:end);                      % shortened current fld
            msg = [pmsg,csub_short,smsg];
            fprintf(frmt, msg)
            path(sub{i},path)
            fprintf('complete\n')
        else
            path(sub{i},path)
        end
    end
end

% c) load the help files (if available)
%
root_fld = zoo_fld(1:indx(end-2));
fl = engine('fld',[root_fld, 'biomechZoo-help'],'search file','samplestudy_process','extension','.m');

if ~isempty(fl)
    
sfld = fileparts(fl{1});
help_fld = strrep(sfld,'sample study','examples');

    
    fprintf('\nLoading biomechZoo-help scripts:\n\n')

    csub_short = sfld(start:end);                      % shortened current fld
    msg = [pmsg,csub_short,smsg];
    fprintf(frmt, msg)
    path(sfld,path)
    fprintf('complete\n')
                
    path(help_fld,path);
    sub = subdir(help_fld);
    
    for i = 1:length(sub)
        csub = sub{i};
        cindx = strfind(csub,filesep);                             % num slash in current fld
        
            if length(cindx) == length(indx) 
                csub_short = csub(start:end);                      % shortened current fld
                msg = [pmsg,csub_short,smsg];
                fprintf(frmt, msg)
                path(sub{i},path)
                fprintf('complete\n')
            else
%                 path(sub{i},path)
            end
    end
    
else
    fprintf('\nHelp and sample study files not found in current setup\n')
    fprintf('Download help and sample study files <a href="https://github.com/PhilD001/biomechzoo-help">here</a>\n')
    
end






% Set some good defaults
%
fprintf('\nSetting biomechZoo defaults:\n\n')

fprintf(frmt,['Send deleted files to trash: ON',smsg])
recycle('on')                                                  % move deleted to recycling
fprintf('complete\n')

fprintf(frmt,['Output format for floats: short g',smsg])
format short g                                                 % use short, avoid sci not
fprintf('complete\n')

% Give the user some help
%
fprintf('\nbiomechZoo Quick Guide:\n\n')
fprintf('Visit the <a href="https://www.biomechzoo.com/">Website</a> | ')
fprintf('Get <a href="https://github.com/PhilD001/biomechzoo">updates</a> | ')
fprintf('Download the <a href="https://github.com/PhilD001/biomechzoo-help/">sample data</a> | ')
fprintf('Seek <a href="https://github.com/PhilD001/biomechzoo-help">help</a> \n\n')
% fprintf('type ''zoosystem'' to browse available functions or click <a href="matlab:zoosystem">here</a> \n')
fprintf('type ''zooinfo'' for project information or click <a href="matlab:zooinfo">here</a> \n')
fprintf('type ''samplestudy'' to explore the sample study or click <a href="matlab:samplestudy">here</a> \n\n')



function [sub,fls] = subdir(CurrPath)

% SUBDIR  lists (recursive) all subfolders and files under given folder
%
% [sub,fls] = subdir(CurrPath)
%
% ARGUMENTS
%    CurrPath     ...   pth as outputted from uigetfolder
%
% RETURNS
%    SUB       ...  path of each subfolder as string array
%    FLS       ...  filenames as string array
%
% NOTES
%   use sort([F{:}]) to get sorted list of all filenames.
%   See also DIR, CD
%
% Created by Elmar Tarajan [Elmar.Tarajan@Mathworks.de]  07-Dez-2004
%
%
% updated by phil dixon october 2011
%  - works with  MAC platorm



if nargin == 0
    CurrPath = cd;
end

if nargout == 1
    sub = subfolder(CurrPath,'');
else
    [sub, fls] = subfolder(CurrPath,'','');
end


function [sub,fls] = subfolder(CurrPath,sub,fls)

tmp = dir(CurrPath);
tmp = tmp(~ismember({tmp.name},{'.' '..'}));
for i = {tmp([tmp.isdir]).name}
    sub{end+1} = [CurrPath, filesep, i{:}];  %#ok<AGROW> % updated PD
    
    if nargin==2
        sub = subfolder(sub{end},sub);
    else
        tmp = dir(sub{end});
        fls{end+1} = {tmp(~[tmp.isdir]).name}; %#ok<AGROW>
        [sub, fls] = subfolder(sub{end},sub,fls);
    end
end




