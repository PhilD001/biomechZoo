function ANTHRO = anthro(body,segmentPar)

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
%  Updated by Philippe C. Dixon Jan 8th 2007
%  changed ro to 1-ro
%
%  Updated by Philippe C. Dixon Jan 15th 2011
%  - length are output in meters
%  - Segment properties are input from SegmentPar struct. This struct is
%    built from an excel file in main vicon2ida functin
%
% Updated by Philippe C. Dixon October 2016
% - improved code to avoid bone/segment mismatch
%
% Updated by Philippe C. Dixon Nov 2017
% - corrected error in moment of inertia calculation


%------------------ 1- PLUGINGAIT SETUP-------------


% a) -----MASS OF SEGMENTS (kg)-------------

mass = body.bodymass;

ANTHRO = struct;
ANTHRO.bodymass = mass;


bones = setdiff(fieldnames(body),{'bodymass','fsamp'});

for i = 1:length(bones)
    
    if strfind(bones{i},'Right')
        bone = strrep(bones{i},'Right','');
        side = 'Right';
    elseif strfind(bones{i},'Left')
        bone = strrep(bones{i},'Left','');
        side = 'Left';
    end
    
    
    % Mass of segment
    %
    if isfield(segmentPar,bone)
        mBone = mass*segmentPar.(bone).mass;
    else
        error(['missing ',bone,' in segment.xls'])
    end
    
    
    
    
    % b) -----RADIUS OF GYRATION-----------
    %
    ro_x = segmentPar.(bone).RadiusGyr_x;     %ABD/ADD
    ro_y = segmentPar.(bone).RadiusGyr_y;     %FLX/EXT
    ro_z = segmentPar.(bone).RadiusGyr_z;     %INT/EXT
    
    % c)----- BONE LENGTH----------------
    %
    lBone = magnitude(body.(bones{i}).prox_end - body.(bones{i}).dist_end) ;
    lBone = mean(lBone(isfinite(lBone))) ; %remove NaNs and take average in meters
    
    switch bone
        
        case 'Femur'
            segment = 'Thigh';
        case 'Tibia'
            segment = 'Shank';
        case 'TibiaOFM'
            segment = 'ShankOFM';
        otherwise
            segment = bone;
    end
    
    ANTHRO.([side,segment]).Mass   = mBone;
    ANTHRO.([side,segment]).Length = lBone;
    
    
    ANTHRO.([side,segment]).Inertia.x  = mBone*(lBone*ro_x)^2;
    ANTHRO.([side,segment]).Inertia.y  = mBone*(lBone*ro_y)^2;
    ANTHRO.([side,segment]).Inertia.z  = mBone*(lBone*ro_z)^2;
    
end

% old code
% d) MOMENT OF INERTIA---------

% ANTHRO.RightThigh.Inertia.x  = M_thigh*(L_rthigh*ro_x)^2;
% ANTHRO.RightThigh.Inertia.y  = M_thigh*(L_rthigh*ro_y)^2;
% ANTHRO.RightThigh.Inertia.z  = M_thigh*(L_rthigh*ro_z)^2;
%
% ANTHRO.LeftThigh.Inertia.x  = M_thigh*(L_lthigh*ro_x)^2;
% ANTHRO.LeftThigh.Inertia.y  = M_thigh*(L_lthigh*ro_y)^2;
% ANTHRO.LeftThigh.Inertia.z  = M_thigh*(L_lthigh*ro_z)^2;
%
% ANTHRO.RightShank.Inertia.x  = M_shank*(L_rshank*ro_shank_x)^2;
% ANTHRO.RightShank.Inertia.y  = M_shank*(L_rshank*ro_shank_y)^2;
% ANTHRO.RightShank.Inertia.z  = M_shank*(L_rshank*ro_shank_z)^2;
%
% ANTHRO.LeftShank.Inertia.x  = M_shank*(L_lshank*ro_shank_x)^2;
% ANTHRO.LeftShank.Inertia.y  = M_shank*(L_lshank*ro_shank_y)^2;
% ANTHRO.LeftShank.Inertia.z  = M_shank*(L_lshank*ro_shank_z)^2;
%
% ANTHRO.RightFoot.Inertia.x  = M_foot*(L_rfoot*ro_foot_x)^2;
% ANTHRO.RightFoot.Inertia.y  = M_foot*(L_rfoot*ro_foot_y)^2;
% ANTHRO.RightFoot.Inertia.z  = M_foot*(L_rfoot*ro_foot_z)^2;
%
% ANTHRO.LeftFoot.Inertia.x  = M_foot*(L_lfoot*ro_foot_x)^2;
% ANTHRO.LeftFoot.Inertia.y  = M_foot*(L_lfoot*ro_foot_y)^2;
% ANTHRO.LeftFoot.Inertia.z  = M_foot*(L_lfoot*ro_foot_z)^2;
%


%-------------------2-  FOR OXFORD FOOT MODEL ------------------

%a) -----MASS OF SEGMENTS (kg)-------------

% if isfield(segmentPar,'HindFoot')
%
%     segments = {'RightShankOFM','LeftShankOFM','RightHindFoot','LeftHindFoot','RightForeFoot','LeftForeFoot'};
%
%     M_shank =mass*segmentPar.TibiaOFM.mass;
%     M_hindfoot = mass*segmentPar.HindFoot.mass;
%     M_forefoot = mass*segmentPar.ForeFoot.mass;
%
%     M = [M_shank M_shank M_hindfoot M_hindfoot M_forefoot M_forefoot];
%     % b) -----RADIUS OF GYRATION-----------
%
%     ro_shank_x = segmentPar.TibiaOFM.RadiusGyr_x;
%     ro_shank_y =  segmentPar.TibiaOFM.RadiusGyr_y;
%     ro_shank_z =  segmentPar.TibiaOFM.RadiusGyr_z;
%
%     ro_forefoot_x =  segmentPar.ForeFoot.RadiusGyr_x;     %ABD/ADD
%     ro_forefoot_y = segmentPar.ForeFoot.RadiusGyr_y;     %Flx/Ext
%     ro_forefoot_z = segmentPar.ForeFoot.RadiusGyr_z;     %INT/EXT
%
%     ro_hindfoot_x =  segmentPar.HindFoot.RadiusGyr_x;     %ABD/ADD
%     ro_hindfoot_y = segmentPar.HindFoot.RadiusGyr_y;     %Flx/Ext
%     ro_hindfoot_z = segmentPar.HindFoot.RadiusGyr_z;     %INT/EXT
%
%
%
%     % c)----- BONE LENGTH----------------
%
%     L_rshank = magnitude(body.RightTibiaOFM.prox_end - body.RightTibiaOFM.dist_end) ;
%     L_lshank = magnitude(body.LeftTibiaOFM.prox_end - body.LeftTibiaOFM.dist_end) ;
%     L_rhindfoot = magnitude(body.RightHindFoot.prox_end - body.RightHindFoot.dist_end) ;
%     L_lhindfoot = magnitude(body.LeftHindFoot.prox_end - body.LeftHindFoot.dist_end) ;
%     L_rforefoot = magnitude(body.RightForeFoot.prox_end - body.RightForeFoot.dist_end) ;
%     L_lforefoot = magnitude(body.LeftForeFoot.prox_end - body.LeftForeFoot.dist_end) ;
%
%     L_rshank =  mean(L_rshank(isfinite(L_rshank)));
%     L_lshank = mean(L_lshank(isfinite(L_lshank)));
%     L_rhindfoot =  mean(L_rhindfoot(isfinite(L_rhindfoot)));
%     L_lhindfoot = mean(L_lhindfoot(isfinite(L_lhindfoot)));
%     L_rforefoot =  mean(L_rforefoot(isfinite(L_rforefoot)));
%     L_lforefoot = mean(L_lforefoot(isfinite(L_lforefoot)));
%
%     L = [L_rshank  L_lshank  L_rhindfoot L_lhindfoot L_rforefoot L_lforefoot];
%
%     for i = 1:length(segments)
%         ANTHRO.(segments{i}).Mass = M(i);
%         ANTHRO.(segments{i}).Length = L(i);
%     end
%
%
%     % d) MOMENT OF INERTIA---------
%
%
%     ANTHRO.RightShankOFM.Inertia.x  = M_shank*(L_rshank*ro_shank_x)^2;
%     ANTHRO.RightShankOFM.Inertia.y  = M_shank*(L_rshank*ro_shank_y)^2;
%     ANTHRO.RightShankOFM.Inertia.z  = M_shank*(L_rshank*ro_shank_z)^2;
%
%     ANTHRO.LeftShankOFM.Inertia.x  = M_shank*(L_lshank*ro_shank_x)^2;
%     ANTHRO.LeftShankOFM.Inertia.y  = M_shank*(L_lshank*ro_shank_y)^2;
%     ANTHRO.LeftShankOFM.Inertia.z  = M_shank*(L_lshank*ro_shank_z)^2;
%
%     ANTHRO.RightHindFoot.Inertia.x  = M_hindfoot*(L_rhindfoot*ro_hindfoot_x)^2;
%     ANTHRO.RightHindFoot.Inertia.y  = M_hindfoot*(L_rhindfoot*ro_hindfoot_y)^2;
%     ANTHRO.RightHindFoot.Inertia.z  = M_hindfoot*(L_rhindfoot*ro_hindfoot_z)^2;
%
%     ANTHRO.LeftHindFoot.Inertia.x  = M_hindfoot*(L_lhindfoot*ro_hindfoot_x)^2;
%     ANTHRO.LeftHindFoot.Inertia.y  = M_hindfoot*(L_lhindfoot*ro_hindfoot_y)^2;
%     ANTHRO.LeftHindFoot.Inertia.z  = M_hindfoot*(L_lhindfoot*ro_hindfoot_z)^2;
%
%
%     ANTHRO.RightForeFoot.Inertia.x  = M_forefoot*(L_rforefoot*ro_forefoot_x)^2;
%     ANTHRO.RightForeFoot.Inertia.y  = M_forefoot*(L_rforefoot*ro_forefoot_y)^2;
%     ANTHRO.RightForeFoot.Inertia.z  = M_forefoot*(L_rforefoot*ro_forefoot_z)^2;
%
%     ANTHRO.LeftForeFoot.Inertia.x  = M_forefoot*(L_lforefoot*ro_forefoot_x)^2;
%     ANTHRO.LeftForeFoot.Inertia.y  = M_forefoot*(L_lforefoot*ro_forefoot_y)^2;
%     ANTHRO.LeftForeFoot.Inertia.z  = M_forefoot*(L_lforefoot*ro_forefoot_z)^2;
%
%
% end

%
% function r = matchBones2Segments(segment)
%
% % r is 2 x n form of:
% % r = ['RightThigh','Femur'
% %      'LeftThigh','Femur'
% %
%
% segment = setdiff(fieldnames(segment),{'bodymass','fsamp'});
% r = cell(length(segment),2);
%
%
% for i = 1:length(segment)
%
%    r{i,1} = segment{i};
%    r{i,2} = segment{i};
%
%    if strfind(r{i,2},'Right')
%        r{i,2} = strrep(r{i,2},'Right','');
%        side = 'Right';
%    elseif strfind(r{i,2},'Left')
%        r{i,2} = strrep(r{i,2},'Left','');
%        side = 'Left';
%    else
%        side = '';
%    end
%
%
%    switch r{i,2}
%
%        case 'Femur'
%        r{i,1} = strrep(r{i,1},r{i,1},[side,'Thigh']);
%
%        case 'Tibia'
%        r{i,1} = strrep(r{i,1},r{i,1},[side,'Shank']);
%
%        case 'TibiaOFM'
%        r{i,1} = strrep(r{i,1},r{i,1},[side,'ShankOFM']);
%
% %        otherwise
% %           r{i,1} = [side,r{i,1}];
%    end
%
%
%
%
%
% end
%
%
%
