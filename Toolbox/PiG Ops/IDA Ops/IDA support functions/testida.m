function testida


% comparison of midfoot angles and PIG ankle angles

FSR = data.AnalogSampleNum.event.FSR(1);
FSL = data.AnalogSampleNum.event.FSL(1);
FOR = data.AnalogSampleNum.event.FOR(1);
FOL = data.AnalogSampleNum.event.FOL(1);




%Right MidFoot Force
figure
plot(data.RightMidFootForce_x.line(FSR:FOR),'b')
hold on
plot(data.RightMidFootForce_y.line(FSR:FOR),'r')
plot(data.RightMidFootForce_z.line(FSR:FOR),'g')
title('Right MidFoot Force')
ylabel('N/kg');
legend('x','y','z','location','best')


% Left MidFoot Force
figure
plot(data.LeftMidFootForce_x.line(FSL:FOL),'b')
hold on
plot(data.LeftMidFootForce_y.line(FSL:FOL),'r')
plot(data.LeftMidFootForce_z.line(FSL:FOL),'g')
title('Left MidFoot Force')
ylabel('N/kg');
legend('x','y','z','location','best')



% Right Ankle Force
figure
plot(data.RAnkleForce.line(FSR:FOR,1))
hold on
plot(data.RightAnkleForcePG_x.line(FSR:FOR),'r')
plot(data.RightAnkleForceOFM_x.line(FSR:FOR),'g')
title('Right Ankle Force x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

figure
plot(data.RAnkleForce.line(FSR:FOR,2))
hold on
plot(data.RightAnkleForcePG_y.line(FSR:FOR),'r')
plot(data.RightAnkleForceOFM_y.line(FSR:FOR),'g')
title('Right Ankle Force y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

figure
plot(data.RAnkleForce.line(FSR:FOR,3))
hold on
plot(data.RightAnkleForcePG_z.line(FSR:FOR),'r')
plot(data.RightAnkleForceOFM_z.line(FSR:FOR),'g')
title('Right Ankle Force z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


% Left Ankle Force
figure
plot(data.LAnkleForce.line(FSL:FOL))
hold on
plot(data.LeftAnkleForcePG_x.line(FSL:FOL),'r')
plot(data.LeftAnkleForceOFM_x.line(FSL:FOL),'g')
title('Left Ankle Force x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LAnkleForce.line(FSL:FOL,2))
hold on
plot(data.LeftAnkleForcePG_y.line(FSL:FOL),'r')
plot(data.LeftAnkleForceOFM_y.line(FSL:FOL),'g')
title('Left Ankle Force y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LAnkleForce.line(FSL:FOL,3))
hold on
plot(data.LeftAnkleForcePG_z.line(FSL:FOL),'r')
plot(data.LeftAnkleForceOFM_z.line(FSL:FOL),'g')
title('Left Ankle Force z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


% Right knee Force
figure
plot(data.RKneeForce.line(FSR:FOR,1))
hold on
plot(data.RightKneeForcePG_x.line(FSR:FOR),'r')
plot(data.RightKneeForceOFM_x.line(FSR:FOR),'g')
title('Right knee Force x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RKneeForce.line(FSR:FOR,2))
hold on
plot(data.RightKneeForcePG_y.line(FSR:FOR),'r')
plot(data.RightKneeForceOFM_y.line(FSR:FOR),'g')
title('Right knee Force y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



figure
plot(data.RKneeForce.line(FSR:FOR,3))
hold on
plot(data.RightKneeForcePG_z.line(FSR:FOR),'r')
plot(data.RightKneeForceOFM_z.line(FSR:FOR),'g')
title('Right knee Force z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


% LeftKnee Force
figure
plot(data.LKneeForce.line(FSL:FOL,1))
hold on
plot(data.LeftKneeForcePG_x.line(FSL:FOL),'r')
plot(data.LeftKneeForceOFM_x.line(FSL:FOL),'g')
title('Left knee Force x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



figure
plot(data.LKneeForce.line(FSL:FOL,2))
hold on
plot(data.LeftKneeForcePG_y.line(FSL:FOL),'r')
plot(data.LeftKneeForceOFM_y.line(FSL:FOL),'g')
title('Left knee Force y ')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LKneeForce.line(FSL:FOL,3))
hold on
plot(data.LeftKneeForcePG_z.line(FSL:FOL),'r')
plot(data.LeftKneeForceOFM_z.line(FSL:FOL),'g')
title('Left knee Force z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

% Right Hip Force
figure
plot(data.RHipForce.line(FSR:FOR,1))
hold on
plot(data.RightHipForcePG_x.line(FSR:FOR),'r')
plot(data.RightHipForceOFM_x.line(FSR:FOR),'g')
title('Right Hip Force x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

figure
plot(data.RHipForce.line((FSR:FOR),2))
hold on
plot(data.RightHipForcePG_y.line(FSR:FOR),'r')
plot(data.RightHipForceOFM_y.line(FSR:FOR),'g')
title('Right Hip Force y ')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RHipForce.line((FSR:FOR),3))
hold on
plot(data.RightHipForcePG_z.line(FSR:FOR),'r')
plot(data.RightHipForceOFM_z.line(FSR:FOR),'g')
title('Right Hip Force z ')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



% LeftHip Force
figure
plot(data.LHipForce.line(FSL:FOL,1))
hold on
plot(data.LeftHipForcePG_x.line(FSL:FOL),'r')
plot(data.LeftHipForceOFM_x.line(FSL:FOL),'g')
title('Left Hip Force ')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



figure
plot(data.LHipForce.line(FSL:FOL,2))
hold on
plot(data.LeftHipForcePG_y.line(FSL:FOL),'r')
plot(data.LeftHipForceOFM_y.line(FSL:FOL),'g')
title('Left Hip Force')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LHipForce.line(FSL:FOL,3))
hold on
plot(data.LeftHipForcePG_z.line(FSL:FOL),'r')
plot(data.LeftHipForceOFM_z.line(FSL:FOL),'g')
title('Left Hip Force')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



%Right MidFoot Moment
figure
plot(data.RightMidFootMoment_x.line(FSR:FOR),'b')
hold on
plot(data.RightMidFootMoment_y.line(FSR:FOR),'r')
plot(data.RightMidFootMoment_z.line(FSR:FOR),'g')
title('Right MidFoot Moment')
ylabel('N/kg');
legend('x','y','z','location','best')



% Right Ankle Moment
figure
plot(data.RAnkleMoment.line(FSR:FOR,1))
hold on
plot(data.RightAnkleMomentPG_x.line(FSR:FOR),'r')
plot(data.RightAnkleMomentOFM_x.line(FSR:FOR),'g')
title('Right Ankle Moment x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RAnkleMoment.line(FSR:FOR,2))
hold on
plot(data.RightAnkleMomentPG_y.line(FSR:FOR),'r')
plot(data.RightAnkleMomentOFM_y.line(FSR:FOR),'g')
title('Right Ankle Moment y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RAnkleMoment.line(FSR:FOR,3))
hold on
plot(data.RightAnkleMomentPG_z.line(FSR:FOR),'r')
plot(data.RightAnkleMomentOFM_z.line(FSR:FOR),'g')
title('Right Ankle Moment z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



%Left MidFoot Moment
figure
plot(data.LeftMidFootMoment_x.line(FSL:FOL),'b')
hold on
plot(data.LeftMidFootMoment_y.line(FSL:FOL),'r')
plot(data.LeftMidFootMoment_z.line(FSL:FOL),'g')
title('Left MidFoot Moment')
ylabel('N/kg');
legend('x','y','z','location','best')


% Left Ankle Moment
figure
plot(data.LAnkleMoment.line(FSL:FOL,1))
hold on
plot(data.LeftAnkleMomentPG_x.line(FSL:FOL),'r')
plot(data.LeftAnkleMomentOFM_x.line(FSL:FOL),'g')
title('Left Ankle Moment x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

figure
plot(data.LAnkleMoment.line(FSL:FOL,2))
hold on
plot(data.LeftAnkleMomentPG_y.line(FSL:FOL),'r')
plot(data.LeftAnkleMomentOFM_y.line(FSL:FOL),'g')
title('Left Ankle Moment y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LAnkleMoment.line(FSL:FOL,3))
hold on
plot(data.LeftAnkleMomentPG_z.line(FSL:FOL),'r')
plot(data.LeftAnkleMomentOFM_z.line(FSL:FOL),'g')
title('Left Ankle Moment z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


% Right knee Moment
figure
plot(data.RKneeMoment.line(FSL:FOL,1))
hold on
plot(data.RightKneeMomentPG_x.line(FSR:FOR),'r')
plot(data.RightKneeMomentOFM_x.line(FSR:FOR),'g')
title('Right knee Moment x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RKneeMoment.line(FSL:FOL,2))
hold on
plot(data.RightKneeMomentPG_y.line(FSR:FOR),'r')
plot(data.RightKneeMomentOFM_y.line(FSR:FOR),'g')
title('Right knee Moment y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



figure
plot(data.RKneeMoment.line(FSL:FOL,3))
hold on
plot(data.RightKneeMomentPG_z.line(FSR:FOR),'r')
plot(data.RightKneeMomentOFM_z.line(FSR:FOR),'g')
title('Right knee Moment z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


% ------------LeftKnee Moment
figure
plot(data.LKneeMoment.line(FSL:FOL,1))
hold on
plot(data.LeftKneeMomentPG_x.line(FSL:FOL),'r')
plot(data.LeftKneeMomentOFM_x.line(FSL:FOL),'g')
title('Left knee Moment x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LKneeMoment.line(FSL:FOL,2))
hold on
plot(data.LeftKneeMomentPG_y.line(FSL:FOL),'r')
plot(data.LeftKneeMomentOFM_y.line(FSL:FOL),'g')
title('Left knee Moment y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LKneeMoment.line(FSL:FOL,3))
hold on
plot(data.LeftKneeMomentPG_z.line(FSL:FOL),'r')
plot(data.LeftKneeMomentOFM_z.line(FSL:FOL),'g')
title('Left knee Moment z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


% Right Hip Moment
figure
plot(data.RHipMoment.line(FSR:FOR,1))
hold on
plot(data.RightHipMomentPG_x.line(FSR:FOR),'r')
plot(data.RightHipMomentOFM_x.line(FSR:FOR),'g')
title('Right Hip Moment x')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RHipMoment.line(FSR:FOR,2))
hold on
plot(data.RightHipMomentPG_y.line(FSR:FOR),'r')
plot(data.RightHipMomentOFM_y.line(FSR:FOR),'g')
title('Right Hip Moment y')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.RHipMoment.line(FSR:FOR,3))
hold on
plot(data.RightHipMomentPG_z.line(FSR:FOR),'r')
plot(data.RightHipMomentOFM_z.line(FSR:FOR),'g')
title('Right Hip Moment z')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

% LeftHip Moment
figure
plot(data.LHipMoment.line(FSL:FOL,1))
hold on
plot(data.LeftHipMomentPG_x.line(FSL:FOL),'r')
plot(data.LeftHipMomentOFM_x.line(FSL:FOL),'g')
title('Left Hip Moment')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LHipMoment.line(FSL:FOL,2))
hold on
plot(data.LeftHipMomentPG_y.line(FSL:FOL),'r')
plot(data.LeftHipMomentOFM_y.line(FSL:FOL),'g')
title('Left Hip Moment')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


figure
plot(data.LHipMoment.line(FSL:FOL,3))
hold on
plot(data.LeftHipMomentPG_z.line(FSL:FOL),'r')
plot(data.LeftHipMomentOFM_z.line(FSL:FOL),'g')
title('Left Hip Moment')
ylabel('N/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')


%-----------POWERS----------


%Right MidFoot Power
figure
plot(data.RightMidFootPower.line(FSR:FOR),'b')
title('Right MidFoot Power')
ylabel('N/kg');



% Right Ankle Power
figure
plot(data.RAnklePower.line(FSR:FOR,3))
hold on
plot(data.RightAnklePowerPG.line(FSR:FOR),'r')
plot(data.RightAnklePowerOFM.line(FSR:FOR),'g')
title('Right Ankle Power')
ylabel('W/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')





% Right Knee Power
figure
plot(data.RKneePower.line(FSR:FOR,3))
hold on
plot(data.RightKneePowerPG.line(FSR:FOR),'r')
plot(data.RightKneePowerOFM.line(FSR:FOR),'g')
title('Right Knee Power')
ylabel('W/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



% Right Hip Power
figure
plot(data.RHipPower.line(FSR:FOR,3))
hold on
plot(data.RightHipPowerPG.line(FSR:FOR),'r')
plot(data.RightHipPowerOFM.line(FSR:FOR),'g')
title('Right Hip Power')
ylabel('W/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



%Left MidFoot Power
figure
plot(data.LeftMidFootPower.line(FSL:FOL),'b')
title('Left MidFoot Power')
ylabel('N/kg');



% Left Ankle Power
figure
plot(data.LAnklePower.line(FSL:FOL,3))
hold on
plot(data.LeftAnklePowerPG.line(FSL:FOL),'r')
plot(data.LeftAnklePowerOFM.line(FSL:FOL),'g')
title('Left Ankle Power')
ylabel('W/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



% Left Knee Power
figure
plot(data.LKneePower.line(FSL:FOL,3))
hold on
plot(data.LeftKneePowerPG.line(FSL:FOL),'r')
plot(data.LeftKneePowerOFM.line(FSL:FOL),'g')
title('Left Knee Power')
ylabel('W/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')



% Left Hip Power
figure
plot(data.LHipPower.line(FSL:FOL,3))
hold on
plot(data.LeftHipPowerPG.line(FSL:FOL),'r')
plot(data.LeftHipPowerOFM.line(FSL:FOL),'g')
title('Left Hip Power')
ylabel('W/kg');
legend('Vicon','PGcalc','OFMcalc','location','best')

