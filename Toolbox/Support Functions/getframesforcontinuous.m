
function [frames,indx] = getframesforcontinuous(fl,ch)

indx = [];
data = zload(fl{1});


if isfield(data.zoosystem.Video,'Indx') && ~isin(ch,'OFM')
    frames =  data.zoosystem.Video.Indx;
    
elseif isin(ch,'OFM') && ~isempty(isnan(data.(ch).line))
    indx = find(~isnan(data.(ch).line),1,'first');
    frames =  data.zoosystem.Video.Indx;
else
    frames = 1:1:length(data.(ch).line);
end