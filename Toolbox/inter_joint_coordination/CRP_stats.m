function [MARP,DP] = CRP_stats(CRP)

%This determines CRP stats: Mean Absolute Relative Phase (MARP) and
%Deviation Phase (DP)

MARP=mean(CRP);
DP=std(CRP);

end

