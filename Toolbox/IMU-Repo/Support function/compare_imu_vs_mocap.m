function compare_imu_vs_mocap(data)
figure
subplot(2,2,1)
plot(data.hipR_flex.line,'b')
hold on
plot(data.RHipAngles_x.line,'r')
title("Right Hip flexion/extention angle")

subplot(2,2,2)
plot(data.kneeR_flex.line,'b')
hold on
plot(data.RKneeAngles_x.line,'r')
title("Right knee flexion/extention angle")


subplot(2,2,3)
plot(data.hipL_flex.line,'b')
hold on
plot(data.LHipAngles_x.line,'r')
title("left Hip flexion/extention angle")


subplot(2,2,4)
plot(data.kneeL_flex.line,'b')
hold on
plot(data.LKneeAngles_x.line,'r')
title("Left Knee flexion/extention angle")

set(gcf, 'Position', get(0, 'Screensize'));
leg=legend(["IMU","MoCap"]);

leg.Position=[0.481706686937371,0.474958698844575,0.0587239589417969,0.0487446591385408];