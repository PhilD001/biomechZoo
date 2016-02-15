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


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Dr. Philippe C. Dixon, Harvard University. Boston, USA.
% Yannick Michaud-Paquette, McGill University. Montreal, Canada.
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


if strcmp(ch,'all')
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



