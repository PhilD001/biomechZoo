function [data,vecStatic] = jointcentreStiefStatic_data(data,joint,mkr_lat,mkr_med)

% [data,vecStatic] = jointcentreStiefStatic_data(data,joint,mkr_lat,mkr_med)
% computes knee and ankle joint centres based on the medial and lateral
% markers (mid-point). 
%
% ARGUMENTS
%  data       ...  zoo data struct to operate on
%  joint      ...  name of joint ('knee' or 'ankle')
%  mkr_lat    ...  lateral joint marker (lateral e.g. 'KNE' or 'ANK')
%  mkr_med    ...  medial marker (e.g. 'KNM' or 'MMA')
%
% RETURNS
%  data       ...  zoo data with joint centre virtual markers appended
%                 ('R/LKnee/AnkleJC')
%  vecStatic  ... Vector pointing from mkr_lat to joint centre (expressed in 
%                 global coordinate system, displaced to origin). This vector
%                 can be added to the position of the dynamic trial mrk_lat
%                 to obtain the dynamic positions of the joint centre
%                 during movement trials
%
% NOTES: 
% - Algorithm: Joint centres set as midpoint between 'mkr_lat' and 'mkr_med'.
%   See Stief et al. "Reliability and Accuracy in Three-Dimensional Gait Analysis:
%   A Comparison of Two Lower Body Protocols". J App Biomech. 2013.
%
% See also jointcentreStiefDynamic, bmech_kinematics



% Error check / set defaults
%
if ~isempty(strfind(lower(joint),'ankle')) && nargin ==2
    mkr_lat = 'ANK';
    mkr_med = 'MMA';
end

if ~isempty(strfind(lower(joint),'knee')) && nargin ==2
    mkr_lat = 'KNE';
    mkr_med = 'KNM';
end


sides = {'R','L'};
vecStatic = struct;


% Main algorithm
%
for i = 1:length(sides)
    
    % extract markers
    MED = data.([sides{i},mkr_med]).line;          % KNM or MMA
    LAT = data.([sides{i},mkr_lat]).line;          % KNE or ANK
    
    % Compute joint center
    JC = (LAT+MED)./2;                             % joint centre in GCS
    jc = nanmean(JC);                              % take average
    
    % Compute vector from lateral marker to joint centre
    %
    lat = nanmean(LAT);
    vec = jc - lat;

    % Save information
    %
    vecStatic.(sides{i}) = vec;                                     % save vector
    data = addchannel_data(data,[sides{i},joint,'JC'],JC,'Video');  % save joint centre
end






