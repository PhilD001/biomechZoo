function bmech_phase_angle(fld, chns, evt1, evt2, pad_type)

% BMECH_PHASE_ANGLE(fld, evt1, evt2) computes phase angles between evt1 and evt2 for channels
%
% ARGUMENTS
%  fld        ...  Folder to batch process (string). 
%  chns       ...  Channels for which to compute phase angle. Channels must be 1 x n (exploded)
%  event1     ...   start of section of interest for angle data
%  event2     ...   end of section of interest for angle data
%  pad_type    ... num, option to pad with zeros or Nans. Default is NaN

% see also: phase_angle_data, phase_angle

% error checking
if nargin == 2
    evt1 = [];
    evt2 = [];  
    pad_type = NaN;
end

if nargin == 4
    pad_type = NaN;
end

% Batch process
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing phase angle');
    data = phase_angle_data(data, chns, evt1, evt2, pad_type);
    zsave(fl{i},data);
end



