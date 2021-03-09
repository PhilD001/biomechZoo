function bmech_massnormalize(fld,ch,type)

% BMECH_MASSNORMALIZE (fld,ch,type) mass normalizes the amplitude of force, moment, or 
% power channels 
% 
% ARGUMENTS
%  fld      ...  Folder to batch process (string). 
%  ch       ...  Channel(s) to operate on (single string or cell array of strings).  
%  type     ...  Type of data channel (string): e.g. 'Forces','Moments', or 'Power').
%                Default, algorithm searches channel name for type identifiers
%
% NOTES
% - Mass normalization is normally performed on force,moment, and power data in
%   order to faciliate inter-subject comparisons
% - The zoosystem.Units field is updated 
%
% See also massnormalize_data

% Revision history: 
%
% Created by Philippe C. Dixon March 2016
%
% Updated by Philippe C. Dixon July 2016
% - consistent with zoo version 1.3



% Set defaults/Error check
%
if nargin==2
    type = [];
end

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'mass normalizing amplitude'); 
    data = massnormalize_data(data,ch,type);
    zsave(fl{i},data,['for ',strjoin(ch,' ')]);
end



