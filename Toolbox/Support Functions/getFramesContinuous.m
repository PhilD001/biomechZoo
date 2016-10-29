function [frames,indx] = getFramesContinuous(fl,ch)

indx = [];
data = zload(fl{1});

frames = 1:1:length(data.(ch).line);
