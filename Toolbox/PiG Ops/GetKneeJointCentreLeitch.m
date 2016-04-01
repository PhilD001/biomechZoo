function KJC = GetKneeJointCentreLeitch(HJC,THI,KNE,KW,mdiam)

% GetKneeJointCentreLeitch returns knee joint centere according to Leitch 
% 
% ARGUMENTS
% HJC       ...    n x 3 matrix of hip joint centre coordinate
% THI       ...    n x 3 matrix of thigh marker coordinates
% KNE       ...    n x 3 matrix of knee marker coordinates
% KW        ...    Knee Width 
% mdiam     ...    Marker diameter
%
% RETURNS
% KJC       ...   Knee joint centre coordinates in GCS
%
%
% NOTES 
% - code based on Jessica Leitch. The Biomechanics of Patellofemoral Pain Syndrome in Distance Runners.
% DPhil Thesis submitted to the University of Oxford, Department of Engineering Science,2011
%
% - KJC must fulfill the following: 
% 1. It lies in the same plane as the HJC and the THI and KNE markers.
% 2. The distance to the KNE marker is half the measured knee width and marker diameter.
% 3. The line from the KJC to the KNE marker is perpendicular to the line from the KJC to the HJC.
% 
%
% Created by Philippe C. Dixon October 2012


%--TRANSLATE GCS TO PLANE COORDINATE SYSTEM (PCS)

KNEtr = zeros(size(KNE));    
THItr = THI-KNE;
HJCtr = HJC-KNE;

%--CREATE PCS WITH ORIGIN AT KNEE

ipl = makeunit(HJCtr); 
tempj = makeunit(THItr); 
kpl = makeunit(cross(ipl,tempj,2));
jpl = makeunit(cross(kpl,ipl,2));


%--CONVERT MARKERS TO PCS

HJCpl = zeros(size(KNE));
KNEpl = zeros(size(KNE));
THIpl = zeros(size(KNE));

for i = 1:length(KNE)
    PLCS = [ipl(i,:) ; jpl(i,:) ; kpl(i,:)];
    HJCpl(i,:) = ctransform(gunit,PLCS,HJCtr(i,:));   %
    THIpl(i,:) = ctransform(gunit,PLCS,THItr(i,:));   % 
end

%--SOLVE SYSTEM OF EQUATIONS THAT SATISFIES 1,2,3 (IN PCS)

r = (KW+mdiam*2)/2;  % radius of circle in plane
rstring = ['r^2-',num2str(r^2)];

KJCpl = zeros(size(KNE));

for i = 1:length(KNE)
    x1 = 0;
    y1 = 0;
    
    x2 = HJCpl(i,1);
    y2 = HJCpl(i,2);
    
    x1string = ['x1-',num2str(x1)];
    y1string = ['y1-',num2str(y1)];
    x2string = ['x2-',num2str(x2)];
    y2string = ['y2-',num2str(y2)];
        
    s = solve('(y3/x3)+((x2-x3)/(y2-y3))','x3^2+y3^2-r^2',rstring,x1string,x2string,y1string,y2string,'Real',true);
    
    if ~isfield(s,'x3')    % fix for r2014b
        KJCpl(i,1) = NaN;
        KJCpl(i,2) = NaN;
    else
        KJCpl(i,1) = s.x3(1);
        KJCpl(i,2) = -(abs(s.y3(1)));  %  negative is the right solution
    end
    
end


%--TRANSFORM KJC INTO GCS

KJC = zeros(size(KNE));

for i = 1:length(KNE)
    PLCS = [ipl(i,:) ; jpl(i,:) ; kpl(i,:)];
    KJC(i,:) = ctransform(PLCS,gunit,KJCpl(i,:));     

end

KJC = KJC+KNE; % translate KJC to global origin

    
    