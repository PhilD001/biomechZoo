function data = velocity(data,ch,method)

% data = VELOCITY(data,ch,method) computes velocity of a motion capture
% trial based on a given marker
%
% ARGUMENTS
%  fld         ...    folder to operate on
%  ch          ...    name of marker (as string)
%  method      ...    'normalize' to dimensionally normalize. Default no normalization 
%
% RETURNS
% data         ...     zoo data with event added to event branch of channel 'ch'
% 
%
% Updated April 2015
% - made standalone function
% - improved error checking
%
%
% Part of the Zoosystem Biomechanics Toolbox 
% Philippe C. Dixon



% Choice to normalize velocity
%
if isin(method,'normalize')
    LL = mean([data.zoosystem.Anthro.LLegLength data.zoosystem.Anthro.RLegLength]);
    
    if LL > 10
        disp('converting leg length from mm to m')
        LL = LL/1000; % put in mm
    end
    
    factor = sqrt(g*LL);
    
else
    factor = 1;
end



% Error check for missing channel
%
if ~isfield(data,ch)
    
    if isfield(data,[ch,'_x'])

       x = data.([ch,'_x']).line;
       y = data.([ch,'_y']).line;
       z = data.([ch,'_z']).line;
 
       ddata = [x y z];
       
       ch = [ch,'_x'];
    else
        error('channel does not exist')
    end
    
else
    ddata = data.(ch).line;
end
        

% Determine units of marker data and convert to meters
%
if isfield(data.zoosystem.Units,'Markers')
    units = data.zoosystem.Units.Markers;
else
    units ='mm';
end

switch units
    
    case 'mm'
        r = 1000;
    case 'cm'
        r = 100;
    case 'dm'
        r = 10;
    case 'm'
        r = 1;
    otherwise
        error(['unknown units for marker ',ch])
end

ddata = ddata/r; % convert to meters


% Extract sampling rate of signal and determine time (sec)
%
fsamp = data.zoosystem.Video.Freq;


% Compute velocity and add to zoosystem
%
p1 = ddata(1,:);
p2 = ddata(end,:);

time = length(ddata)/fsamp;

if isin(method,'normalize')
    vel = magnitude((p2-p1)/time);
    vel = vel/factor;
else
    vel = magnitude((p2-p1)/time);
end


% Add information to zoosystem
%
data.(ch).event.vel = [1 vel 0];

if isin(method,'normalize')
    data.zoosystem.Units.Velocity = 'normalized';   
else
    data.zoosystem.Units.Velocity = 'm/s';
end



