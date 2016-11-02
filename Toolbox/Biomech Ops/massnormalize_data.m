function data = massnormalize_data(data,ch,type)

% data = MASSNORMALIZE_DATA(data,ch,type) mass normalizes the amplitude of force, moment, or
% power channels
%
% ARGUMENTS
%  data     ...  Zoo data
%  ch       ...  Channel(s) to operate on (single string or cell array of strings)
%  type     ...  Type of data channel (string): e.g. 'Forces','Moments', or 'Power').
%                Default, algorithm searches channel name for type identifiers
%
% RETURNS
%  data    ...  Zoo data with differentiated chanels appended with suffix '_dot'
%
% Notes
% - mass will be extracted from data
%
% See also bmech_massnormalize


% Revision history:
%
% Created by Philippe C. Dixon July 2016
% - based on existing code
% - consistent with zoo version 1.3


% Set defaults/ Error check
%
if nargin==2
    type = [];
end




% Normalize quantities by mass and update zoosystem
%
mass = getanthro(data,'Bodymass');

if isempty(mass)
    error('no mass information found')
end

for i = 1:length(ch)
    data.(ch{i}).line = data.(ch{i}).line/mass;
    
    if isempty(type)
        
        if isin(ch{i},{'Force','Fx','Fy','Fz'})
            type = 'Forces';
            
        elseif isin(ch{i},{'Moment','Mx','My','Mz'})
            type = 'Moments';
            
        elseif isin(ch{i},{'Power'})
            type = 'Power';
            
        else
            error('unknown data type')
        end
                   
    end
    
    oUnit = data.zoosystem.Units.(type);
    
    if ~isin(oUnit,'/kg')
        nUnit = [oUnit,'/kg'];
        data.zoosystem.Units.(type) = nUnit;
    end
end





