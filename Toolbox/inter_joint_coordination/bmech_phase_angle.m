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


function data = phase_angle_data(data, evt1, evt2, chns)

if isempty(evt1)
    events = false;
else
    events = true;
    evt1_indx = findfield(data, evt1);
    evt2_indx = findfield(data, evt2);  
    evt1_indx = evt1_indx(1);
    evt2_indx = evt2_indx(1);
end

    
% compute phase angle and add to data
for i = 1:length(chns)
    joint_angle = data.(chns{i}).line;
    if events
        pa = phase_angle(joint_angle, evt1_indx, evt2_indx);
    else
        pa = phase_angle(joint_angle);
    end
    
    data = addchannel_data(data, [chns{i}, '_phase'], pa, 'video');
    
end