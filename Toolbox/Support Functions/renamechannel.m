function data = renamechannel(data,och,nch,section)


% renamechannel renames channels in zoo files
%
% ARGUMENTS
% data      ... zoo file
% och       ... channels to remove as cell array of strings
% nch       ... channels to add (rename)
% section   ... zoo file section ('video' or 'analog')
%
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


if nargin==3
    section = '';
end


for i = 1:length(och)
    
    if isempty(findfield(data,och{i}))
        disp(['channel: ',och{i}, ' does not exist'])
        
    else
        
        if ~isempty(section)
            
        elseif isin(data.zoosystem.Video.Channels,och{i})
            section = 'Video';
        else
            section = 'Analog';
        end
        
        r = data.(och{i}).line;   % save data in och
        
        data = addchannel(data,nch{i},r,section); % copy this data to nch
        data = removechannel(data,och{i},section); % remove the old field
       
        
    end
end

