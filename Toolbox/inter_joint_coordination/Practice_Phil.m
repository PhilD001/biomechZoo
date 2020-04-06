
function Practice_Phil

%% This is set up to use Hip and Knee data

%% Step 0: Load data
%
fld = fileparts(which('Practice_Phil'));          % get root Zoosystem folder
hip = load([fld, filesep, 'left_hip_data.mat']);
knee = load([fld, filesep, 'left_knee_data.mat']);
left_hip_stk = hip.left_hip_stk;
left_knee_stk = knee.left_knee_stk;

figure; hold on
plot(left_hip_stk')
title('LHipAngles_x')

%% Step 1: Determine Phase Angles

figure;hold on

for i=1:size(left_hip_stk,1)
    data=left_hip_stk(i,:);
    PA_hip(i,:)=Phase_Angle(data,32,94);
    plot(PA_hip')
    title('Phase Angle Hip')
end

figure; hold on

for i=1:size(left_knee_stk,1)
    data=left_knee_stk(i,:);
    PA_knee(i,:)=Phase_Angle(data,32,94);
    plot(PA_knee')
    title('Phase Angle Knee')
end

%% Step 2: Determine CRP

for i=1:size(PA_hip,1)
    data_prox=PA_hip(i,:);
    data_dist=PA_knee(i,:);
    CRP_Knee_Hip(i,:)=CRP(data_dist,data_prox);
end

%% Step 3: Determine CRP stats

figure; hold on

plot(CRP_Knee_Hip')
title('CRP Angle Knee-Hip')

[MARP,DP]=CRP_stats(CRP_Knee_Hip);
figure;hold on
title('MARP and DP')
plot(MARP, 'LineWidth',2)
plot(DP, 'LineWidth',2)
legend ('MARP','DP')