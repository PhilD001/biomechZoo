function ndata = keepchannel(data,chkp)

% stanalone function used primarily by BMECH_REMOVECHANNEL


% Revision History
%
% Updated by Philippe C. Dixon May 2015
% - fixed bug with vector size

v_list = cell(size(chkp));
a_list = cell(size(chkp));

for i = 1:length(chkp)
    
    if isfield(data,chkp{i})
        ndata.(chkp{i})=data.(chkp{i});
    end
    
    if isin(data.zoosystem.Video.Channels,chkp{i})
        v_list{i}  = chkp{i};
        
    elseif isin(data.zoosystem.Analog.Channels,chkp{i})
        a_list{i}  = chkp{i};
        
    else
        error('missing appropriate section fieldname in zoosystem')
    end
    
end

ndata.zoosystem = data.zoosystem;  % copy metainfo

v_list(cellfun(@isempty,v_list)) = [];
a_list(cellfun(@isempty,a_list)) = [];

v_list = makecolumn(v_list);
a_list = makecolumn(a_list);

if isempty(v_list)
    ndata.zoosystem.Video.Channels = {};
else
    ndata.zoosystem.Video.Channels = v_list;
end


if isempty(a_list)
    ndata.zoosystem.Analog.Channels = {};
else
    ndata.zoosystem.Analog.Channels = a_list;
end


