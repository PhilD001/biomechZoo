function startZoo

% STARTZOO sets up path for use of the zoosystem toolbox.
%
% Instructions:
% - Open startZoo in the Matlab editor
% - Run file (press Run button or F5 shortcut key on most systems)
% - Select 'Change Folder' or 'Add to Path'


% Set defaults and paths
%
s = filesep;                                                   % platform depend file sep
zoo_fld = [fileparts(which('startZoo')),s,'Toolbox'];          % get root Zoosystem folder
pmsg = 'Loading ';                                             % prefix for message
smsg = ' ... ';                                                % suffix for message
lfld = 'the zoosystem/Toolbox/Support Functions';              % longest subfolder
lpad = length(pmsg) + length(lfld)+length(smsg)+5;             % length of longest
start = strfind(zoo_fld,'the zoosystem');                      % start of short file path
frmt = ['%-',num2str(lpad),'s'];                               % format output nicely

% Welcome message
%
clc
fprintf('--------------- Welcome to the BiomechZoo Toolbox ---------------\n\n')


% Get Zoosystem folders and subfolders
%
sub = subdir(zoo_fld);
indx = strfind(sub{1},filesep);                                % find slashes in roots


% restore default path
%
fprintf(frmt,['restoring default path',smsg])

restoredefaultpath;

fprintf('complete\n\n')

% Load Zoosystem folders and subfolders
%
fprintf('Loading Zoosystem folders and subfolders:\n\n')


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


% Set some good defaults
%
fprintf('\nSetting Zoosystem defaults:\n\n')

fprintf(frmt,['Send deleted files to trash: ON',smsg])
recycle('on')                                                  % move deleted to recycling
fprintf('complete\n')

fprintf(frmt,['Output format for floats: short g',smsg])
format short g                                                 % use short, avoid sci not
fprintf('complete\n')

% Give the user some help
%
fprintf('\nThe Zoosystem Quick Guide:\n\n')
fprintf('View the <a href="https://vimeo.com/143870493">Video</a> | ')
fprintf('Seek <a href="https://github.com/PhilD001/the-zoosystem-help">help</a> | ')
fprintf('Download the <a href="https://github.com/PhilD001/the-zoosystem-sample-study">sample study</a> | ')
fprintf('Get <a href="https://github.com/PhilD001/the-zoosystem">updates</a>\n\n')
fprintf('type ''zoosystem'' to browse available functions or click <a href="matlab:zoosystem">here</a> \n')
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




