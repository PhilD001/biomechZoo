% program to read avi files and click the points
clear, close all

% load image
%name = 'HindfootTibiaDorsiflexion';
%name = 'HindfootTibiaInversion';
% name = 'HindfootTibiaRotation';
% calibv=[-20,20];

%name = 'ForefootHindfootDorsiflexion';
%name = 'ForefootHindfootSupination';
%name = 'ForefootHindfootAdduction';
%calibv=[-20,20];
% 
% name = 'ForefootTibiaDorsiflex';
% calibv=[-30,30];
% 
%name = 'ForefootTibiaSupination';
%name = 'ForefootTibiaAdduction';
%calibv=[-20,30];
% 
% name = 'NormArchHeight';
% calibv=[0,35];
% 
% name = 'HalluxDorsiflexion';
% calibv=[0,50];

name = 'TibiaFemurRotation';
calibv=[-20,30];



calibh=[0,100];

I = imread([name '.bmp']);
imshow(I);
hold on;

% look for points x,y
pixval on

fs = 18;

% calib
title('calib vertical ( 2 points )','FontSize',fs);
[xv,yv] = getpts;

title('calib horizontal ( 2 points )','FontSize',fs);
[xh,yh] = getpts;

title('upper boundary ( n points )','FontSize',fs);
[xup,yup] = getpts;

title('lower boundary ( n points )','FontSize',fs);
[xlo,ylo] = getpts;


vn = yv(2) - yv(1);
cv = (calibv(2)-calibv(1))/vn;

yup = cv * (yup -yv(1)) + calibv(1);
ylo = cv * (ylo -yv(1)) + calibv(1);

vh = xh(2) - xh(1);
ch = (calibh(2)-calibh(1))/vh;

xup = ch * (xup - xh(1)) + calibh(1);
xlo = ch * (xlo - xh(1)) + calibh(1);

% sort data points 
Mups = sortrows([xup,yup],1);
Mlos = sortrows([xlo,ylo],1);


% remove identical horizontal points
Mup(1,:)=Mups(1,:);
k=2;
for i=2:length(Mups(:,1))
    if Mups(i,1) > Mups(i-1,1)
       Mup(k,:) = Mups(i,:);
       k=k+1;
    end
end

Mlo(1,:)=Mlos(1,:);
k=2;
for i=2:length(Mlos(:,1))-1
    if Mlos(i+1,1) > Mlos(i,1)
       Mlo(k,:) = Mlos(i,:);
       k=k+1;
    end
end

% interpolate on same values
timen = (0:2:100)';
yloi = interp1(Mlo(:,1),Mlo(:,2),timen,'spline','extrap');
yupi = interp1(Mup(:,1),Mup(:,2),timen,'spline','extrap');
ymean = mean([yupi,yloi],2);

% plot results
figure('name','results')
plot(xup,yup,'g*',xlo,ylo,'r*')
hold on;
plot(timen,yupi,'g',timen,yloi,'r',timen,ymean,'k');
title(name)

% save data
M = [timen,yloi,ymean,yupi];
save([name '.txt'],'M','-ascii');    
  



   