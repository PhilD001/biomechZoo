function data= removech(data,chrm)

% standalone function used primarily by BMECH_REMOVECHANNEL



for i = 1:length(chrm)

    if isfield(data,chrm{i})
    data = rmfield(data,chrm{i});
    end
end