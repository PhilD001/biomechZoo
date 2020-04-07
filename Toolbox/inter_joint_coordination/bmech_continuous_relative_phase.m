function bmech_continuous_relative_phase(fld, dist_phase_angle_ch, prox_phase_angle_ch)

% BMECH_CONTINNUOUS_RELATIVE_PHASE(fld, dist_phase_angle_ch,
% prox_phase_angle_ch) computes CRP between two angles
%
% ARGUMENTS
%  fld                    ...  Folder to batch process (string). 
%  dist_phase_angle_ch   ...   Phase angle channel for distal joint
%  prox_phase_angle_ch   ...   Phase angle channel for proximal joint

% Batch process
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing phase angle');
    data = continuous_relative_phase_data(data, dist_phase_angle_ch, prox_phase_angle_ch);
    zsave(fl{i},data);
end

function data = continuous_relative_phase_data(data, dist_phase_angle_ch, prox_phase_angle_ch)

dist_angle = data.(dist_phase_angle_ch).line;
prox_angle = data.(prox_phase_angle_ch).line;

CRP_data = CRP(dist_angle,prox_angle);

data = addchannel_data(data, [prox_phase_angle_ch, '_', dist_phase_angle_ch, '_crp'], CRP_data, 'video');