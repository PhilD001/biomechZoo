function bmech_removechannel(varargin)

% BMECH_REMOVECHANNEL(varargin) removes unwanted channels from zoo files
%
% ARGUMENTS
%  chkp         ...    channels to keep as cell array of strings ex.
%  chrm         ...    channels to remove as cell array of strings
%  fld          ...    name of folder to operatre on
%
% Created 2008
%
% Updated by Philippe C. Dixon August 2010
% -  if channels don't exist, error will not occur
%
% Updated by Philippe C. Dixon February 2014
% - Removed channels are also removed from zoosystem channel list
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt


chkp = [];
chrm = [];
fld = [];

%-------Default settings----

for i = 1:2:nargin
    
    switch varargin{i}
        
        case 'chkp'
            chkp = varargin{i+1};
        case 'chrm'
            chrm = varargin{i+1};
        case 'fld'
            fld = varargin{i+1};
    end
end


if isempty(fld)
    fld = uigetfolder('select zoo processed)');
end

cd(fld)

fl = engine('path',fld,'extension','zoo');


% error checking
%


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'removing channel');
    
    if ~isempty(chrm)    % you've selected channels to remove
        data = removechannel(data,chrm);
        if ~iscell(chrm)
            chrm = {chrm};
        end
        nch = length(chrm);
    end
    
    if ~isempty(chkp)    % you've selected channels to remove
        allch = setdiff(fieldnames(data),'zoosystem');
        nch = length(setdiff(allch,chkp));
        data = keepchannel(data,chkp);
    end
    
    if length(nch)==1
        suff = 'channel';
    else
        suff = 'channels';
    end
    
    zsave(fl{i},data, ['removed ',num2str(nch),' ',suff]);
end


















