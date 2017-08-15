% ANGULAR VELOCITY-------

% LEFT FOOT
figure
plot(AKIN.LeftFoot.AngVel(:,1))
hold on
plot(vdata.AngularVelocityLeftFoot.line(:,1),'r')

figure
plot(AKIN.LeftFoot.AngVel(:,2))
hold on
plot(vdata.AngularVelocityLeftFoot.line(:,2),'r')

figure
plot(AKIN.LeftFoot.AngVel(:,3))
hold on
plot(vdata.AngularVelocityLeftFoot.line(:,3),'r')



%---left shank

figure
plot(AKIN.LeftShankPG.AngVel(:,1))
hold on
plot(vdata.AngularVelocityLeftShankPG.line(:,1),'r')

figure
plot(AKIN.LeftShankPG.AngVel(:,2))
hold on
plot(vdata.AngularVelocityLeftShankPG.line(:,2),'r')

figure
plot(AKIN.LeftShankPG.AngVel(:,3))
hold on
plot(vdata.AngularVelocityLeftShankPG.line(:,3),'r')




%---Left thigh

figure
plot(AKIN.LeftThigh.AngVel(:,1))
hold on
plot(vdata.AngularVelocityLeftThigh.line(:,1),'r')

figure
plot(AKIN.LeftThigh.AngVel(:,2))
hold on
plot(vdata.AngularVelocityLeftThigh.line(:,2),'r')

figure
plot(AKIN.LeftThigh.AngVel(:,3))
hold on
plot(vdata.AngularVelocityLeftThigh.line(:,3),'r')


%--Right Foot

figure
plot(AKIN.RightFoot.AngVel(:,1))
hold on
plot(vdata.AngularVelocityRightFoot.line(:,1),'r')

figure
plot(AKIN.RightFoot.AngVel(:,2))
hold on
plot(vdata.AngularVelocityRightFoot.line(:,2),'r')

figure
plot(AKIN.RightFoot.AngVel(:,3))
hold on
plot(vdata.AngularVelocityRightFoot.line(:,3),'r')



%---Right shank

figure
plot(AKIN.RightShankPG.AngVel(:,1))
hold on
plot(vdata.AngularVelocityRightShankPG.line(:,1),'r')

figure
plot(AKIN.RightShankPG.AngVel(:,2))
hold on
plot(vdata.AngularVelocityRightShankPG.line(:,2),'r')

figure
plot(AKIN.RightShankPG.AngVel(:,3))
hold on
plot(vdata.AngularVelocityRightShankPG.line(:,3),'r')




%---Right thigh

figure
plot(AKIN.RightThigh.AngVel(:,1))
hold on
plot(vdata.AngularVelocityRightThigh.line(:,1),'r')

figure
plot(AKIN.RightThigh.AngVel(:,2))
hold on
plot(vdata.AngularVelocityRightThigh.line(:,2),'r')

figure
plot(AKIN.RightThigh.AngVel(:,3))
hold on
plot(vdata.AngularVelocityRightThigh.line(:,3),'r')



%% ANGULAR ACCELERATION-------

% LEFT FOOT
figure
plot(AKIN.LeftFoot.AngAcc(:,1))

figure
plot(AKIN.LeftFoot.AngAcc(:,2))


figure
plot(AKIN.LeftFoot.AngAcc(:,3))



%---left shank

figure
plot(AKIN.LeftShankPG.AngAcc(:,1))

figure
plot(AKIN.LeftShankPG.AngAcc(:,2))

figure
plot(AKIN.LeftShankPG.AngAcc(:,3))





%---Left thigh

figure
plot(AKIN.LeftThigh.AngAcc(:,1))

figure
plot(AKIN.LeftThigh.AngAcc(:,2))

figure
plot(AKIN.LeftThigh.AngAcc(:,3))


%--Right Foot

figure
plot(AKIN.RightFoot.AngAcc(:,1))

figure
plot(AKIN.RightFoot.AngAcc(:,2))

figure
plot(AKIN.RightFoot.AngAcc(:,3))



%---Right shank

figure
plot(AKIN.RightShankPG.AngAcc(:,1))

figure
plot(AKIN.RightShankPG.AngAcc(:,2))

figure
plot(AKIN.RightShankPG.AngAcc(:,3))



%---Right thigh

figure
plot(AKIN.RightThigh.AngAcc(:,1))


figure
plot(AKIN.RightThigh.AngAcc(:,2))

figure
plot(AKIN.RightThigh.AngAcc(:,3))


