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


if ~exist(fl,'file')
    error(['file :',fl,' does not exist'])
end

data = load(fl,'-mat');
%data = matfile(fl,'Writable',true);


data = data.data;
