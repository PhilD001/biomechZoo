function data = hipJointCentreHarrington(data)


if nargin==0
    grab
end
conv = 1000;

RASI = data.RASI.line;
LASI = data.LASI.line;
SACR = data.SACR.line;


% Define Pelvis coordinate system
%
b1 = 0.5*(LASI+RASI)-SACR;
b2 = RASI-LASI;
ip = makeunit(b2);                 % epy
b3 = b1- (b1.*ip).*ip;
kp = makeunit(b3);                 % epx
jp = cross(kp,ip);                 % epz



mASIS = pointonline(RASI,LASI,0.5); % in GCS verified in director

PW = magnitude(RASI-LASI);                       % Pelvic Width (mm)
PD = magnitude(SACR-mASIS);                      % Pelvic Depth (mm)

RLL = data.zoosystem.Anthro.RLegLength/conv;     % Right leg length

rxhat = -0.24.*PD - 9.9;                         % Antero-posterior
ryhat = -0.16.*PW - 0.04.*RLL - 7.1;             % supero-inferior
rzhat =  0.28.*PD + 0.16.*PW + 7.9;               % medio-lateral
rhat = [-rxhat ryhat rzhat];

LLL = data.zoosystem.Anthro.LLegLength/conv;
lxhat = -0.24.*PD-9.9;
lyhat = -0.16.*PW - 0.04.*LLL + 7.1;
lzhat =  0.28.*PD + 0.16.*PW + 7.9;
lhat = [lxhat lyhat lzhat];



RHJChar = zeros(size(RASI));
LHJChar = zeros(size(RASI));
I = longunit(ip,'i');
J = longunit(ip,'j');
K = longunit(ip,'k');

for i = 1:length(RASI)
    PLCS = [ip(i,:) ; jp(i,:) ; kp(i,:)];
    GCS = [I(i,:) ;  J(i,:) ; K(i,:)];
    RHJChar(i,:) = ctransform(PLCS,GCS,rhat(i,:))+mASIS(i,:);   %
    LHJChar(i,:) = ctransform(PLCS,GCS,lhat(i,:))+mASIS(i,:);   %
end




% for i = 1:length(RASI)
%     
%     PLCS = [ip(i,:) ; jp(i,:) ; kp(i,:)];
%     GCS = [I(i,:) ;  J(i,:) ; K(i,:)];
%     RHJChar(i,:) = ctransform(PLCS,GCS,rhat(i,:));   %
%     LHJChar(i,:) = ctransform(PLCS,GCS,lhat(i,:));   %
%     
% end



data.RHJChar.line = RHJChar;
data.RHJChar.event = struct;


data.LHJChar.line = LHJChar;
data.LHJChar.event = struct;

data.mASIS.line  = mASIS;
data.mASIS.event = struct;


figure
subplot(2,3,1)
plot(data.RHJChar.line(:,1))
hold on
plot(data.RHJC.line(:,1))
title('x')
ylabel('Hip Joint Centre')
r = mean(data.RHJChar.line(:,1) - data.RHJC.line(:,1));

subplot(2,3,2)
plot(data.RHJChar.line(:,2))
hold on
plot(data.RHJC.line(:,2))
title('y')
r = mean(data.RHJChar.line(:,2) - data.RHJC.line(:,2));

subplot(2,3,3)
plot(data.RHJChar.line(:,3))
hold on
plot(data.RHJC.line(:,3))
title('z')
r = mean(data.RHJChar.line(:,3) - data.RHJC.line(:,3));

subplot(2,3,4)
plot(data.LHJChar.line(:,1))
hold on
plot(data.LHJC.line(:,1))
title('x')
ylabel('Hip Joint Centre')
r = mean(data.LHJChar.line(:,1) - data.LHJC.line(:,1));

subplot(2,3,5)
plot(data.LHJChar.line(:,2))
hold on
plot(data.LHJC.line(:,2))
title('y')
r = mean(data.LHJChar.line(:,2) - data.LHJC.line(:,2));

subplot(2,3,6)
plot(data.LHJChar.line(:,3))
hold on
plot(data.LHJC.line(:,3))
title('z')
r = mean(data.LHJChar.line(:,3) - data.LHJC.line(:,3));


