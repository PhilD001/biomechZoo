function AKIN = angular_kin(LKIN,fsamp,f)

% ANGULAR_KIN returns angular kinematic quantities required for inverse dynamics 
%
% ARGUMENTS
%
% LKIN    ...  linear kinematics
% fsamp   ...  sampling rate of signal
% f       ...  choice of filtering 0 = no, 1 = yes (with default) or f =
%                struct with filter properties (see bmech filter)
%
% RETURNS
%
% AKIN  ...   structured array containing grood
%             and suntay axes, euler axes, segment angular velocity and
%             accelerations. ALL IN LOCAL
%
%
%  Created May 2008 by Phil Dixon
%
% updated January 2011
% - channel names in variable KIN were changed by vicon2groodsuntay.
%   Changes are reflected here. 
% - future update required to account for oxford model
%
% Updated February 2011
% - Joint kinematics are not needed for any IDA calculations. Removed input
% KIN from function and joint kinematics are not included in AKIN
%
% Updated August 2013
% - user has control over choice of filtering


%--------- 1 - PLUGINGAIT BONES---------

%-a) SET GROOD AND SUNTAY AXES------


k_pelvis =LKIN.Pelvis.Axes.k;

i1 =LKIN.RightThigh.Axes.i;
k1 =LKIN.RightThigh.Axes.k;

i2 =LKIN.LeftThigh.Axes.i;
k2 =LKIN.LeftThigh.Axes.k;

i3 =LKIN.RightShank.Axes.i;
k3 =LKIN.RightShank.Axes.k;

i4 =LKIN.LeftShank.Axes.i;
k4 =LKIN.LeftShank.Axes.k;

i5 =LKIN.RightFoot.Axes.i;

i6 =LKIN.LeftFoot.Axes.i; 



i_dist_rh = i1;                     %Right Hip                         
k_prox_rh = k_pelvis;
l_rh = cross(k_prox_rh,i_dist_rh,2);

i_dist_lh = i2;                     %Left Hip                         
k_prox_lh = k_pelvis;
l_lh = cross(k_prox_lh,i_dist_lh,2);

i_dist_rk = i3;                     %Right knee                        
k_prox_rk = k1;
l_rk = cross(k_prox_rk,i_dist_rk,2);

i_dist_lk = i4;                     %left knee
k_prox_lk = k2;
l_lk =  cross(k_prox_lk,i_dist_lk,2);                                           
                                            
i_dist_ra = i5;                     %Right ankle                    
k_prox_ra = k3;
l_ra = cross(k_prox_ra,i_dist_ra,2);

i_dist_la = i6;                     %Left ankle                       
k_prox_la = k4;
l_la = cross(k_prox_la,i_dist_la,2);



AKIN.RightThigh.GSAxes.i = i_dist_rh;  
AKIN.RightThigh.GSAxes.k = k_prox_rh;  
AKIN.RightThigh.GSAxes.l = l_rh ;  

AKIN.LeftThigh.GSAxes.i  =  i_dist_lh;
AKIN.LeftThigh.GSAxes.k  =  k_prox_lh;
AKIN.LeftThigh.GSAxes.l  =  l_lh;

AKIN.RightShank.GSAxes.i =  i_dist_rk;
AKIN.RightShank.GSAxes.k =  k_prox_rk;
AKIN.RightShank.GSAxes.l =  l_rk;

AKIN.LeftShank.GSAxes.i =   i_dist_lk;
AKIN.LeftShank.GSAxes.k =   k_prox_lk;
AKIN.LeftShank.GSAxes.l =   l_lk;

AKIN.RightFoot.GSAxes.i =   i_dist_ra;
AKIN.RightFoot.GSAxes.k =   k_prox_ra;
AKIN.RightFoot.GSAxes.l =   l_ra;

AKIN.LeftFoot.GSAxes.i  =   i_dist_la;
AKIN.LeftFoot.GSAxes.k  =   k_prox_la;
AKIN.LeftFoot.GSAxes.l  =   l_la;



%---b) SET EULER ANGLES-----------

segments = {'RightThigh','LeftThigh','RightShank','LeftShank','RightFoot', 'LeftFoot'};

Euler=euler(LKIN,fsamp,f);

for i = 1:length(segments)
   AKIN.(segments{i}).EulerAngles = Euler.(segments{i});
end

AKIN.Pelvis.EulerAngles = Euler.Pelvis;
    

for i = 1:length(segments)
   AKIN.(segments{i}).AngVel = ang_velocity(Euler.(segments{i}),fsamp,f);
   AKIN.(segments{i}).AngAcc = ang_acc(Euler.(segments{i}),fsamp,f);  % ang_vel properly organises angles so ang_Acc doesn't have to
end


% please check!
AKIN.Pelvis.AngVel = ang_velocity(Euler.Pelvis,fsamp,f);
AKIN.Pelvis.AngAcc = ang_acc(Euler.Pelvis,fsamp,f);   




%--------- 2 - OXFORD FOOT MODEL BONES---------


if isfield(LKIN,'RightForeFoot')

   
    %-a) SET GROOD AND SUNTAY AXES------
    
   % PLESE CHECK THESE AXES

    iRTIB =LKIN.RightShankOFM.Axes.i;
    kRTIB =LKIN.RightShankOFM.Axes.k;

    iLTIB =LKIN.LeftShankOFM.Axes.i;
    kLTIB =LKIN.LeftShankOFM.Axes.k;

    iRHF =LKIN.RightHindFoot.Axes.i;
    kRHF =LKIN.RightHindFoot.Axes.k;

    iLHF =LKIN.LeftHindFoot.Axes.i;
    kLHF =LKIN.LeftHindFoot.Axes.k;
    
    iRFF =LKIN.RightForeFoot.Axes.i;
        
    iLFF =LKIN.LeftForeFoot.Axes.i;

    i_dist_rk = iRTIB;                     %Right knee
    k_prox_rk = k1;
    l_rk = cross(k_prox_rk,i_dist_rk,2);

    i_dist_lk = iLTIB;                     %left knee
    k_prox_lk = k2;
    l_lk =  cross(k_prox_lk,i_dist_lk,2);

    i_dist_ra = iRHF;                     %Right ankleOFM
    k_prox_ra = kRTIB;
    l_ra = cross(k_prox_ra,i_dist_ra,2);

    i_dist_la = iLHF;                     %Left ankleOFM
    k_prox_la = kLTIB;
    l_la = cross(k_prox_la,i_dist_la,2);


    i_dist_rmf = iRFF;                     %Right Midfoot
    k_prox_rmf = kRHF;
    l_rmf = cross(k_prox_rmf, i_dist_rmf,2);

    i_dist_lmf = iLFF;                     %Right Midfoot
    k_prox_lmf = kLHF;
    l_lmf = cross(k_prox_lmf,i_dist_lmf,2);
    
    
    AKIN.RightShankOFM.GSAxes.i =  i_dist_rk;
    AKIN.RightShankOFM.GSAxes.k =  k_prox_rk;
    AKIN.RightShankOFM.GSAxes.l =  l_rk;

    AKIN.LeftShankOFM.GSAxes.i =   i_dist_lk;
    AKIN.LeftShankOFM.GSAxes.k =   k_prox_lk;
    AKIN.LeftShankOFM.GSAxes.l =   l_lk;

    AKIN.RightHindFoot.GSAxes.i =   i_dist_ra;
    AKIN.RightHindFoot.GSAxes.k =   k_prox_ra;
    AKIN.RightHindFoot.GSAxes.l =   l_ra;

    AKIN.LeftHindFoot.GSAxes.i  =   i_dist_la;
    AKIN.LeftHindFoot.GSAxes.k  =   k_prox_la;
    AKIN.LeftHindFoot.GSAxes.l  =   l_la;

    AKIN.RightForeFoot.GSAxes.i =   i_dist_rmf;
    AKIN.RightForeFoot.GSAxes.k =   k_prox_rmf;
    AKIN.RightForeFoot.GSAxes.l =   l_rmf;

    AKIN.LeftForeFoot.GSAxes.i  =   i_dist_lmf;
    AKIN.LeftForeFoot.GSAxes.k  =   k_prox_lmf;
    AKIN.LeftForeFoot.GSAxes.l  =   l_lmf;
    
    

    %---b) SET EULER ANGLES-----------

     segments = {'RightShankOFM','LeftShankOFM','RightHindFoot','LeftHindFoot', 'RightForeFoot','LeftForeFoot'};
    
    Euler=euler(LKIN,fsamp,f);

    for i = 1:length(segments)
        AKIN.(segments{i}).EulerAngles = Euler.(segments{i});
    end


    %-- c) SET SEGMENT ANGULAR VELOCITY & ACCELERATION (LOCAL)-------------

    for i = 1:length(segments)
        AKIN.(segments{i}).AngVel = ang_velocity(Euler.(segments{i}),fsamp,f);
        AKIN.(segments{i}).AngAcc = ang_acc(Euler.(segments{i}),fsamp,f);
    end




end



