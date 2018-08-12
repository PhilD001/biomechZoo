function bmech_velocity(fld,ch,method)


% BMECH_VELOCITY(fld,ch,method) calculates velocity of a trial based on a given marker. 
% Also displays average velocity for a given trial
% 
% ARGUMENTS
%  fld         ...    folder to operate on
%  ch          ...    name of marker (as string)
%  method      ...    'normalize' to dimensionally normalize. Default no normalization 



% Revision history: 
%
% Created by Phil Dixon Nov 2008
%
% Updated July 2011
% - outputs mean trial velocity
%
% Updated November 2012
% - error checking, more detailed
% - removed axis input
%
% Updated dec 31st 
% - complies with zoosystem v1.0
%
% Updated June 14th 2013
%  - cleaned up help 
%
% Updated November 2014
% -dimensionless normalization option according to Hof AL. Scaling Gait Data to Body Size. 
%  Gait and Posture 1996, 4(3): 222-3. 




% Set defaults
%
if nargin==0
    fld = uigetfolder;
    ch = 'SACR';
    method = 1;
end

if nargin==1
    ch = 'SACR';
    method =1;
end
    
if nargin==2
    method =1;
end

 

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'computing velocity'); 
    data = velocity_data(data,ch,method);
    zsave(fl{i},data,['for channel ',ch]);
end

