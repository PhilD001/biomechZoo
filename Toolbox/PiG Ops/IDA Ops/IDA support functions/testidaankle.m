function testidaankle


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



%-----------POWERS----------


FSR = data.AnalogSampleNum.event.FSR(1);
FSL = data.AnalogSampleNum.event.FSL(1);
FOR = data.AnalogSampleNum.event.FOR(1);
FOL = data.AnalogSampleNum.event.FOL(1);

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




