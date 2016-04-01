function bmech_normalize(fld,datalength,intmethod)

% BMECH_NORMALIZE(FLD,DATALENGTH,INTMETHOD) will normalize data to a given data length
%
% ARGUMENTS
%  fld          ...   Folder to operate on
%  datalength   ...   Normalize data to a specific length. Data will have
%                     datalength+1 frames. Default 101 frames
%  intmethod    ...   method to interpolate data. Default 'linear'.
%                     See interp1 for more options
%
% NOTES
% - If no arguments are supplied, the function will ask for a folder to
%   operate on and normalize to 101 frames
% - All channels of a given file will be normalized
% - Normalization will not recalculate an event value. It will only recalculate the 
%   event index. Thus an event may not 'lie' exactly on a normalized line. 
% - For processing a single vector, use standalone NORMALIZELINE.m 


% Revision history: 
%
% Updated by Philippe C. Dixon Jan 2010
% - this function now normalizes event data as well
% - function only runs in batch file mode, 
%
% Updated by Philippe C. Dixon June 2010
% -Event normalization verified and improved. 
%
% Updated by Philippe C. Dixon May 2015
% - Help improved
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon Jan 11th 
% - Interpolation can be performed using any method available in the
%  'interp1' function


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

% Set defaults
%
if nargin==0
    disp('normalizing to 100%, please select your folder');
    disp(' ');
    datalength = 100;
    fld = uigetfolder('select zoo processed ');
    cd(fld);  
    intmethod = 'linear';

end

if nargin ==1
    disp(['normalizing to 100%, using folder ',fld]);
    datalength=101;
    intmethod = 'linear';
end

if nargin ==2
    disp(['normalizing to ',num2str(datalength),'using folder ',fld])
    intmethod = 'linear';
end



% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'normalizing:');
    data = normalizedata(data,datalength,intmethod);
    zsave(fl{i},data, [num2str(datalength+1) ' frames']);
end

















