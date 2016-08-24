function data = explodechannel_data(data,ch)

% data = EXPLODECHANNEL_DATA(data,ch) explodes channels
%
% ARGUMENTS
%  data     ... Zoo file
%  ch       ...  Channels to explode (single string or cell array of strings).
%                Default: explode all channels 'all'
%
% NOTES
% - existing events are transferred to the '_x' dimension
% - Appropriate section (video or analog) determined automatically
%
% See also bmech_explode


% Revision history
%
% Created 2008 Philippe C. Dixon and JJ Loh
%
% Updated September 15th 2013
% - made use of updated addchannel and removechannel function


% set defaults/error check
%
if strcmp(ch,'all')
    ch = setdiff(fieldnames(data),'zoosystem');
end


% Process
%
for i = 1:length(ch);
    
    if isfield(data,ch{i})
        cname = ch{i};
        [~,c] = size(data.(cname).line);
        
        if c ==3
            if ismember(ch{i},data.zoosystem.Video.Channels)
                section = 'Video';
            elseif ismember(ch{i},data.zoosystem.Analog.Channels)
                section = 'Analog';
            else
                error('section not identifiable')
            end
            
            evt = data.(cname).event;
            
            xd = data.(cname).line(:,1);
            yd = data.(cname).line(:,2);
            zd = data.(cname).line(:,3);
            
            data = addchannel_data(data,[cname,'_x'],xd,section);
            data = addchannel_data(data,[cname,'_y'],yd,section);
            data = addchannel_data(data,[cname,'_z'],zd,section);
            
            data.([cname,'_x']).event = evt;                  % transfer ecents to x only
            data.([cname,'_y']).event = struct;
            data.([cname,'_z']).event = struct;
            
            data= removechannel_data(data,{cname});
            
        end
        
    else
        disp(['ch ',ch{i} ' does not exist']) 
    end
end



