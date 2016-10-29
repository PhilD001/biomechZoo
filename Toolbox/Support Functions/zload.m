function data = zload(fl)

% data = ZLOAD(fl) loads zoo files for quicker typing in batch processing
%
% ARGUMENTS
%  fl    ... complete file path of file (string)
%
% RETURN
%  data  ... zoo data (struct)
%
% See also zsave

% Revision history
%
% Created by Philippe C. Dixon January 2012
%
% Updated by Philippe C. Dixon October 2016
% - Added additional error checking


% Error checking
%
if iscell(fl)    
    if length(fl)==1
        fl = fl{1};
    else
        error('zload requires a single file input, not cell of strings (from engine?)')
    end
end
    
if ~exist(fl,'file')
    error(['file :',fl,' does not exist'])
end

if ~strcmp(extension(fl),'.zoo')
    error('Only zoo files can be loaded, convert your file to .zoo before loading')
end


% Load file to workspace
%
data = load(fl,'-mat');
data = data.data;
