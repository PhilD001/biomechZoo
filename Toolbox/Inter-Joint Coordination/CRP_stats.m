function [MARP,DP] = CRP_stats(CRP)

%This determines CRP stats: Mean Absolute Relative Phase (MARP) and
%Deviation Phase (DP)

MARP=nanmean(CRP);
DP=nanstd(CRP);

end

