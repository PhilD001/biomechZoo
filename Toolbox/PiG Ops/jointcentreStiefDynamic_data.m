function data= jointcentreStiefDynamic_data(data,joint,mkr_lat,vecStatic)

% data = jointcentreStiefDynamic_data(data,joint,mkr_lat,vecStatic)
% computes knee and ankle joint centres based on medial marker and vector
% pointing to joint centre (computed using static trial with medial markers)
%
% ARGUMENTS
%  data       ...  zoo data struct to operate on
%  joint      ...  name of joint ('Knee' or 'Ankle')
%  mkr_lat    ...  lateral joint marker (lateral e.g. 'KNE' or 'ANK')
%  vecStatic  ...  Vector pointing from mkr_lat to joint centre (expressed in 
%                  global coordinate system, displaced to origin). This vector
%                  is added to the position of the dynamic trial mrk_lat
%                  to obtain the dynamic positions of the joint centre
%                  during movement trials
%
% RETURNS
%  data       ...  zoo data with joint centre virtual markers appended
%                 ('R/LKnee/AnkleJC')
%
% NOTES:
% - Algorithm: Joint centres set as midpoint between 'mkr_lat' and 'mkr_med'.
%   See Stief et al. "Reliability and Accuracy in Three-Dimensional Gait Analysis:
%   A Comparison of Two Lower Body Protocols". J App Biomech. 2013.
%
% See also jointcentreStiefStatic, bmech_kinematics


sides = {'R','L'};

for j = 1:2
    JC_dynamic  = zeros(size(data.RASI.line));
    
    for k = 1:length(JC_dynamic)
        Aprime = data.([sides{j},mkr_lat]).line(k,:);
        JC_dynamic(k,:) = vecStatic.(sides{j}) + Aprime;
    end
    
    data = addchannel_data(data,[sides{j},joint,'JC'],JC_dynamic,'Video');
end