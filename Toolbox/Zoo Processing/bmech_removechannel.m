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


% Part of the Zoosystem Biomechanics Toolbox 
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.



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
    

















