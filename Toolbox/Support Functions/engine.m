function file_list = engine(varargin)

% fl = ENGINE(varargin) is a file searching algorithm
%
% inputs are in pairs where the first element is the property name and the second is a property value
% The 'path' property is required.  All other properties are optional. All arguments must be strings.
%
% ARGUMENTS
%  'path', 'pth' or 'fld'       ...  root folder path to begin the search as string
%  'extension' or 'ext'         ...  type of file to search as string. ex. '.c3d' or 'csv' ('.' not necessary)
%  'file' or 'search file'      ...  return only files containing specific string ex. '_g_'
%  'substring' , 'search path'  ...  search for a particular string in the path name ex 'hello' in data/helloworld and data/worldhello
%  'subfolder' or 'folder'      ...  search only in folders of a specific name located downstream from the root path (string)
%                                    ex 'helloworld' searches only in folders called 'helloworld'
%
% RETURNS
%  fl                           ...  list of files as cell array of strings
%
% e.g. #1 Return all files in the root folder C:/Users/Public which contain the
% string 'imba':
% fl = engine('path','C:/Users/Public','search file','imba')
%
% e.g. #2 Return all files in the root folder C:/Users/Public which are
% located in the subfolder Sample Music:
% fld = 'C:/Users/Public';
% fl = engine('path',fld,'search path','Sample Music')


% Revision History
%
% Created by JJ Loh  2006/09/20
% Departement of Kinesiology
% McGill University, Montreal, Quebec Canada
%
% Updated by JJ Loh 2006/10/23
% - function now searches for partners.
%   the search function will search in the path and not the filename.
%
% Updated by Phil Dixon 2008/02/05
% - engine can now be used on mac intel. functionality on older mac has not
%   been tested
%
% Updated by Phil Dixon 2011/05/03
% - updated help menu. It is now clear that you can limit search to files
%   containing a specific string
% - multiple options can fit into 'options', but only 1 will work currently
%
% Updated by Phil Dixon 05.02.2015
% -fixed bug when 'option' contains 2 options
% - argument 'folder' not tested
% - use off both options and search path does not work
%
% Updated by Philippe C. Dixon April 2015
% - fixed small bug on MAC platform
% - Users can select 'extension' and 'search file' simultaneously
% - extra error checking added
%
% Updated by Philippe C. Dixon June 2015
% - improved help with examples
%
% Updated by Philippe C. Dixon Jan 2016
% - replaced call to function 'slash' with Matlab embedded 
%   function 'filesep'
%
% Updated by Oussama Jlassi Aug 2023
% - improve code readability and performance (speed and memory consumption)
% -------------------------------------------
 

% Check if the number of input arguments is even
if mod(nargin, 2) ~= 0
    error('Invalid input arguments. Each property name must have a corresponding value.');
end

% Parse and store input arguments in a struct
properties = struct();
for i = 1:2:nargin
    propName = varargin{i};
    propValue = varargin{i + 1};
    % Replace spaces with underscores in property names
    propName = strrep(propName, ' ', '_');
    properties.(propName) = propValue;
end


% update for different input options
properties = clean_properties(properties);

% Check if the 'path' property is provided
if ~isfield(properties, 'path')
    error('The ''path'' property is required.');
end

% check extension input (make it work with extension with and without .)  
if isfield(properties, 'extension')
    if isempty(strfind(properties.extension, '.'))
        properties.extension = ['.', properties.extension];
    end
end


% Convert all property values to strings
properties = structfun(@convertToString, properties, 'UniformOutput', false);

% Start recursive file search
file_list = search_files(properties.path, properties);

% Convert the cell array of file paths to a 1-column array (to match
% the old function output)
file_list = file_list(:);

% If the result is an empty 1-column array, return an empty cell array
if isempty(file_list)
    file_list = {};
end


function file_list = search_files(path, properties)
file_list = {};

% Get a list of all files and folders in the current path
filesAndFolders = dir(path);

% Loop through each item in the current path
for i = 1:length(filesAndFolders)
    item = filesAndFolders(i);

    % Skip '.' and '..' directories (an extreme use case)
    if strcmp(item.name, '.') || strcmp(item.name, '..')
        continue;
    end

    % Check if the item is a file
    if item.isdir == 0
        % Check if the file matches the search criteria
        if check_file_match(item, path, properties)
            file_list{end+1} = fullfile(path, item.name);
        end
    else
        % Recursively search subfolders
        subfolder_path = fullfile(path, item.name);
        subfolder_files = search_files(subfolder_path, properties);
        file_list = [file_list, subfolder_files];
    end
end


function match = check_file_match(item, current_folder, properties)
% Check if the file has the specified extension (if 'extension' property is provided)
if isfield(properties, 'extension')
    ext = convertToString(properties.extension);
    [~, ~, fileext] = fileparts(item.name);
    if ~strcmp(fileext, ext)
        match = false;
        return;
    end
end

% Check if the file name contains the specified search string (if 'search_file' property is provided)
if isfield(properties, 'file')
    searchString = convertToString(properties.file);
    if isempty(strfind(item.name, searchString))
        match = false;
        return;
    end
end

% Check if the file's path contains the specified search string (if 'search_path' property is provided)
if isfield(properties, 'substring')
    searchString = convertToString(properties.substring);
    if ~contains(current_folder, searchString)
        match = false;
        return;
    end
end

% Check if the file is in the specified folder (if 'folder' property is provided)
if isfield(properties, 'subfolder')
    folderName = convertToString(properties.subfolder);
    folderPathParts = strsplit(current_folder, filesep);
    if ~any(strcmp(folderName, folderPathParts))
        match = false;
        return;
    end
end

% If none of the conditions above are met, the file matches the criteria
match = true;


function str = convertToString(input)
if isstring(input) || ischar(input)
    str = char(input);
else
    error('Input must be a string.');
end

function properties = clean_properties(properties)

fieldsToMap = {
    'pth', 'path';
    'fld', 'path';
    'ext', 'extension';
    'search_file', 'file';
    'folder', 'subfolder';
    'search_path', 'substring';
};

for i = 1:size(fieldsToMap, 1)
    if isfield(properties, fieldsToMap{i, 1})
        properties.(fieldsToMap{i, 2}) = properties.(fieldsToMap{i, 1});
    end
end