function bmech_reversepol(fld,ch)

% BMECH_REVERSEPOL(fld,ch) batch process polarity reversing for a given channel and
% accompanying event if available
%
% ARGUMENTS
%  fld      ...  Folder of data to operate on
%  ch       ...  Channels to reverse as cell array of strings
%
% Example
% fld = 'c:/my documents'
% ch = {'Fz1','Fz2'}
% bmech_reversepol(fld,ch) reverses the polarity of the the channels Fz1
% and Fz2 in all files contained within the folder 'c:/my documents'
%
% Notes
% - event of type range of motion ('rom') will not be changed
%
% See also reversepol_data, reversepol_line


% Revision history: 
%
% Created by Philippe C. Dixon 2008  
%
% Updated by Philippe C. Dixon May 2015
% - event data are reversed as well
% - Help improved
%
% Updated by Philippe C. Dixon June 2015
% - events of type 'rom' will not be reversed
% - improved error checking
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'




% Set Defaults
%
if nargin==0
    fld = uigetfolder;
    ch = 'all';
end

if nargin ==1
    ch = 'all';
end

cd(fld);

if ischar(ch)
    ch = {ch};
end


% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'reversing polarity');
    data = reversepol_data(data,ch);
    zsave(fl{i},data);
    
    if isin(ch{1},'all')
        zsave(fl{i},data,'for all channels')
    else
        zsave(fl{i},data,['for channel ',strjoin(ch)])
    end
    
end








