function bmech_filter(varargin)

% data = BMECH_FILTER(varargin) will filter data with zero-lag based on user input arguments
%
% ARGUMENTS
%  fld       ...   full path leading to folder to be processed
%  cutoff    ...   single number or 2 element vector (for notch type filters)
%  ftype     ...   Type of filter (string) to be used from the following list:
%                 ('butterworth', 'chebychev I', 'chebychev II', 'eliptic','bessel')
%  order     ...   Order of filter (number). Default is 4
%  pass      ...   frequencies to pass (string) from the following list:
%                 ('lowpass', 'highpass', 'bandpass','notch'). Default is lowpass
%  chfilt    ...   channel to filter as cell arrawy of strings. e.g. {'ch1','ch2','ch3'}
%
%
% NOTES
% - inputs are in pairs where the first element is the property name and the second is a property value
%   e.g. data = bmech_filter('fld',fld) associates the folder fld to the variable 'fld
% - if you want to run the filter on a single vector or zoo file, use 'filterline'
% - Sampling rate will be read from zoo file. If filtering both analog and
%   video channels, users should make sure that filter settings are
%   approproate for both


% Revision history: 
%
% Created by JJ Loh 2006
%
% Updated by Philippe C Dixon Oct 2007
% - improved functionality
%
% Updated by Philippe C. Dixon Nov 2008
% - increased choice of parameters
%
% Updated by Philippe C. Dixon June 2010
% - when using zoo files, fsamp is extracted from the zoosystem channel
%
% updated by Philippe C. Dixon August 2010
% - fixed small bug in 'zoodata' mode.
%
% updated by Philippe C. Dixon June 2012
% - added possibility of filtering via fft algorithm
%
% Updated by Philippe C. Dixon August 2013
% - fixed sampling frequency bug when processing using a folder
%
% Updated by Philippe C. Dixon September 2013
% - checking of frequency using zoo v1.2 functionality
% - filter setting can be input using a struct called 'filt'
%
% Updated by Philippe C. Dixon May 2015
% - improved help
% - simplified inputs
% - 'filterline' made as standalone function
% - upgraded to zoosystem v.1.2 (no backwards compatibility)
%
% Updated by Philippe C. Dixon Sept 2015
% - implements the new 'zsave' procedure in which the processing information
%   is saved to the zoo file in the branch 'data.zoosystem.processing'
%
% Updated by Philippe C. Dixon Nov 2015
% - Fixed bug with selection of specific channels to filter
% - Added display of filter settings summary


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

% Default settings
%
filt.cutoff = 10;
filt.ftype = 'butterworth';
filt.forder = 4;
filt.pass = 'lowpass';
chfilt = 'all';

fld = [];


for i = 1:2:nargin
    
    switch varargin{i}
        
        case 'cutoff'
            filt.cutoff = varargin{i+1};
            
        case 'ftype'
            filt.ftype = varargin{i+1};
            
        case 'order'
            filt.forder = varargin{i+1};
            
        case 'pass'
            filt.pass = varargin{i+1};
            
        case 'chfilt'
            chfilt = varargin{i+1};
            
        case 'fld'
            fld = varargin{i+1};
          
    end

end

if isempty(fld)
    fld = uigetfolder;
end




cd(fld)

fl = engine('fld',fld,'extension','zoo');

% Filter summary
%
disp('----------------Filter settings------------')
disp(['Filter type:             ',filt.ftype])  
disp(['Filter Order:            ',num2str(filt.forder)])
disp(['Filter Pass Range:       ',filt.pass]);
disp(['Filter Cutoff Frequency: ', num2str(filt.cutoff)])
disp(' ')
disp('Channels to be filtered:')
disp(makecolumn(chfilt));


for i = 1:length(fl)
    data = zload(fl{i});    
    batchdisplay(fl{i},'filtering:')
    data = filterprocess(data,chfilt,filt);
    msg = [filt.ftype,' ',num2str(filt.cutoff),'Hz ',num2str(filt.pass),' ',num2str(filt.forder),'th order'];
    zsave(fl{i},data,msg);
end




    
  
%============EMBEDDED FUNCTIONS================
