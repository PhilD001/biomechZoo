function folder = uigetfolder(title, initial_path)

% UIGETFOLDER(title, initial_path)  Standard Windows browse for folder dialog box.
%
%   folder = uigetfolder(title, initial_path)
%
%   Output: folder       = selected folder (empty string if dialog cancelled)
%   Inputs: title        = title string (OPTIONAL)
%           initial_path = initial path (OPTIONAL, defaults to PWD)
%
%   Examples:   folder = uigetfolder                          - default title and initial path
%               folder = uigetfolder('Select results folder') - default initial path
%               folder = uigetfolder([], 'C:\Program Files')  - default title
%
%   See also UIGETFILE, UIPUTFILE

%-----------------------------------------------------------------------------------------------

% Updated by Philippe C. Dixon 2007/11/05
% uigetfolder now works on mac platforms using uigetdir
%
% Updated by Philippe C. Dixon June 22nd 2016
% - allow title and initial_path to be correctly displayed in browser window


if nargin < 2
    initial_path = pwd;
end

if nargin < 1 || isempty(title)
    title = 'Select a folder';
end


if ~strcmp(computer, 'PCWIN')
    folder = uigetdir(initial_path,title);
    
else
    
    % Error checking
    if ~ischar(title)
        error('The title must be a string')
    end
    if ~ischar(initial_path)
        error('The initial path must be a string')
    end
    if ~exist(initial_path, 'dir')
        error(['The initial path: ', initial_path, ' does not exist!'])
    end
    
    folder = uigetfolder_win32(title, initial_path);
    
end
