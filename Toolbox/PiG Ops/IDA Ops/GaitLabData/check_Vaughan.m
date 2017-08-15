% check dynamic outputs

% VAughan Force data output from Gait lab is not so great, compare visually
% with graphs in gaitlab

% REMAINS TO CHECK HIP

% RANKLE FORCE

figure
plot(-F_ranklePG(:,4))
hold on
plot(RightAnkleForce(:,2),'r')

figure
plot(F_ranklePG(:,5))
hold on
plot(RightAnkleForce(:,1),'r')

figure
plot(-F_ranklePG(:,6))
hold on
plot(RightAnkleForce(:,3),'r')

% Right Ankle Moment

figure
plot(M_ranklePG(:,4))
hold on
plot(RightAnkleMoment(:,1),'r')

figure
plot(M_ranklePG(:,5))
hold on
plot(RightAnkleMoment(:,3),'r')

figure
plot(M_ranklePG(:,6))
hold on
plot(RightAnkleMoment(:,2),'r')


% check ang vel

plot(AKIN.RightFoot.AngVel)

% Right Ankle Power

figure
plot(P_ranklePG)
hold on
plot(RightAnklePower,'r')


% Right Knee FORCE

figure
plot(F_rkneePG(:,4))
hold on
plot(RightKneeForce(:,2),'r')

figure
plot(F_rkneePG(:,5))
hold on
plot(RightKneeForce(:,1),'r')


figure
plot(F_rkneePG(:,6))
hold on
plot(RightKneeForce(:,3),'r')

% Right knee Moment

figure
plot(M_rkneePG(:,4))
hold on
plot(RightKneeMoment(:,1),'r')

figure
plot(M_rkneePG(:,5))
hold on
plot(RightKneeMoment(:,2),'r')

figure
plot(-M_rkneePG(:,6))
hold on
plot(RightKneeMoment(:,3),'r')



% Right Knee Power

figure
plot(P_rkneePG)
hold on
plot(RightKneePower,'r')



%===LEFT====



% LANKLE FORCE

figure
plot(-F_lanklePG(:,4))
hold on
plot(LeftAnkleForce(:,2),'r')

figure
plot(-F_lanklePG(:,5))
hold on
plot(LeftAnkleForce(:,1),'r')

figure
plot(-F_lanklePG(:,6))
hold on
plot(LeftAnkleForce(:,3),'r')

% Left Ankle Moment

figure
plot(M_lanklePG(:,4))
hold on
plot(LeftAnkleMoment(:,1),'r')

figure
plot(M_lanklePG(:,5))
hold on
plot(LeftAnkleMoment(:,3),'r')

figure
plot(M_lanklePG(:,6))
hold on
plot(LeftAnkleMoment(:,2),'r')



% Left Ankle Power

figure
plot(P_lanklePG)
hold on
plot(LeftAnklePower,'r')


% Left Knee FORCE

figure
plot(F_lkneePG(:,4))
hold on
plot(LeftKneeForce(:,2),'r')

figure
plot(-F_lkneePG(:,5))
hold on
plot(LeftKneeForce(:,1),'r')


figure
plot(F_lkneePG(:,6))
hold on
plot(LeftKneeForce(:,3),'r')

% Left knee Moment

figure
plot(M_lkneePG(:,4))
hold on
plot(LeftKneeMoment(:,1),'r')

figure
plot(M_lkneePG(:,5))
hold on
plot(LeftKneeMoment(:,2),'r')

figure
plot(-M_lkneePG(:,6))
hold on
plot(LeftKneeMoment(:,3),'r')



% Left Knee Power

figure
plot(P_rkneePG)
hold on
plot(LeftKneePower,'r')