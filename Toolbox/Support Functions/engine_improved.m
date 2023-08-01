function file_list = engine_improved(varargin)

    % fl = ENGINE(varargin) is a file searching algorithm
    %
    % inputs are in pairs where the first element is the property name and the second is a property value
    % The 'path' property is required.  All other properties are optional. All arguments must be strings.
    %
    % ARGUMENTS
    %  'pth, 'path' or 'fld'  ...  folder path to begin the search as string
    %  'extension' or 'ext'   ...  type of file to search as string. ex. '.c3d' or 'csv' ('.' not necessary)
    %  'search file'          ...  return only files containing specific string ex. '_g_'
    %  'search path'          ...  search for a particular string in the path name ex 'hello' in data/hello
    %  'folder'               ...  search only in folders of a specific name located downstream from the path (string)
    %
    % RETURNS
    %  fl                     ...  list of files as cell array of strings  
    %
    % e.g. #1 Return all files in the root folder C:/Users/Public which contain the
    % string 'imba':
    % fl = engine('path','C:/Users/Public','search file','imba')
    %
    % e.g. #2 Return all files in the root folder C:/Users/Public which are
    % located in the subfolder Sample Music: 
    % fld = 'C:/Users/Public';
    % fl = engine('path',fld,'search path','Sample Music')
    
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

    % Check if the 'path' property is provided
    if ~isfield(properties, 'path')
        error('The ''path'' property is required.');
    end

    % Convert all property values to strings
    properties = structfun(@convertToString, properties, 'UniformOutput', false);

    % Start recursive file search
    file_list = search_files(properties.path, properties);

    % Convert the cell array of file paths to a 1-column array (to match
    % the previous function output)
    file_list = file_list(:);

    % If the result is an empty 1-column array, return an empty cell array
    if isempty(file_list)
        file_list = {};
    end
end

function file_list = search_files(path, properties)
    % Initialize an empty cell array to store the file paths
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
end

function match = check_file_match(item, current_folder, properties)
    % Check if the file has the specified extension (if 'extension' property is provided)
    if isfield(properties, 'extension')
        ext = convertToString(properties.extension);
        [~, filename, fileext] = fileparts(item.name);
        if ~strcmp(fileext, ext)
            match = false;
            return;
        end
    end

    % Check if the file name contains the specified search string (if 'search_file' property is provided)
    if isfield(properties, 'search_file')
        searchString = convertToString(properties.search_file);
        if isempty(strfind(item.name, searchString))
            match = false;
            return;
        end
    end

    % Check if the file's path contains the specified search string (if 'search_path' property is provided)
    if isfield(properties, 'search_path')
        searchString = convertToString(properties.search_path);
        if isempty(strfind(current_folder, searchString))
            match = false;
            return;
        end
    end

    % Check if the file is in the specified folder (if 'folder' property is provided)
    if isfield(properties, 'folder')
        folderName = convertToString(properties.folder);
        folderPathParts = strsplit(current_folder, filesep);
        if ~any(strcmp(folderName, folderPathParts))
            match = false;
            return;
        end
    end

    % If none of the conditions above are met, the file matches the criteria
    match = true;
end

function str = convertToString(input)
    if isstring(input) || ischar(input)
        str = char(input);
    else
        error('Input must be a string.');
    end
end
