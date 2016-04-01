function data = normalizedata(data,ndatalength,intmethod)

% data = normalizedata(data,ndatalength,intmethod) normalizes a single zoo file
%
% ARGUMENTS
%  data          ...  zoo file
%  ndatalength   ... length of normalized vectors
%  intmethod      ... interpolation method usde for normalizing
%
% RETURNS
%  data          ... updated zoo file


% Revision history
%
% Created by Philippe C. Dixon March 2016
% - made standalone function based on existing code


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

if nargin==1
    ndatalength = 101;
    intmethod = 'linear';
end

if nargin ==2
    intmethod = 'linear';
end


ch = setdiff(fieldnames(data),{'zoosystem'});




for i = 1:length(ch)
    
    if i==1
        olength = length(data.(ch{i}).line);
    end

    data.(ch{i}).line = normalizeline(data.(ch{i}).line,ndatalength,intmethod);
    
    if ~isempty(fieldnames(data.(ch{i}).event))
        
        event = fieldnames(data.(ch{i}).event);
        
        for e = 1:length(event)
            
            if data.(ch{i}).event.(event{e})(2)~=999
                
                if data.(ch{i}).event.(event{e})(1)~=1
                    data.(ch{i}).event.(event{e})(1) = round(data.(ch{i}).event.(event{e})(1)/(olength)*ndatalength);
                end
                
            end
            
        end
    end
    
end

% Update zoosystem info
%
data.zoosystem.Video.Indx = (0:1:ndatalength)';
data.zoosystem.Analog.Indx = (0:1:ndatalength)';
