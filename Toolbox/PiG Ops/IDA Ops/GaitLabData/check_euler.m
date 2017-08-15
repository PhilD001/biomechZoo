% ANGULAR VELOCITY IN LOCAL -------

% LEFT FOOT
figure
plot(AKIN.LeftFoot.AngVel(:,1))
hold on
plot(VKIN.LeftFoot.AngVel(:,1),'r')

figure
plot(AKIN.LeftFoot.AngVel(:,2))
hold on
plot(VKIN.LeftFoot.AngVel(:,2),'r')

figure
plot(AKIN.LeftFoot.AngVel(:,3))
hold on
plot(VKIN.LeftFoot.AngVel(:,3),'r')



%---left shank

figure
plot(AKIN.LeftShankPG.AngVel(:,1))
hold on
plot(VKIN.LeftShankPG.AngVel(:,1),'r')

figure
plot(AKIN.LeftShankPG.AngVel(:,2))
hold on
plot(VKIN.LeftShankPG.AngVel(:,2),'r')

figure
plot(AKIN.LeftShankPG.AngVel(:,3))
hold on
plot(VKIN.LeftShankPG.AngVel(:,3),'r')




%---Left thigh

figure
plot(AKIN.LeftThigh.AngVel(:,1))
hold on
plot(VKIN.LeftThigh.AngVel(:,1),'r')

figure
plot(AKIN.LeftThigh.AngVel(:,2))
hold on
plot(VKIN.LeftThigh.AngVel(:,2),'r')

figure
plot(AKIN.LeftThigh.AngVel(:,3))
hold on
plot(VKIN.LeftThigh.AngVel(:,3),'r')


%--Right Foot

figure
plot(AKIN.RightFoot.AngVel(:,1))
hold on
plot(VKIN.RightFoot.AngVel(:,1),'r')


figure
plot(AKIN.RightFoot.AngVel(:,2))
hold on
plot(VKIN.RightFoot.AngVel(:,2),'r')


figure
plot(AKIN.RightFoot.AngVel(:,3))
hold on
plot(VKIN.RightFoot.AngVel(:,3),'r')
title('rfoot')


%---Right shank

figure
plot(AKIN.RightShankPG.AngVel(:,1))
hold on
plot(VKIN.RightShankPG.AngVel(:,1),'r')


figure
plot(AKIN.RightShankPG.AngVel(:,2))
hold on
plot(VKIN.RightShankPG.AngVel(:,2),'r')

figure
plot(AKIN.RightShankPG.AngVel(:,3))
hold on
plot(VKIN.RightShankPG.AngVel(:,3),'r')
title('rshank')



%---Right thigh

figure
plot(AKIN.RightThigh.AngVel(:,1))
hold on
plot(VKIN.RightThigh.AngVel(:,1),'r')

figure
plot(AKIN.RightThigh.AngVel(:,2))
hold on
plot(VKIN.RightThigh.AngVel(:,2),'r')

figure
plot(AKIN.RightThigh.AngVel(:,3))
hold on
plot(VKIN.RightThigh.AngVel(:,3),'r')



%% ANGULAR ACCELERATION-------



% LEFT FOOT
figure
plot(AKIN.LeftFoot.AngAcc(:,1))
hold on
plot(VKIN.LeftFoot.AngAcc(:,1),'r')

figure
plot(AKIN.LeftFoot.AngAcc(:,2))
hold on
plot(VKIN.LeftFoot.AngAcc(:,2),'r')

figure
plot(AKIN.LeftFoot.AngAcc(:,3))
hold on
plot(VKIN.LeftFoot.AngAcc(:,3),'r')



%---left shank

figure
plot(AKIN.LeftShankPG.AngAcc(:,1))
hold on
plot(VKIN.LeftShankPG.AngAcc(:,1),'r')

figure
plot(AKIN.LeftShankPG.AngAcc(:,2))
hold on
plot(VKIN.LeftShankPG.AngAcc(:,2),'r')

figure
plot(AKIN.LeftShankPG.AngAcc(:,3))
hold on
plot(VKIN.LeftShankPG.AngAcc(:,3),'r')




%---Left thigh

figure
plot(AKIN.LeftThigh.AngAcc(:,1))
hold on
plot(VKIN.LeftThigh.AngAcc(:,1),'r')

figure
plot(AKIN.LeftThigh.AngAcc(:,2))
hold on
plot(VKIN.LeftThigh.AngAcc(:,2),'r')

figure
plot(AKIN.LeftThigh.AngAcc(:,3))
hold on
plot(VKIN.LeftThigh.AngAcc(:,3),'r')


%--Right Foot

figure
plot(AKIN.RightFoot.AngAcc(:,1))
hold on
plot(VKIN.RightFoot.AngAcc(:,1),'r')

figure
plot(AKIN.RightFoot.AngAcc(:,2))
hold on
plot(VKIN.RightFoot.AngAcc(:,2),'r')

figure
plot(AKIN.RightFoot.AngAcc(:,3))
hold on
plot(VKIN.RightFoot.AngAcc(:,3),'r')



%---Right shank

figure
plot(AKIN.RightShankPG.AngAcc(:,1))
hold on
plot(VKIN.RightShankPG.AngAcc(:,1),'r')

figure
plot(AKIN.RightShankPG.AngAcc(:,2))
hold on
plot(VKIN.RightShankPG.AngAcc(:,2),'r')

figure
plot(AKIN.RightShankPG.AngAcc(:,3))
hold on
plot(VKIN.RightShankPG.AngAcc(:,3),'r')




%---Right thigh

figure
plot(AKIN.RightThigh.AngAcc(:,1))
hold on
plot(VKIN.RightThigh.AngAcc(:,1),'r')

figure
plot(AKIN.RightThigh.AngAcc(:,2))
hold on
plot(VKIN.RightThigh.AngAcc(:,2),'r')

figure
plot(AKIN.RightThigh.AngAcc(:,3))
hold on
plot(VKIN.RightThigh.AngAcc(:,3),'r')

%% ANGULAR VELOCITY IN GLOBAL -------

% comes from the Vaughan Variable !AngularVelocityLefthThigh-3
% Only used to calculate power

% LEFT FOOT
figure
plot(AKIN.LeftFoot.AngVel(:,1))
hold on
plot(SEG.LeftFoot.AngVel(:,1),'r')

figure
plot(AKIN.LeftFoot.AngVel(:,2))
hold on
plot(SEG.LeftFoot.AngVel(:,2),'r')

figure
plot(AKIN.LeftFoot.AngVel(:,3))
hold on
plot(SEG.LeftFoot.AngVel(:,3),'r')



%---left shank

figure
plot(AKIN.LeftShankPG.AngVel(:,1))
hold on
plot(SEG.LeftShankPG.AngVel(:,1),'r')

figure
plot(AKIN.LeftShankPG.AngVel(:,2))
hold on
plot(SEG.LeftShankPG.AngVel(:,2),'r')

figure
plot(AKIN.LeftShankPG.AngVel(:,3))
hold on
plot(SEG.LeftShankPG.AngVel(:,3),'r')




%---Left thigh

figure
plot(AKIN.LeftThigh.AngVel(:,1))
hold on
plot(SEG.LeftThigh.AngVel(:,1),'r')

figure
plot(AKIN.LeftThigh.AngVel(:,2))
hold on
plot(SEG.LeftThigh.AngVel(:,2),'r')

figure
plot(AKIN.LeftThigh.AngVel(:,3))
hold on
plot(SEG.LeftThigh.AngVel(:,3),'r')


%--Right Foot

figure
plot(wdg(:,1))
hold on
plot(SEG.RightFoot.AngVel(:,1),'r')


figure
plot(wdg(:,2))
hold on
plot(SEG.RightFoot.AngVel(:,2),'r')


figure
plot(wdg(:,3))
hold on
plot(SEG.RightFoot.AngVel(:,3),'r')
title('rfoot')


%---Right shank

figure
plot(wpg(:,1))
hold on
plot(SEG.RightShankPG.AngVel(:,1),'r')


figure
plot(wpg(:,2))
hold on
plot(SEG.RightShankPG.AngVel(:,2),'r')

figure
plot(wpg(:,3))
hold on
plot(SEG.RightShankPG.AngVel(:,3),'r')
title('rshank')



%---Right thigh

figure
plot(AKIN.RightThigh.AngVel(:,1))
hold on
plot(SEG.RightThigh.AngVel(:,1),'r')

figure
plot(AKIN.RightThigh.AngVel(:,2))
hold on
plot(SEG.RightThigh.AngVel(:,2),'r')

figure
plot(AKIN.RightThigh.AngVel(:,3))
hold on
plot(SEG.RightThigh.AngVel(:,3),'r')


