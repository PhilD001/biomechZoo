function bmech_renamechannel(fld,och,nch)
      
% BMECH_RENAMECHANNEL(fld,och,nch) batch process renaming of channels
%
% ARGUMENTS
%  fld   ...  Folder (batch process) or full path to individual file (string).
%  och   ...  Name of old channels (cell array of strings or single string) e.g. {'ch1','ch2'}
%  nch   ...  Name of new channels (cell array of strings or single string)
%
% See also renamechannel_data, ebmech_removechannel

% Revision History
%
% Created by Philippe C. Dixon May 2009 
% - based on original function by JJ Loh
%
% Updated by Philippe C. Dixon March 2011
% - Added optional 3rd argument
%
% Updated by Philippe C. Dixon January 2014
% - updates channel list in relevant section (video or analog)
% - uses standalone renamechannel
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon Jan 2016
% - Uses standard sub-function renamechannel.m


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



if nargin ==2
    fld = uigetfolder;
end

cd(fld);

fl = engine('path',fld,'extension','zoo');

% check for single string instead of cell array of strings
%
if ~iscell(och)
    och = {och};
end

if ~iscell(nch)
    nch= {nch};
end


if length(och)~=length(nch)
    error('number of new name channels does not match number of old channel names to replace')
end
    
disp(' ')
disp('renaming the following channels:')
for i = 1:length(och)
    disp(['renaming ', och{i}, ' to ',nch{i}])
end

disp(' ')


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'renaming channels')
    data = renamechannel_data(data,och,nch);
    zsave(fl{i},data);
end













