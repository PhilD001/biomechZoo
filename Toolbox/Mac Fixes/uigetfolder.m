function folder = uigetfolder(title, initial_path)

% folder = UIGETFOLDER(title,initia_path) sets up standard Windows browse for folder dialog box.
%
% ARGUMENTS
%  title         ...  title string (OPTIONAL)
%  initial_path  ...  initial path (OPTIONAL, defaults to PWD)
% 
% RETURNS
%  folder        ...  selected folder (empty string if dialog cancelled)
%  
% Examples:    folder = uigetfolder                          - default title and initial path
%               folder = uigetfolder('Select results folder') - default initial path
%               folder = uigetfolder([], 'C:\Program Files')  - default title
%
% See also UIGETFILE, UIPUTFILE


% Revision History
%
% Created by  Neil Rutland 20 Sept 2000
% - http://www.mathworks.com/matlabcentral/fileexchange/332-uigetfolder/content/uigetfolder.m
% 
% Updated by Philippe C. Dixon May 20007
% - now works on mac platforms using uigetdir




if ~strcmp(computer, 'PCWIN')
    folder = uigetdir;
   
else
   if nargin < 2
      initial_path = pwd;
   end
   
   if nargin < 1 || isempty(title)
      title = 'Select a folder';
   end
   
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
