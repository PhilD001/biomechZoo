function bmech_phase_angle(fld, chns, evt1, evt2)

% BMECH_PHASE_ANGLE(fld, evt1, evt2) computes phase angles between evt1 and evt2 for channels
%
% ARGUMENTS
%  fld        ...  Folder to batch process (string). 
%  chns       ...  Channels for which to compute phase angle. Channels must be 1 x n (exploded)
%  event1     ...   start of section of interest for angle data
%  event2     ...   end of section of interest for angle data


% error checking
if nargin < 3
    evt1 = [];
    evt2 = [];  
end


% Batch process
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing phase angle');
    data = phase_angle_data(data, evt1, evt2, chns);
    zsave(fl{i},data);
end


