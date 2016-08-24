% LOAD all structs for vicon2ida

clc
clear all   % this is a script after all

%----SETTINGS---
fsamp = 50;
g = [0 0 9.82];

%---LOAD INPUT VARIABLES---

ANTHROvar   % ANTHRO

KINvar     % KIN

LKINvar    % LKIN

COMvar     % COM

FPvar      % FORCE PLATES

AKIN = angular_kin(LKIN,KIN,fsamp);  % make AKIN using my variables


% ---LOAD DYNAMIC OUTPUT VARIABLES TO CHECK CODE---

DYNvar    % Force plate

%---RUN CALCULATIONS---


F_ranklePG = F_foot(ANTHRO.RightFoot.Mass, COM.RightFoot.Acc, FR, g, LKIN,AKIN.RightFoot.GSAxes,'RightFoot','vaughan');  %matrix 1-3 column XYZ 4-6 column segment based
F_lanklePG = F_foot(ANTHRO.LeftFoot.Mass,  COM.LeftFoot.Acc,  FL, g, LKIN,AKIN.LeftFoot.GSAxes,'LeftFoot','vaughan');

M_ranklePG = M_foot(FR,F_ranklePG(:,1:3),TzR,LKIN.RightFoot.AnkleJoint,COPRg,COM.RightFoot.Pos,ANTHRO.RightFoot.Inertia,AKIN.RightFoot.AngVel, AKIN.RightFoot.AngAcc,AKIN.RightFoot.GSAxes,LKIN,'RightFoot','vaughan');
M_lanklePG = M_foot(FL,F_lanklePG(:,1:3),TzL,LKIN.LeftFoot.AnkleJoint, COPLg,COM.LeftFoot.Pos, ANTHRO.LeftFoot.Inertia, AKIN.LeftFoot.AngVel, AKIN.LeftFoot.AngAcc, AKIN.LeftFoot.GSAxes,LKIN,'LeftFoot','vaughan' );


% % b) KNEE
% 
% F_rkneePG = F_segment(ANTHRO.RightShankPG.Mass,COM.RightShankPG.Acc,F_ranklePG(:,1:3),  g,LKIN,'RightShankPG','vaughan');
% F_lkneePG = F_segment(ANTHRO.LeftShankPG.Mass, COM.LeftShankPG.Acc, F_lanklePG(:,1:3),  g,LKIN,'LeftShankPG','vaughan');
% 
% M_rkneePG = M_segment(F_ranklePG(:,1:3), F_rkneePG(:,1:3),M_ranklePG(:,1:3),LKIN.RightFoot.AnkleJoint,LKIN.RightShankPG.KneeJoint, COM.RightShankPG.Pos, ANTHRO.RightShankPG.Inertia,AKIN.RightShankPG.AngVel, AKIN.RightShankPG.AngAcc,AKIN.RightShankPG.GSAxes,LKIN,'RightShankPG','vaughan' );                                                                                                                                                                        
% M_lkneePG = M_segment(F_lanklePG(:,1:3), F_lkneePG(:,1:3),M_lanklePG(:,1:3),LKIN.LeftFoot.AnkleJoint, LKIN.LeftShankPG.KneeJoint,  COM.LeftShankPG.Pos,  ANTHRO.LeftShankPG.Inertia, AKIN.LeftShankPG.AngVel, AKIN.LeftShankPG.AngAcc,AKIN.LeftShankPG.GSAxes,LKIN,'LeftShankPG','vaughan');
% 
% % c) HIP
% F_rhipPG = F_segment(ANTHRO.RightThigh.Mass, COM.RightThigh.Acc,F_rkneePG(:,1:3),  g, LKIN, 'RightThigh','vaughan');
% F_lhipPG= F_segment(ANTHRO.LeftThigh.Mass,   COM.LeftThigh.Acc, F_lkneePG(:,1:3),  g, LKIN, 'LeftThigh','vaughan');
% 
% M_rhipPG = M_segment(F_rkneePG(:,1:3),   F_rhipPG(:,1:3), M_rkneePG(:,1:3), LKIN.RightShankPG.KneeJoint,LKIN.RightThigh.HipJoint, COM.RightThigh.Pos,  ANTHRO.RightThigh.Inertia,AKIN.RightThigh.AngVel, AKIN.RightThigh.AngAcc,AKIN.RightThigh.GSAxes,LKIN,'RightThigh','vaughan');
% M_lhipPG = M_segment(F_lkneePG(:,1:3),   F_lhipPG(:,1:3), M_lkneePG(:,1:3), LKIN.LeftShankPG.KneeJoint, LKIN.LeftThigh.HipJoint,  COM.LeftThigh.Pos,   ANTHRO.LeftThigh.Inertia, AKIN.LeftThigh.AngVel, AKIN.LeftThigh.AngAcc,AKIN.LeftThigh.GSAxes,LKIN,'LeftThigh','vaughan' );


%   5) ---------------POWER CALCULATIONS UNCHECKED---------------

% RUN Vaughan  power with all his variables

% SEGvar  % load Vaughans variables for power


P_ranklePG= P_segment(RightAnkleMoment,AKIN.RightFoot.AngVel,AKIN.RightShankPG.AngVel,LKIN.RightFoot.Axes, LKIN.RightShankPG.Axes); 
P_lanklePG = P_segment(LeftAnkleMoment,AKIN.LeftFoot.AngVel,AKIN.LeftShankPG.AngVel, LKIN.LeftFoot.Axes,  LKIN.LeftShankPG.Axes);
% 



% P_ranklePG= P_segment(M_ranklePG(:,1:3),AKIN.RightFoot.AngVel,AKIN.RightShankPG.AngVel,LKIN.RightFoot.Axes, LKIN.RightShankPG.Axes); 
% P_lanklePG = P_segment(M_lanklePG(:,1:3),AKIN.LeftFoot.AngVel,AKIN.LeftShankPG.AngVel, LKIN.LeftFoot.Axes,  LKIN.LeftShankPG.Axes);
% % 
% P_rkneePG = P_segment(M_rkneePG(:,1:3),AKIN.RightShankPG.AngVel,AKIN.RightThigh.AngVel,LKIN.RightShankPG.Axes, LKIN.RightThigh.Axes);
% P_lkneePG = P_segment(M_lkneePG(:,1:3),AKIN.LeftShankPG.AngVel,AKIN.LeftThigh.AngVel,  LKIN.LeftShankPG.Axes,  LKIN.LeftThigh.Axes);
% 
% P_rhipPG = P_segment(M_rhipPG(:,1:3), AKIN.RightThigh.AngVel,AKIN.Pelvis.AngVel, LKIN.RightThigh.Axes, LKIN.Pelvis.Axes);
% P_lhipPG = P_segment(M_lhipPG(:,1:3), AKIN.LeftThigh.AngVel, AKIN.Pelvis.AngVel, LKIN.LeftThigh.Axes,   LKIN.Pelvis.Axes);

