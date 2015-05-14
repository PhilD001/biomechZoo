function data= removechannel(data,chrm,section)

% removechannel removes channels from zoo files
%
% ARGUMENTS
% data      ... zoo file
% chrm      ... channels to remove as cell array of strings
%
% NOTES
% - standalone function used primarily by BMECH_REMOVECHANNEL
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


% error checking
%
if ~iscell(chrm)
    chrm = {chrm};
end

% setting sections
%
if nargin==2
    
    section = [];
    v_list = cell(size(chrm));
    a_list = cell(size(chrm));
    
    for i = 1:length(chrm)
        
        if isin(data.zoosystem.Video.Channels,chrm{i})
            v_list{i}  = chrm{i};
            
        elseif isin(data.zoosystem.Analog.Channels,chrm{i})
            a_list{i}  = chrm{i};
            
        else
            error('missing appropriate section fieldname in zoosystem')
        end
        
    end
    
    v_list(cellfun(@isempty,v_list)) = [];
    a_list(cellfun(@isempty,a_list)) = [];
    
    
end





% process
%
for i = 1:length(chrm)
    
    if isfield(data,chrm{i})
        
        data = rmfield(data,chrm{i});
        
        if ~isempty(section)
            
        elseif isin(chrm{i},v_list)
            section = 'Video';
        elseif isin(chrm{i},a_list)
            section = 'Analog';
        end
        
        chlist = data.zoosystem.(section).Channels;
        nchlist = setdiff(chlist,chrm{i});
        data.zoosystem.(section).Channels = nchlist;
        
    end
    
end