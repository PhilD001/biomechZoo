function bmech_imu_heelstrike_detect(fld, PeakLim)

% fld is path to data folder
% add new ch for heel strike(HS), mid swing(MS), toe_off(TO) both right(R) and left(L) side

if nargin ==0
    fld = uigetfolder;
    PeakLim = 0.7;
end

fl = engine('fld', fld, 'extension', 'zoo');
for i = 1:length(fl)
    if strfind(fl{i}, 'CALIB')
        batchdisp(fl{i}, 'no gait events for CALIB, skipping...')
    else
        batchdisp(fl{i}, 'extracting gait events')
        data = zload(fl{i});
        data = gait_event_detect_data(data, PeakLim);
        zsave(fl{i},data)
    end
end


function data = gait_event_detect_data(data, PeakLim)


ch = fieldnames(data);

if ismember('shankR_Gyr_X', ch)
    
    g_x = data.shankR_Gyr_X.line;
    g_y = data.shankR_Gyr_Y.line;
    g_z = data.shankR_Gyr_Z.line;
    Gmag=sqrt(g_x.^2 + g_y.^2 + g_z.^2); %Normalized Gyro Data
    % detect heel strike, mid swing, toe_off for Right side
    RHS = imu_heelstrike_line(Gmag,PeakLim); % min value between two peaks
    figure
    plot(Gmag)
    hold on
    scatter(RHS,Gmag(RHS))
    
    %adding as events to zoo
    for i = 1:length(RHS)
        data.shankR_Gyr_X.event.(['RHS',num2str(i)]) = [RHS(i) 0 0];
    end
    
end

if ismember('shankL_Gyr_X', ch)
    
    g_x = data.shankL_Gyr_X.line;
    g_y = data.shankL_Gyr_Y.line;
    g_z = data.shankL_Gyr_Z.line;
    Gmag=sqrt(g_x.^2 + g_y.^2 + g_z.^2); %Normalized Gyro Data
    % detect heel strike, mid swing, toe_off for Left side
    LHS = imu_heelstrike_line(Gmag,PeakLim); % min value between two peaks
    figure
    plot(Gmag)
    hold on
    scatter(LHS,Gmag(LHS))
    
    %adding as events to zoo
    for i = 1:length(LHS)
        data.shankL_Gyr_X.event.(['LHS',num2str(i)]) = [LHS(i) 0 0];
    end
    
end

function Heelstrike = imu_heelstrike_line(G,PeakLim)

% Heelstrike_Detection(Gs,PeakLim) finds frames for heel strike based on
% magnitude of gyroscope data (G). 

[GRow, ~] = size(G); % Count Row and Columm of Gyro Shank
limitPeakH = PeakLim * max(G,[],'all'); %Set limit peak (X to Max value of Gyro)
limitPeakD = 50; %Min Distance between two peaks
% Peak ditection Start
[~,GyroPeaks,~,~] = findpeaks(G,[1:GRow],...
    'MinPeakProminence',limitPeakH,...
    'MinPeakDistance',limitPeakD);

GyroPeaks= GyroPeaks.';
[iend, ~] = size(GyroPeaks);
if iend >1
    for i= 1:iend-1
        [TF,~]=islocalmin(G(GyroPeaks(i):GyroPeaks(i+1)));
        TFmin=find(TF==1);
        Heel(i)= GyroPeaks(i)+TFmin(1)-1;
    end
else
    Heel=[];
end
Heelstrike=Heel;
    
    
    
