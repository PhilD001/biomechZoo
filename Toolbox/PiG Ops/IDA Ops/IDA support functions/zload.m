function data = zload(fl)

% zload loads zoo files for quicker typing in batch processing
%
% Created by Philippe C. Dixon January 2012

 data = load(fl,'-mat');
 data = data.data;