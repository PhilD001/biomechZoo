function [DYNAMICS,Tz] = dynamics(ANTHRO,LKIN,COM,AKIN,COP,Tz,data,g,mass)


%   1) LOAD ANALOG DATA 
%
%   load downsampled & filtered analog data from zoo2ida

F = [data.fx1 data.fy1 data.fz1 data.fx2 data.fy2 data.fz2];    % N
T = [data.mx1 data.my1 data.mz1 data.mx2 data.my2 data.mz2];    % N*m

%   2) POSITION OF COP DATA -------------
%
%           -COP (m)
%           -values are in each plate's coordinate system
%                                   
%                                   5003.2 plate 1



%   3) CONVERT FORCES/MOMENTS TO ACTION ORIENTED SYSTEM--------

F = F.*-1; 
       
F_1plate = F(:,1:3);            
F_2plate = F(:,4:6);

T_1plate = T(:,1:3);            
T_2plate = T(:,4:6);





COP1 = COP.COP1ida;
COP2 = COP.COP2ida;

Tz1 = (Tz.Tz1).*-1;
Tz2 = (Tz.Tz2).*-1;

%   4) FORCE CALCULATIONS



F_rankle = F_segment(ANTHRO.Segment.RightFoot.Mass,COM.Segment.RightFoot.Acc, F_1plate,       AKIN.Segment.RightFoot.GSAxes,  g);  %matrix 1-3 column XYZ 4-6 column segment based
F_lankle = F_segment(ANTHRO.Segment.LeftFoot.Mass, COM.Segment.LeftFoot.Acc,  F_2plate,       AKIN.Segment.LeftFoot.GSAxes,   g);

F_rknee = F_segment(ANTHRO.Segment.RightShank.Mass,COM.Segment.RightShank.Acc,F_rankle(:,1:3),AKIN.Segment.RightShank.GSAxes, g);
F_lknee = F_segment(ANTHRO.Segment.LeftShank.Mass, COM.Segment.LeftShank.Acc, F_lankle(:,1:3),AKIN.Segment.LeftShank.GSAxes,  g);

F_rhip = F_segment(ANTHRO.Segment.RightThigh.Mass, COM.Segment.RightThigh.Acc,F_rknee(:,1:3), AKIN.Segment.RightThigh.GSAxes, g);
F_lhip= F_segment(ANTHRO.Segment.LeftThigh.Mass,   COM.Segment.LeftThigh.Acc, F_lknee(:,1:3), AKIN.Segment.LeftThigh.GSAxes,  g);


%   4) MOMENT CALCULATIONS------------------

M_rankle = M_foot(F_1plate,F_rankle(:,1:3),Tz1,LKIN.Segment.RightFoot.AnkleJoint,COP1,COM.Segment.RightFoot.Pos,ANTHRO.Segment.RightFoot.Inertia,AKIN.Segment.RightFoot.AngVel, AKIN.Segment.RightFoot.AngAcc,LKIN.Segment.RightFoot.Axes,AKIN.Segment.RightFoot.GSAxes);                                                                                                                  
M_lankle = M_foot(F_2plate,F_lankle(:,1:3),Tz2,LKIN.Segment.LeftFoot.AnkleJoint, COP2,COM.Segment.LeftFoot.Pos, ANTHRO.Segment.LeftFoot.Inertia, AKIN.Segment.LeftFoot.AngVel, AKIN.Segment.LeftFoot.AngAcc,  LKIN.Segment.LeftFoot.Axes, AKIN.Segment.LeftFoot.GSAxes ); 

M_rknee = M_segment(F_rankle(:,1:3), F_rknee(:,1:3),M_rankle(:,1:3),LKIN.Segment.RightFoot.AnkleJoint,LKIN.Segment.RightShank.KneeJoint, COM.Segment.RightShank.Pos, ANTHRO.Segment.RightShank.Inertia,AKIN.Segment.RightShank.AngVel, AKIN.Segment.RightShank.AngAcc,LKIN.Segment.RightShank.Axes,AKIN.Segment.RightShank.GSAxes );                                                                                                                                                                        
M_lknee = M_segment(F_lankle(:,1:3), F_lknee(:,1:3),M_lankle(:,1:3),LKIN.Segment.LeftFoot.AnkleJoint, LKIN.Segment.LeftShank.KneeJoint,  COM.Segment.LeftShank.Pos,  ANTHRO.Segment.LeftShank.Inertia, AKIN.Segment.LeftShank.AngVel, AKIN.Segment.LeftShank.AngAcc, LKIN.Segment.LeftShank.Axes, AKIN.Segment.LeftShank.GSAxes);

M_rhip = M_segment(F_rknee(:,1:3),   F_rhip(:,1:3), M_rknee(:,1:3), LKIN.Segment.RightShank.KneeJoint,LKIN.Segment.RightThigh.HipJoint, COM.Segment.RightThigh.Pos,  ANTHRO.Segment.RightThigh.Inertia,AKIN.Segment.RightThigh.AngVel, AKIN.Segment.RightThigh.AngAcc,LKIN.Segment.RightThigh.Axes,AKIN.Segment.RightThigh.GSAxes);
M_lhip = M_segment(F_lknee(:,1:3),   F_lhip(:,1:3), M_lknee(:,1:3), LKIN.Segment.LeftShank.KneeJoint, LKIN.Segment.LeftThigh.HipJoint,  COM.Segment.LeftThigh.Pos,   ANTHRO.Segment.LeftThigh.Inertia, AKIN.Segment.LeftThigh.AngVel, AKIN.Segment.LeftThigh.AngAcc, LKIN.Segment.LeftThigh.Axes, AKIN.Segment.LeftThigh.GSAxes );


%   5) ---------------POWER CALCULATIONS---------------

P_rankle= P_segment(M_rankle(:,4:6),AKIN.Segment.RightFoot.AngVel); 
P_lankle = P_segment(M_lankle(:,4:6),AKIN.Segment.LeftFoot.AngVel);

P_rknee = P_segment(M_rknee(:,4:6),AKIN.Segment.RightShank.AngVel);
P_lknee = P_segment(M_lknee(:,4:6),AKIN.Segment.LeftShank.AngVel);

P_rhip = P_segment(M_rhip(:,4:6),AKIN.Segment.RightThigh.AngVel);
P_lhip = P_segment(M_lhip(:,4:6),AKIN.Segment.LeftThigh.AngVel);


%-------------------NORMALIZE TO MASS----------------



F_1plate = F_1plate/mass;            %all subjects striked fp1 with right foot
F_2plate = F_2plate/mass;

T_1plate = T_1plate/mass; 
T_2plate = T_2plate/mass; 

Tz1 = Tz1/mass;
Tz2 = Tz2/mass;

F_rankle = F_rankle/mass;
F_lankle = F_lankle/mass;
F_rknee =F_rknee/mass;
F_lknee = F_lknee/mass;
F_rhip = F_rhip/mass;
F_lhip =F_lhip/mass;

M_rankle =M_rankle/mass;
M_lankle =M_lankle/mass;
M_rknee =M_rknee/mass;
M_lknee =M_lknee/mass;
M_rhip =M_rhip/mass;
M_lhip =M_lhip/mass;

P_rankle =P_rankle/mass;
P_lankle =P_lankle/mass;
P_rknee =P_rknee/mass;
P_lknee =P_lknee/mass;
P_rhip =P_rhip/mass;
P_lhip =P_lhip/mass;



%-----------EXPORT JOINT DYNAMICS AS STRUCT------------
%
%   Units:      Force:    N/m/kg
%               Moments:  N*m/kg
%               Power:    W/kg


Tz =struct;

Tz.Tz1 = Tz1;
Tz.Tz2 = Tz2;


DYNAMICS= struct;


DYNAMICS.ForcePlate1.Force = F_1plate(:,1:3);
DYNAMICS.ForcePlate1.Moment = T_1plate(:,1:3);

DYNAMICS.ForcePlate2.Force = F_2plate(:,1:3);
DYNAMICS.ForcePlate2.Moment = T_2plate(:,1:3);

DYNAMICS.RightAnkle.Force = F_rankle(:,4:6);
DYNAMICS.RightAnkle.Moment.InvEve = M_rankle(:,4);
DYNAMICS.RightAnkle.Moment.PlaDor = M_rankle(:,5);
DYNAMICS.RightAnkle.Moment.VarVal = M_rankle(:,6);
DYNAMICS.RightAnkle.Power = P_rankle;

DYNAMICS.LeftAnkle.Force =F_lankle(:,4:6);
DYNAMICS.LeftAnkle.Moment.InvEve= M_lankle(:,4);
DYNAMICS.LeftAnkle.Moment.PlaDor= M_lankle(:,5);
DYNAMICS.LeftAnkle.Moment.VarVal= M_lankle(:,6);
DYNAMICS.LeftAnkle.Power = P_lankle;

DYNAMICS.RightKnee.Force = F_rknee(:,4:6);
DYNAMICS.RightKnee.Moment.IntExt = M_rknee(:,4);
DYNAMICS.RightKnee.Moment.FlxExt = M_rknee(:,5);
DYNAMICS.RightKnee.Moment.AbdAdd = M_rknee(:,6);
DYNAMICS.RightKnee.Power = P_rknee;

DYNAMICS.LeftKnee.Force =F_lknee(:,4:6);
DYNAMICS.LeftKnee.Moment.IntExt = M_lknee(:,4);
DYNAMICS.LeftKnee.Moment.FlxExt = M_lknee(:,5);
DYNAMICS.LeftKnee.Moment.AbdAdd = M_lknee(:,6);
DYNAMICS.LeftKnee.Power = P_lknee;

DYNAMICS.RightHip.Force = F_rhip(:,4:6);
DYNAMICS.RightHip.Moment.IntExt = M_rhip(:,4);
DYNAMICS.RightHip.Moment.FlxExt = M_rhip(:,5);
DYNAMICS.RightHip.Moment.AbdAdd = M_rhip(:,6);
DYNAMICS.RightHip.Power = P_rhip;

DYNAMICS.LeftHip.Force =F_lhip(:,4:6);
DYNAMICS.LeftHip.Moment.IntExt = M_lhip(:,4);
DYNAMICS.LeftHip.Moment.FlxExt = M_lhip(:,5);
DYNAMICS.LeftHip.Moment.AbdAdd = M_lhip(:,6);
DYNAMICS.LeftHip.Power = P_lhip;

