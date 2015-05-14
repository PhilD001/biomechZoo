function data = explodechannel(data,ch)

% standalone function used primarily by bmech_explode
%
% ARGUMENTS
%  data      ... zoo file
%  ch        ... channel to explode as cell array of string
%
%
%
% NOTES
% - existing events are transferred to the '_x' dimension
% - determines the appropriate section (video or analog) automatically
%
% Created 2008 Philippe C. Dixon and JJ Loh
%
% Updated September 15th 2013
% - made use of updated addchannel and removechannel function


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

if isin(ch,'all')
    ch = setdiff(fieldnames(data),'zoosystem');
end


for i = 1:length(ch);
    
    if isfield(data,ch{i})

        cname = ch{i};
        [~,c] = size(data.(cname).line);
        if c ~=3
            continue
        end
        
        if isin(data.zoosystem.Video.Channels,ch{i})
            section = 'Video';
        elseif isin(data.zoosystem.Analog.Channels,ch{i})
            section = 'Analog';
        else
            error('section not identifiable')
        end
        
        evt = data.(cname).event;
        
        xd = data.(cname).line(:,1);
        yd = data.(cname).line(:,2);
        zd = data.(cname).line(:,3);
                
        data = addchannel(data,[cname,'_x'],xd,section);  
        data.([cname,'_x']).event = evt;                  % transfer ecents to x only
       
        data = addchannel(data,[cname,'_y'],yd,section); 
        data.([cname,'_y']).event = struct;
        
        data = addchannel(data,[cname,'_z'],zd,section);
        data.([cname,'_z']).event = struct;
 
        data= removechannel(data,{cname},section);
        
    else
        disp(['ch ',ch{i} ' does not exist'])
        
    end
end



