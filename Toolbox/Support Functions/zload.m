function data = zload(fl)

% zload loads zoo files for quicker typing in batch processing
%
% Created by Philippe C. Dixon January 2012


if ~exist(fl,'file')
    error(['file :',fl,' does not exist'])
end

data = load(fl,'-mat');
%data = matfile(fl,'Writable',true);


data = data.data;
