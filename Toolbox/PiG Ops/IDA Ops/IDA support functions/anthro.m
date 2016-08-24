function ANTHRO = anthro(body,SegmentPar)

% ANTHRO returns anthropometric quantities 
%
% ARGUMENTS
%  body        ...  structured array of segment data
%  SegmentPar  ...  struct containing segment mass (%) and radius of
%                    gyration. Based on plugingait or Deleva, see main function 
%
% RETURNS
%  ANTHRO      ...  structured array containing segment mass, length, moment of
%                    inertia
%
%  Updated Jan 2nd 2007
%   -segment masses are based on DeLeva': 'Adjustments to Zatsiorsky-Seluyanov's
%   segment inertia parameters', Journal of Biomechanics, Volume 29, Issue 9, September 1996, Pages 1223-1230 Paolo de Leva
%
%
%  Updated Jan 8th 2007
%  changed ro to 1-ro 
%
%  Updated Jan 15th 2011
%  - length are output in meters
%  - Segment properties are input from SegmentPar struct. This struct is
%    built from an excel file in main vicon2ida functin


%------------------ 1- PLUGINGAIT SETUP-------------


% a) -----MASS OF SEGMENTS (kg)-------------

mass = body.bodymass;


if isfield(SegmentPar,'Femur')  % these are plugingait operations
    
    segments = {'RightThigh','LeftThigh','RightShank','LeftShank','RightFoot','LeftFoot'};
    
    M_thigh = mass*SegmentPar.Femur.mass;
    M_shank = mass*SegmentPar.Tibia.mass;
    M_foot = mass*SegmentPar.Foot.mass;
    
    M = [M_thigh M_thigh M_shank M_shank M_foot M_foot];
    
    % b) -----RADIUS OF GYRATION-----------

    ro_thigh_x = SegmentPar.Femur.RadiusGyr_x;     %ABD/ADD
    ro_thigh_y = SegmentPar.Femur.RadiusGyr_y;     %FLX/EXT
    ro_thigh_z = SegmentPar.Femur.RadiusGyr_z;     %INT/EXT

    ro_shank_x = SegmentPar.Tibia.RadiusGyr_x;
    ro_shank_y =  SegmentPar.Tibia.RadiusGyr_y;
    ro_shank_z =  SegmentPar.Tibia.RadiusGyr_z;

    ro_foot_x =  SegmentPar.Foot.RadiusGyr_x;     %ABD/ADD
    ro_foot_y = SegmentPar.Foot.RadiusGyr_y;     %Flx/Ext
    ro_foot_z = SegmentPar.Foot.RadiusGyr_z;     %INT/EXT
    

    % c)----- BONE LENGTH----------------

    %L_pelvis = magnitude(data.Pelvis.prox_end - data.Pelvis.dist_end);
    L_rthigh = magnitude(body.RightFemur.prox_end - body.RightFemur.dist_end) ;
    L_lthigh = magnitude(body.LeftFemur.prox_end - body.LeftFemur.dist_end) ;
    L_rshank = magnitude(body.RightTibia.prox_end - body.RightTibia.dist_end) ;
    L_lshank = magnitude(body.LeftTibia.prox_end - body.LeftTibia.dist_end) ;
    L_rfoot = magnitude(body.RightFoot.prox_end - body.RightFoot.dist_end) ;
    L_lfoot = magnitude(body.LeftFoot.prox_end - body.LeftFoot.dist_end) ;

    %L_pelvis = mean(L_pelvis(isfinite(L_pelvis)));
    L_rthigh = mean(L_rthigh(isfinite(L_rthigh))) ; %remove NaNs and take average in meters
    L_lthigh =  mean(L_lthigh(isfinite(L_lthigh)));
    L_rshank =  mean(L_rshank(isfinite(L_rshank)));
    L_lshank = mean(L_lshank(isfinite(L_lshank)));
    L_rfoot =  mean(L_rfoot(isfinite(L_rfoot)));
    L_lfoot = mean(L_lfoot(isfinite(L_lfoot)));

    L = [L_rthigh L_lthigh L_rshank L_lshank L_rfoot L_lfoot];
 
    for i = 1:length(segments)
        ANTHRO.(segments{i}).Mass = M(i);
        ANTHRO.(segments{i}).Length = L(i);
    end
    

    % d) MOMENT OF INERTIA---------

    ANTHRO.RightThigh.Inertia.x  = M_thigh*(L_rthigh*ro_thigh_x)^2;
    ANTHRO.RightThigh.Inertia.y  = M_thigh*(L_rthigh*ro_thigh_y)^2;
    ANTHRO.RightThigh.Inertia.z  = M_thigh*(L_rthigh*ro_thigh_z)^2;

    ANTHRO.LeftThigh.Inertia.x  = M_thigh*(L_lthigh*ro_thigh_x)^2;
    ANTHRO.LeftThigh.Inertia.y  = M_thigh*(L_lthigh*ro_thigh_y)^2;
    ANTHRO.LeftThigh.Inertia.z  = M_thigh*(L_lthigh*ro_thigh_z)^2;

    ANTHRO.RightShank.Inertia.x  = M_shank*(L_rshank*ro_shank_x)^2;
    ANTHRO.RightShank.Inertia.y  = M_shank*(L_rshank*ro_shank_y)^2;
    ANTHRO.RightShank.Inertia.z  = M_shank*(L_rshank*ro_shank_z)^2;

    ANTHRO.LeftShank.Inertia.x  = M_shank*(L_lshank*ro_shank_x)^2;
    ANTHRO.LeftShank.Inertia.y  = M_shank*(L_lshank*ro_shank_y)^2;
    ANTHRO.LeftShank.Inertia.z  = M_shank*(L_lshank*ro_shank_z)^2;

    ANTHRO.RightFoot.Inertia.x  = M_foot*(L_rfoot*ro_foot_x)^2;
    ANTHRO.RightFoot.Inertia.y  = M_foot*(L_rfoot*ro_foot_y)^2;
    ANTHRO.RightFoot.Inertia.z  = M_foot*(L_rfoot*ro_foot_z)^2;

    ANTHRO.LeftFoot.Inertia.x  = M_foot*(L_lfoot*ro_foot_x)^2;
    ANTHRO.LeftFoot.Inertia.y  = M_foot*(L_lfoot*ro_foot_y)^2;
    ANTHRO.LeftFoot.Inertia.z  = M_foot*(L_lfoot*ro_foot_z)^2;
    
end


%-------------------2-  FOR OXFORD FOOT MODEL ------------------

% a) -----MASS OF SEGMENTS (kg)-------------

if isfield(SegmentPar,'HindFoot')
    
    segments = {'RightShankOFM','LeftShankOFM','RightHindFoot','LeftHindFoot','RightForeFoot','LeftForeFoot'};
    
    M_shank =mass*SegmentPar.TibiaOFM.mass;
    M_hindfoot = mass*SegmentPar.HindFoot.mass;
    M_forefoot = mass*SegmentPar.ForeFoot.mass;

    M = [M_shank M_shank M_hindfoot M_hindfoot M_forefoot M_forefoot];
    % b) -----RADIUS OF GYRATION-----------
    
    ro_shank_x = SegmentPar.TibiaOFM.RadiusGyr_x;
    ro_shank_y =  SegmentPar.TibiaOFM.RadiusGyr_y;
    ro_shank_z =  SegmentPar.TibiaOFM.RadiusGyr_z;

    ro_forefoot_x =  SegmentPar.ForeFoot.RadiusGyr_x;     %ABD/ADD
    ro_forefoot_y = SegmentPar.ForeFoot.RadiusGyr_y;     %Flx/Ext
    ro_forefoot_z = SegmentPar.ForeFoot.RadiusGyr_z;     %INT/EXT

    ro_hindfoot_x =  SegmentPar.HindFoot.RadiusGyr_x;     %ABD/ADD
    ro_hindfoot_y = SegmentPar.HindFoot.RadiusGyr_y;     %Flx/Ext
    ro_hindfoot_z = SegmentPar.HindFoot.RadiusGyr_z;     %INT/EXT
    

    
    % c)----- BONE LENGTH----------------
  
    L_rshank = magnitude(body.RightTibiaOFM.prox_end - body.RightTibiaOFM.dist_end) ;
    L_lshank = magnitude(body.LeftTibiaOFM.prox_end - body.LeftTibiaOFM.dist_end) ;   
    L_rhindfoot = magnitude(body.RightHindFoot.prox_end - body.RightHindFoot.dist_end) ;
    L_lhindfoot = magnitude(body.LeftHindFoot.prox_end - body.LeftHindFoot.dist_end) ;
    L_rforefoot = magnitude(body.RightForeFoot.prox_end - body.RightForeFoot.dist_end) ;
    L_lforefoot = magnitude(body.LeftForeFoot.prox_end - body.LeftForeFoot.dist_end) ;

    L_rshank =  mean(L_rshank(isfinite(L_rshank)));
    L_lshank = mean(L_lshank(isfinite(L_lshank)));
    L_rhindfoot =  mean(L_rhindfoot(isfinite(L_rhindfoot)));
    L_lhindfoot = mean(L_lhindfoot(isfinite(L_lhindfoot)));
    L_rforefoot =  mean(L_rforefoot(isfinite(L_rforefoot)));
    L_lforefoot = mean(L_lforefoot(isfinite(L_lforefoot)));

    L = [L_rshank  L_lshank  L_rhindfoot L_lhindfoot L_rforefoot L_lforefoot];

    for i = 1:length(segments)
        ANTHRO.(segments{i}).Mass = M(i);
        ANTHRO.(segments{i}).Length = L(i);
    end
    

    % d) MOMENT OF INERTIA---------


    ANTHRO.RightShankOFM.Inertia.x  = M_shank*(L_rshank*ro_shank_x)^2;
    ANTHRO.RightShankOFM.Inertia.y  = M_shank*(L_rshank*ro_shank_y)^2;
    ANTHRO.RightShankOFM.Inertia.z  = M_shank*(L_rshank*ro_shank_z)^2;

    ANTHRO.LeftShankOFM.Inertia.x  = M_shank*(L_lshank*ro_shank_x)^2;
    ANTHRO.LeftShankOFM.Inertia.y  = M_shank*(L_lshank*ro_shank_y)^2;
    ANTHRO.LeftShankOFM.Inertia.z  = M_shank*(L_lshank*ro_shank_z)^2;

    ANTHRO.RightHindFoot.Inertia.x  = M_hindfoot*(L_rhindfoot*ro_hindfoot_x)^2;
    ANTHRO.RightHindFoot.Inertia.y  = M_hindfoot*(L_rhindfoot*ro_hindfoot_y)^2;
    ANTHRO.RightHindFoot.Inertia.z  = M_hindfoot*(L_rhindfoot*ro_hindfoot_z)^2;

    ANTHRO.LeftHindFoot.Inertia.x  = M_hindfoot*(L_lhindfoot*ro_hindfoot_x)^2;
    ANTHRO.LeftHindFoot.Inertia.y  = M_hindfoot*(L_lhindfoot*ro_hindfoot_y)^2;
    ANTHRO.LeftHindFoot.Inertia.z  = M_hindfoot*(L_lhindfoot*ro_hindfoot_z)^2;


    ANTHRO.RightForeFoot.Inertia.x  = M_forefoot*(L_rforefoot*ro_forefoot_x)^2;
    ANTHRO.RightForeFoot.Inertia.y  = M_forefoot*(L_rforefoot*ro_forefoot_y)^2;
    ANTHRO.RightForeFoot.Inertia.z  = M_forefoot*(L_rforefoot*ro_forefoot_z)^2;

    ANTHRO.LeftForeFoot.Inertia.x  = M_forefoot*(L_lforefoot*ro_forefoot_x)^2;
    ANTHRO.LeftForeFoot.Inertia.y  = M_forefoot*(L_lforefoot*ro_forefoot_y)^2;
    ANTHRO.LeftForeFoot.Inertia.z  = M_forefoot*(L_lforefoot*ro_forefoot_z)^2;
    
    
end

