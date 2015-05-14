function ndata = keepch(data,chkp)

% stanalone function used primarily by BMECH_REMOVECHANNEL


for i = 1:length(chkp)
    
     if isfield(data,chkp{i})
       ndata.(chkp{i})=data.(chkp{i});
     end

end

    ndata.zoosystem = data.zoosystem;

