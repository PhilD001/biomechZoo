function bmech_phase_angle(fld, chns)

% BMECH_PHASE_ANGLE(fld) computes phase angles between evt1 and evt2 for channels
%
% ARGUMENTS
%  fld        ...  Folder to batch process (string). 
%  chns       ...  Channels for which to compute phase angle. Channels must be 1 x n (exploded)

% Batch process
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing phase angle');
    data = phase_angle_data(data, chns);
    zsave(fl{i},data);
end

