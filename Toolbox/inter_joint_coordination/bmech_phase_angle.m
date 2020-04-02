function bmech_phase_angle(fld, chns, evt1, evt2)

% bmech_phase_angle(fld, evt1, evt2) computes phase angles between evt1 and
% evt2 for channels
%



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
    evt1 = 32;
    evt2 = 94;
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
        phase_angle = Phase_Angle(joint_angle, evt1_indx, evt2_indx);
    else
        phase_angle = Phase_Angle(joint_angle);
    end
    
    data = addchannel_data(data, [chns{i}, '_phase'], phase_angle, 'video');
    
end