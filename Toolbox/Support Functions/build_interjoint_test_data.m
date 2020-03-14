% script to generate mat file data for testing inter-joint coordination

fld = uigetfolder; % get 1-c3d2zoo folder
cd(fld)

fl = engine('fld', fld, 'extension', 'zoo', 'folder', 'Straight');

left_ankle_stk = [];
left_knee_stk = [];
left_hip_stk = [];

for i = 1:length(fl)
    data = zload(fl{i});
    
    % get events
    rfs1 = findfield(data, 'Right_FootStrike1');
    lfs1 = findfield(data, 'Left_FootStrike1');
    
    if rfs1(1) < lfs1(1)
        rfo2 = findfield(data, 'Right_FootOff2');
        if ~isempty(rfo2)
            data = partition_data(data,'Right_FootStrike1', 'Right_FootOff2');
            data = normalize_data(data);
            left_ankle = data.LAnkleAngles.line(:, 1)';
            left_knee = data.LKneeAngles.line(:, 1)';
            left_hip = data.LHipAngles.line(:, 1)';
            
            if ~isnan(mean(left_ankle)) && ~isnan(mean(left_knee)) && ~isnan(mean(left_hip))
                batchdisp(fl{i}, 'extracting kinematics')
                left_ankle_stk = [left_ankle_stk; left_ankle];
                left_knee_stk = [left_knee_stk; left_knee];
                left_hip_stk = [left_hip_stk; left_hip];
                
            end
            
            
            
        end
    end
    
end

% save data to mat files
save('left_ankle_data.mat', 'left_ankle_stk');
save('left_knee_data.mat', 'left_knee_stk');
save('left_hip_data.mat', 'left_hip_stk');


% make some plots
subplot(3, 1, 1)
plot(left_ankle_stk')
title('left ankle')
vline(32, 'k-')
vline(94, 'k-')

subplot(3, 1, 2)
title('left knee')
plot(left_knee_stk')
vline(32, 'k-')
vline(94, 'k-')

subplot(3, 1, 3)
plot(left_hip_stk')
title('left hip')
vline(32, 'k-')
vline(94, 'k-')



