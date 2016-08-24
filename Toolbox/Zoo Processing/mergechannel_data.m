function data = mergechannel_data(data,ch)

% data = MERGECHANNEL_DATA(data,ch) explodes channels
%
% ARGUMENTS
%  data     ...  Zoo file 
%  ch       ...  Channel(s) to operate on (cell array of 3 strings) 

% 
% RETURNS
%  data     ...  Zoo file with merged channel appended (and exploded channels removed) 


% NOTES
% - existing events are transferred to the '_x' dimension
% - Appropriate section (video or analog) determined automatically
%
% See also bmech_merge


% Revision history
%
% Created by Philippe C. Dixon July 2016






if length(ch) ~= 3
    error('merge triplets only x y z')
end

% Process
%

if isfield(data,ch{1})
    r = zeros(length(data.(ch{1}).line),3);
    section = getsection(data,ch(1));

    for i = 1:length(ch);
        r(:,i) = data.(ch{i}).line;
        data= removechannel_data(data,(ch{i}));
    end
    
    nch = strrep(ch{1},'_x','');
    data = addchannel_data(data,(nch),r,section);  
end

