function zoosystem = setZoosystem(fl)

% zoosystem = SETZOOSYSTEM(fl) creates 'zoosystem' branch for data
% being imported to biomechZoo
%
% ARGUMENTS
%  data      ... Zoo data
%  r         ... Parameters (struct)
%
% RETURNS
%  data      ... Zoo data with appropriate parameters loaded


% Set defaults
%
ver = zooinfo(false);                                                                
zch = {'Analog','Anthro','AVR','CompInfo','SourceFile','Units','Version','Video'};


% Set up struc
%
zoosystem = struct;
for i = 1:length(zch)
    zoosystem.(zch{i}) = struct;
end

section = {'Video','Analog'};

for i = 1:length(section)
    zoosystem.(section{i}).Channels = {};
    zoosystem.(section{i}).Freq = [];
    zoosystem.(section{i}).Indx = [];
    zoosystem.(section{i}).ORIGINAL_START_FRAME = [];
    zoosystem.(section{i}).ORIGINAL_END_FRAME   = [];
    zoosystem.(section{i}).CURRENT_START_FRAME  = [];
    zoosystem.(section{i}).CURRENT_END_FRAME    = []; 
end

zoosystem.Processing = '';

zoosystem.AVR = 0;

zoosystem.Analog.FPlates.CORNERS = [];
zoosystem.Analog.FPlates.NUMUSED = 0;
zoosystem.Analog.FPlates.LOCALORIGIN = [];                            % not available
zoosystem.Analog.FPlates.LABELS = [];

zoosystem.Version = ver;
zoosystem.SourceFile = char(fl);
 
zoosystem.Units.Markers = 'mm';
zoosystem.Units.Angles = 'deg';
zoosystem.Units.Forces = 'N';
zoosystem.Units.Moments = 'Nmm';
zoosystem.Units.Power = 'W/kg';
zoosystem.Units.Scalars = 'mm';

% 
