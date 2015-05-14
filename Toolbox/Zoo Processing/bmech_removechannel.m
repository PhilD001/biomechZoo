function bmech_removechannel(varargin)

% BMECH_REMOVECHANNEL removes unwanted channels from zoo files 
% 
% data = bmech_removechannnel('chkp',chkp,'chrm',chrm,'fld',fld);
%
% ARGUMENTS
%  chkp         ...    channels to keep as cell array of strings ex.
%  chrm         ...    channels to remove as cell array of strings
%  fld          ...    name of folder to operatre on
%
%
%
% Created 2008
%
% Updated by Philippe C. Dixon August 2010
% -  if channels don't exist, error will not occur
%
% Updated by Philippe C. Dixon February 2014
% - Removed channels are also removed from zoosystem channel list
%
%
%----------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
%                                                                                            %                
% MAIN CONTRIBUTORS                                                                          %
%                                                                                            %
% Philippe C. Dixon         Dept. of Engineering Science. University of Oxford, Oxford, UK   %
% JJ Loh                    Medicus Corda, Montreal, Canada                                  %
% Yannick Michaud-Paquette  Dept. of Kinesiology. McGill University, Montreal, Canada        %
%                                                                                            %
% - This toolbox is provided in open-source format with latest version available on          %
%   GitHub: https://github.com/phild001                                                      %
%                                                                                            %
% - Users are encouraged to edit and contribute to functions                                 %
% - Please reference if used during preparation of manuscripts                               %                                                                                           %
%                                                                                            %
%  main contact: philippe.dixon@gmail.com                                                    %
%                                                                                            %
%--------------------------------------------------------------------------------------------%


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

fl = engine('path',fld,'extension','zoo');


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'removing channel');

    if ~isempty(chkp)    % you've selected channels to remove
       data = keepchannel(data,chkp);
    end
     
    if ~isempty(chrm)    % you've selected channels to remove
        data = removechannel(data,chrm);
    end
    
    save(fl{i},'data');
end
    

















