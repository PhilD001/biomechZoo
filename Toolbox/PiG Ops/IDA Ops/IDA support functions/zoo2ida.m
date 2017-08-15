function [ANTHRO,LKIN,COM, AKIN,DYNAMICS,COP,Tz,FPproperties,StrideProperties,StridePropertiesCOP,HS0,HS3,TO0,data] = zoo2ida(zdata,cdata,zfilename)

%   zoo2IDA will output segment information from zoo data created by JJ.
%
%   PREREQUISITES
%   zdata must contain the events TO and HS in the channels fz1 and fz2
%
%   ARGUMENTS
%
%   ZDATA        ...   loaded .zoo file
%   CDATA        ...   loaded coordinate data from xls file in matrix form
%   ZFILENAME    ...   full path of file as string
%
%   RETURNS
%   
%   DYNAMICS     ...   Struct containing force,moment and power info
%   AKIN         ...   struct containing all joint angles
%   Tz
%   FProperties  ...   struct containing REFdis, REFort, dis
%                         -REFdis(3 element vector that defines the origin of the data)
%                         -REFort(3X3 matrix of ijk unit vectors that defines the coordinate system of the zoo data
%                         -dis (distance between force plates)
%
%
%
%   HS3      ... Heel strike 3 calculated from ida bones
%   TO0      ... Toe off 0 calculated from ida bones
%   
%   Caution.  all segments above and including the pelvis do not have the
%   proper center of mass
%
%   Created by JJ Loh  2007/06/21
%   Departement of Kinesiology
%   McGill University, Montreal, Quebec Canada
%
%   Updated by JJ LOH 2007/07/05
%   1)output xyz vectors for inverse dynamic analysis
%   2)redefined the origin as REFdis
%   3)redefined the orientation as REFort
%
%   Updatad by Phil Dixon 2007/07/07
%   1)output moments
%   2)COM based on DeLeva (adjusted Zatsiorsky)
%   3)added thorax orientation axes as output
%   4) output bone info is in meters
%
%   Updated by JJ & Phil 2007/09/12
%   Added heel strike 3
%
%   Updated by Phil 2007/09/23
%   added TO0 
%
%   updated by Phil 2007/11/15
%    -COP calculation takes true centre of plate into consideration
%    -Free torque calculation corrected (as per kwon3d)
%
%  updated 2007/12/10
%  -Tz converted to action oriented system
% 
% updated 2007/12/16
% -fixed dis (distance between plates)
% -can now accept and process kinematics of t-pose data. Analog channels
% contain garbage
%
%  NOTES:
%    -data in "data" is scaled down by a factor of 1000. Multiply by 1000
%    to fit onto director graphs

[REFdis,REFort,force_dis] = GetForceplatePosition(cdata,zfilename);
FPproperties.REFdis = REFdis;       %origin of FP
FPproperties.REFort = REFort;%fp LCS
FPproperties.dis = force_dis;       % dist btw FPs

amat = {'PEL','Pelvis';...
    'LFE','LeftFemur';...
    'LTI','LeftTibia';...
    'LFO','LeftFoot';...
    'LTO','LeftToe';...
    'RFE','RightFemur';...
    'RTI','RightTibia';...
    'RFO','RightFoot';...
    'RTO','RightToe';...
    'TRX','Thorax';...
    'HED','Head';...
    'LCL','LeftClavicle';...
    'LHU','LeftHumerus';...
    'LRA','LeftRadius';...
    'LHN','LeftHand';...
    'RCL','RightClavicle';...
    'RHU','RightHumerus';...
    'RRA','RightRadius';...
    'RHN','RightHand'};

dim = {'O','A','L','P'};


% O is origin of bone, at distal joint
% A is an anterior vector from bone
% L is a lateral vector
% P is the proximal joint

data = struct;

for i = 1:length(amat(:,1))
    d = [];
    for j = 1:4
        d{j} = zdata.([amat{i,1},dim{j}]).line;
    end
    bn = amat{i,2};
    switch bn
        case 'Pelvis'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];             
           
        case 'LeftFemur'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .591];             %based on DeLeva
            
        case 'LeftTibia'
            pjoint = data.LeftFemur.dist_end;
            djoint = [0 0 0];
            com = [0 0 .561];
            
        case 'LeftFoot'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .559];
            
        case 'RightFemur'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .591];             %based on DeLeva
        case 'RightTibia'
            pjoint = data.RightFemur.dist_end;
            djoint = [0 0 0];
            com = [0 0 .561];
             
        case 'RightFoot'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .559];
             
        case 'Thorax'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'Head'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftHumerus'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftRadius'
            pjoint = data.LeftHumerus.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftHand'
            pjoint = data.LeftRadius.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightHumerus'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightRadius'
            pjoint = data.RightHumerus.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightHand'
            pjoint = data.RightRadius.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        otherwise
            continue
    end



    [dis,ort,pjoint,djoint,com] = getdata(d,pjoint,djoint,com,REFdis,REFort);
    data.(bn).dis =dis;
    data.(bn).ort =ort;
    data.(bn).prox_end = pjoint;       %output is in meters       
    data.(bn).dist_end = djoint;              
    data.(bn).com = com;                  
end



data.Xthorax = makeunit(data.Thorax.ort(:,:,3));
data.Ythorax = makeunit(data.Thorax.ort(:,:,1));
data.Zthorax = makeunit(data.Thorax.ort(:,:,2));

data.Xpelvis = makeunit(data.Pelvis.ort(:,:,3));
data.Ypelvis = makeunit(data.Pelvis.ort(:,:,1));
data.Zpelvis = makeunit(data.Pelvis.ort(:,:,2));

data.X1 = makeunit(data.RightFemur.ort(:,:,3));
data.Y1 = makeunit(data.RightFemur.ort(:,:,1));
data.Z1 = makeunit(data.RightFemur.ort(:,:,2));

data.X2 = makeunit(data.LeftFemur.ort(:,:,3));
data.Y2 = makeunit(data.LeftFemur.ort(:,:,1));
data.Z2 = makeunit(data.LeftFemur.ort(:,:,2));

data.X3 = makeunit(data.RightTibia.ort(:,:,3));
data.Y3 = makeunit(data.RightTibia.ort(:,:,1));
data.Z3 = makeunit(data.RightTibia.ort(:,:,2));

data.X4 = makeunit(data.LeftTibia.ort(:,:,3)); 
data.Y4 = makeunit(data.LeftTibia.ort(:,:,1));
data.Z4 = makeunit(data.LeftTibia.ort(:,:,2));

data.X5 = makeunit(data.RightFoot.ort(:,:,3));
data.Y5 = makeunit(data.RightFoot.ort(:,:,1));
data.Z5 = makeunit(data.RightFoot.ort(:,:,2));

data.X6 = makeunit(data.LeftFoot.ort(:,:,3));
data.Y6 = makeunit(data.LeftFoot.ort(:,:,1));
data.Z6 = makeunit(data.LeftFoot.ort(:,:,2));

% data.fx1 = zdata.fx1.line;
% data.fy1 = zdata.fy1.line;
% data.fz1 = zdata.fz1.line;
% 
% data.fx2 = zdata.fx2.line;
% data.fy2 = zdata.fy2.line;
% data.fz2 = zdata.fz2.line;
% 
% data.mx1 = zdata.mx1.line;
% data.my1 = zdata.my1.line;
% data.mz1 = zdata.mz1.line;
% 
% data.mx2 = zdata.mx2.line;
% data.my2 = zdata.my2.line;
% data.mz2 = zdata.mz2.line;

if ~isempty(findstr(zfilename,'T-Pose'))             %fill FP channels with junk if no FP data for T-Pose
    
    
    
    zdata.fx1.line = ones(size(zdata.RHEE.line),1);
    zdata.fy1.line = ones(size(zdata.RHEE.line),1);
    zdata.fz1.line = ones(size(zdata.RHEE.line),1);

    zdata.fx2.line = ones(size(zdata.RHEE.line),1);
    zdata.fy2.line = ones(size(zdata.RHEE.line),1);
    zdata.fz2.line = ones(size(zdata.RHEE.line),1);

    zdata.mx1.line = ones(size(zdata.RHEE.line),1);
    zdata.my1.line = ones(size(zdata.RHEE.line),1);
    zdata.mz1.line = ones(size(zdata.RHEE.line),1);

    zdata.mx2.line = ones(size(zdata.RHEE.line),1);
    zdata.my2.line = ones(size(zdata.RHEE.line),1);
    zdata.mz2.line = ones(size(zdata.RHEE.line),1);

    
    data.fx1 = zdata.fx1.line;
    data.fy1 = zdata.fy1.line;
    data.fz1 = zdata.fz1.line;

    data.fx2 = zdata.fx2.line;
    data.fy2 = zdata.fy2.line;
    data.fz2 = zdata.fz2.line;

    data.mx1 = zdata.mx1.line;
    data.my1 = zdata.my1.line;
    data.mz1 = zdata.mz1.line;

    data.mx2 = zdata.mx2.line;
    data.my2 = zdata.my2.line;
    data.mz2 = zdata.mz2.line;
    
    
    data.events.TO1 = [1 1 1];
    data.events.TO2 = [1 1 1];
    data.events.HS1 = [1 1 1];
    data.events.HS2 = [1 1 1];
   
else                %for trial files

    data.fx1 = zdata.fx1.line;
    data.fy1 = zdata.fy1.line;
    data.fz1 = zdata.fz1.line;

    data.fx2 = zdata.fx2.line;
    data.fy2 = zdata.fy2.line;
    data.fz2 = zdata.fz2.line;

    data.mx1 = zdata.mx1.line;
    data.my1 = zdata.my1.line;
    data.mz1 = zdata.mz1.line;

    data.mx2 = zdata.mx2.line;
    data.my2 = zdata.my2.line;
    data.mz2 = zdata.mz2.line;

    data.events.TO1 = zdata.fz1.event.TO1;
    data.events.TO2 = zdata.fz2.event.TO2;
    data.events.HS1 = zdata.fz1.event.HS1;
    data.events.HS2 = zdata.fz2.event.HS2;

    


end

gunit = [1 0 0 ; 0 1 0 ; 0 0 1];        %global coordinate system       
g = [0 0 9.8];                          %g in global   (what is g in MTL?)                 
g = ctransform(gunit, REFort, g);       %g expressed in REFort          




%------CALLING MAIN OUTPUT FUNCTIONS------

mass = GetMass(zfilename);

[ANTHRO,LKIN,COM, AKIN,DYNAMICS,COP,Tz] = IDA(mass,zdata.zoosystem.Header.VideoHZ,g,data,force_dis);

[StrideProperties,HS0,HS3,TO0] = GetStrideProperties(zdata,data,zfilename);
[StridePropertiesCOP] = GetCOPStrideProperties(COP,force_dis,StrideProperties.LegLength,zfilename);







function [dis,ort,pjnt,djnt,cm] = getdata(data,pjoint,djoint,com,ref,refort)


% ref    ...  origin of FP system (coord of FP bottom right in meters)
% refort ...  FP LCS
%-----------JJ ORIGINAl CODE START-----------

dis = displace(data{1}/1000,-ref);      %translate bone origin data to FP coord 


a = (data{2}-data{1})/1000;         %a: distal joint - origin (new vector starting at O)
l = (data{3}-data{1})/1000;         %l: lateral - origin
p = (data{4}-data{1})/1000;         %p: proximal joint - origin 

[rw,cl] = size(a);

ort = [];
pjnt = [];
djnt = [];
cm = [];



for i = 1:rw
    unt = [a(i,:);l(i,:);p(i,:)];
    unt = ctransform(refort,gunit,unt);  %?
    [r,c] = size(pjoint);
    if r==1        
        pjplate = ctransform(unt,gunit,pjoint)+dis(i,:);
        pjnt = [pjnt;pjplate];
    end
    [r,c] = size(djoint);
    if r==1
        djplate = ctransform(unt,gunit,djoint)+dis(i,:);
        djnt = [djnt;djplate];
    end
    cplate = ctransform(unt,gunit,com)+dis(i,:);
    cm = [cm;cplate];
    
    oplate(1,1:3,1) = unt(1,1:3);          %segment embedded axes i  
    oplate(1,1:3,2) = unt(2,1:3);           %segment embedded axes j 
    oplate(1,1:3,3) = unt(3,1:3);           %segment embedded axes k 
    ort = [ort;oplate];

    
    
end



if isempty(pjnt)  %if the joints are empty just return the incomeing joint
    pjnt = pjoint;
end
if isempty(djnt)
    djnt = djoint;
end
    
    %-----------JJ ORIGINAl CODE END-----------
    




    

%-----------------DEFINE LCS FOR EACH SUBJECT-------------------------------

function [REFdis,REFort,dis] = GetForceplatePosition(coord,zfilename)


% REFdis   ... coordinates of fp1 bottom right (origin of LCS)
% REFort   ... LCS based at fp1 bottom right
% dis      ... distance between the plates (x,y,z)

[COORD,DIS]=fplate_coord(coord);

indx= findstr(zfilename,'subject');           %choose correct coordinate system based on subject/condition
subject = zfilename(indx+7:indx+8);

if findstr(zfilename,'T-Pose')                  %to run t-pose 
    condition = 'f';
else
condition = zfilename(indx+10);
end

switch condition
    case 'f'
        switch subject
            case '01'
                REFdis = COORD.S1.Flat.REFdis;
                REFort = COORD.S1.Flat.REFort;
                dis = DIS.S1.Flat;
            case '02'
                REFdis = COORD.S2.Flat.REFdis;
                REFort = COORD.S2.Flat.REFort;
                dis = DIS.S2.Flat;
            case '03'
                REFdis = COORD.S3.Flat.REFdis;
                REFort = COORD.S3.Flat.REFort;
                dis = DIS.S3.Flat;
            case '04'
                REFdis = COORD.S4.Flat.REFdis;
                REFort = COORD.S4.Flat.REFort;
                dis = DIS.S4.Flat;
            case '05'
                REFdis = COORD.S5.Flat.REFdis;
                REFort = COORD.S5.Flat.REFort;
                dis = DIS.S5.Flat;
            case '06'
                REFdis = COORD.S6.Flat.REFdis;
                REFort = COORD.S6.Flat.REFort;
                dis = DIS.S6.Flat;
            case '07'
                REFdis = COORD.S7.Flat.REFdis;
                REFort = COORD.S7.Flat.REFort;
                dis = DIS.S7.Flat;
            case '08'
                REFdis = COORD.S8.Flat.REFdis;
                REFort = COORD.S8.Flat.REFort;
                dis = DIS.S8.Flat;
            case '09'
                REFdis = COORD.S9.Flat.REFdis;
                REFort = COORD.S9.Flat.REFort;
                dis = DIS.S9.Flat;
            case '10'
                REFdis = COORD.S10.Flat.REFdis;
                REFort = COORD.S10.Flat.REFort;
                dis = DIS.S10.Flat;
        end

    case 'c'

        switch subject
            case '01'
                REFdis = COORD.S1.Cross.REFdis;
                REFort = COORD.S1.Cross.REFort;
                dis = DIS.S1.Cross;
            case '02'
                REFdis = COORD.S2.Cross.REFdis;
                REFort = COORD.S2.Cross.REFort;
                dis = DIS.S2.Cross;
            case '03'
                REFdis = COORD.S3.Cross.REFdis;
                REFort = COORD.S3.Cross.REFort;
                dis = DIS.S3.Cross;
            case '04'
                REFdis = COORD.S4.Cross.REFdis;
                REFort = COORD.S4.Cross.REFort;
                dis = DIS.S4.Cross;
            case '05'
                REFdis = COORD.S5.Cross.REFdis;
                REFort = COORD.S5.Cross.REFort;
                dis = DIS.S5.Cross;
            case '06'
                REFdis = COORD.S6.Cross.REFdis;
                REFort = COORD.S6.Cross.REFort;
                dis = DIS.S6.Cross;
            case '07'
                REFdis = COORD.S7.Cross.REFdis;
                REFort = COORD.S7.Cross.REFort;
                dis = DIS.S7.Cross;
            case '08'
                REFdis = COORD.S8.Cross.REFdis;
                REFort = COORD.S8.Cross.REFort;
                dis = DIS.S8.Cross;
            case '09'
                REFdis = COORD.S9.Cross.REFdis;
                REFort = COORD.S9.Cross.REFort;
                dis = DIS.S9.Cross;
            case '10'
                REFdis = COORD.S10.Cross.REFdis;
                REFort = COORD.S10.Cross.REFort;
                dis = DIS.S10.Cross;
        end

end
    


%-----------------------PART I : ANTHROPOMETRICS -----------------------
%                                                                       
%           -segment mass (kg)                                          
%           -segment length (m)                                            
%           -segment moment of inertia (kg*m^2 )                        
function mass = GetMass(filename)


M = [76.07  83.91 81.58 69.61 63.67 66.61 78.21 80.15 90.81 77.17 ]';     %subject body masses 1,2,3.. kg.


indx= findstr(filename,'subject');
subject = filename(indx+7:indx+8);

switch subject                        %choose correct subject to return anthropometrics
    case '01'
        mass =M(1);
    case '02'
        mass =M(2);
    case '03'
        mass =M(3);
    case '04'
        mass =M(4);
    case '05'
        mass =M(5);
   case '06'
        mass =M(6);
    case '07'
        mass =M(7);
    case '08'
        mass =M(8);
    case '09'
        mass =M(9);
    case '10'
        mass =M(10);
end




%function [DYNAMICS,AKIN,COP,Tz] = IDA(mass,dis,fsamp,g,data)
function [ANTHRO,LKIN,COM, AKIN,DYNAMICS,COP,Tz] = IDA(mass,fsamp,g,data,dis)



ANTHRO = anthro(data,mass); 


%-----------------PART II: LINEAR KINEMATIC DATA----------
%
%                 -Joint centers (m)
%                 -segment embedded axes xyz (expressed in XYZ)
LKIN = linear_kin(data); 


%-----------------PART III: CENTER OF MASS ---------
%
%               -position of com   (m)
%               -acceleration of com (m/s^2)
%           
%               Note: requires choice of derivative/filtering techhique
COM = com(data,fsamp);


%---------------PART IV : ANGULAR KINEMATICS---------
%
%                 -joint anatomical angles (degrees)
%                 -angular velocity (rad/s)
%                 -angular acceleration (rad/s^2)
%                 -Euler reference axes
%                 -G&S reference axes
%
%                 Note: requires choice of derivative/filtering techhique

AKIN = angular_kin(LKIN,fsamp);



%------------------T-POSE ADJUSTMENT-------------

%For Kinematics T-pose adjustment was made downstream, but in order to
%express forces and moments in anatomical system, Grood and Suntay angles
%must be adjusted before entering the IDA calculations!!!! Groos and Suntay
%angles are stored in AKIN,


% AKINt = struct;
% 
% segname = fieldnames(AKIN.Segment);
% 
% for i = 1:length(seg)
% 
% AKINt.Segment.(segname{i}).GSAxes = tposeadj(AKIN.Segment.(segname{i}).GSAxes,segname,filename);
% 
% end



        


%------------PART V : DYNAMICS OF JOINTS---------
%
%           Force (N)
%           Moments (N*m)
%           Power (W)

%   1) LOAD ANALOG DATA 
%
%   load downsampled & filtered analog data from zoo2ida

F = [data.fx1 data.fy1 data.fz1 data.fx2 data.fy2 data.fz2];    % N
T = [data.mx1 data.my1 data.mz1 data.mx2 data.my2 data.mz2];    % N*m


%   2) POSITION OF COP DATA -------------
%
%           -COP (m)
%           -values are in each plate's coordinate system
%                                   
%                                   5003.2 plate 1
x1 = 0.027/100; 
y1 = 0/100; 
z1 = -1.525/100; 

x2 = -0.039/100;                   %5009.1  Plate 2
y2 = -0.027/100; 
z2 = -1.555/100; 

COP_1 = COP_oneplate(F(:,1:3),T(:,1:3),x1,y1,z1);
COP_2 = COP_oneplate(F(:,4:6),T(:,4:6),x2,y2,z2);


one= ones(size(COP_2(:,1)));
dis = dis(1)*one;    %assume y_z dis = 0



%----COP used for inverse dynamics must be in GCS: FP bottom right corner 
% bottom right to top right dist x = 0.44m, y = 0

px = 0.44;
py = 0.48;

COP1 = [COP_1(:,1)+px/2      COP_1(:,2)+py/2  COP_1(:,3)]; 
COP2 = [COP_2(:,1)+dis+px/2, COP_2(:,2)+py/2, COP_2(:,3)];            %yes cop2 must include dis





%    3) FREE TORQUE----------------
%
Tz1= free_torque(F(:,1:3),T(:,1:3),COP_1,x1,y1);  
Tz2= free_torque(F(:,4:6),T(:,4:6),COP_2,x2,y2);


%   3) CONVERT FORCES/MOMENTS TO ACTION ORIENTED SYSTEM--------

Fx1 = -1.*F(:,1);
Fy1 = -1.*F(:,2);
Fz1 = -1.*F(:,3);                    %so fz should be positive

Fx2 = -1.*F(:,4);
Fy2 = -1.*F(:,5);
Fz2 = -1.*F(:,6);


Tz1 = -1*Tz1;
Tz2 = -1*Tz2;

% T = T.*-1;
%        


F_1plate = [Fx1 Fy1 Fz1];         
F_2plate = [Fx2 Fy2 Fz2];



% T_1plate = T(:,1:3); %not needed for anything
% T_2plate = T(:,4:6);



%   4) FORCE CALCULATIONS

%global AKIN;

F_rankle = F_rfoot(ANTHRO.Segment.RightFoot.Mass,COM.Segment.RightFoot.Acc, F_1plate,       AKIN.Segment.RightFoot.GSAxes,  g);  %matrix 1-3 column XYZ 4-6 column segment based
F_lankle = F_lfoot(ANTHRO.Segment.LeftFoot.Mass, COM.Segment.LeftFoot.Acc,  F_2plate,       AKIN.Segment.LeftFoot.GSAxes,   g);

F_rknee = F_rsegment(ANTHRO.Segment.RightShank.Mass,COM.Segment.RightShank.Acc,F_rankle(:,1:3),AKIN.Segment.RightShank.GSAxes, g);
F_lknee = F_lsegment(ANTHRO.Segment.LeftShank.Mass, COM.Segment.LeftShank.Acc, F_lankle(:,1:3),AKIN.Segment.LeftShank.GSAxes,  g);

F_rhip = F_rsegment(ANTHRO.Segment.RightThigh.Mass, COM.Segment.RightThigh.Acc,F_rknee(:,1:3), AKIN.Segment.RightThigh.GSAxes, g);
F_lhip= F_lsegment(ANTHRO.Segment.LeftThigh.Mass,   COM.Segment.LeftThigh.Acc, F_lknee(:,1:3), AKIN.Segment.LeftThigh.GSAxes,  g);


%   4) MOMENT CALCULATIONS------------------

M_rankle = M_rfoot(F_1plate,F_rankle(:,1:3),Tz1,LKIN.Segment.RightFoot.AnkleJoint,COP1,COM.Segment.RightFoot.Pos,ANTHRO.Segment.RightFoot.Inertia,AKIN.Segment.RightFoot.AngVel, AKIN.Segment.RightFoot.AngAcc,AKIN.Segment.RightFoot.GSAxes);                                                                                                                  
M_lankle = M_lfoot(F_2plate,F_lankle(:,1:3),Tz2,LKIN.Segment.LeftFoot.AnkleJoint, COP2,COM.Segment.LeftFoot.Pos, ANTHRO.Segment.LeftFoot.Inertia, AKIN.Segment.LeftFoot.AngVel, AKIN.Segment.LeftFoot.AngAcc, AKIN.Segment.LeftFoot.GSAxes ); 

M_rknee = M_rshank(F_rankle(:,1:3), F_rknee(:,1:3),M_rankle(:,1:3),LKIN.Segment.RightFoot.AnkleJoint,LKIN.Segment.RightShank.KneeJoint, COM.Segment.RightShank.Pos, ANTHRO.Segment.RightShank.Inertia,AKIN.Segment.RightShank.AngVel, AKIN.Segment.RightShank.AngAcc,AKIN.Segment.RightShank.GSAxes );                                                                                                                                                                        
M_lknee = M_lshank(F_lankle(:,1:3), F_lknee(:,1:3),M_lankle(:,1:3),LKIN.Segment.LeftFoot.AnkleJoint, LKIN.Segment.LeftShank.KneeJoint,  COM.Segment.LeftShank.Pos,  ANTHRO.Segment.LeftShank.Inertia, AKIN.Segment.LeftShank.AngVel, AKIN.Segment.LeftShank.AngAcc,AKIN.Segment.LeftShank.GSAxes);

M_rhip = M_rthigh(F_rknee(:,1:3),   F_rhip(:,1:3), M_rknee(:,1:3), LKIN.Segment.RightShank.KneeJoint,LKIN.Segment.RightThigh.HipJoint, COM.Segment.RightThigh.Pos,  ANTHRO.Segment.RightThigh.Inertia,AKIN.Segment.RightThigh.AngVel, AKIN.Segment.RightThigh.AngAcc,AKIN.Segment.RightThigh.GSAxes);
M_lhip = M_lthigh(F_lknee(:,1:3),   F_lhip(:,1:3), M_lknee(:,1:3), LKIN.Segment.LeftShank.KneeJoint, LKIN.Segment.LeftThigh.HipJoint,  COM.Segment.LeftThigh.Pos,   ANTHRO.Segment.LeftThigh.Inertia, AKIN.Segment.LeftThigh.AngVel, AKIN.Segment.LeftThigh.AngAcc,AKIN.Segment.LeftThigh.GSAxes );


%   5) ---------------POWER CALCULATIONS---------------

% P_rankle= P_segment(M_rankle(:,4:6),AKIN.Segment.RightFoot.AngVel); 
% P_lankle = P_segment(M_lankle(:,4:6),AKIN.Segment.LeftFoot.AngVel);
% 
% P_rknee = P_segment(M_rknee(:,4:6),AKIN.Segment.RightShank.AngVel);
% P_lknee = P_segment(M_lknee(:,4:6),AKIN.Segment.LeftShank.AngVel);
% 
% P_rhip = P_segment(M_rhip(:,4:6),AKIN.Segment.RightThigh.AngVel);
% P_lhip = P_segment(M_lhip(:,4:6),AKIN.Segment.LeftThigh.AngVel);


%-------------------NORMALIZE TO MASS----------------


F_1plate = F_1plate/mass;            %all subjects strike fp1 with right foot
F_2plate = F_2plate/mass;

% T_1plate = T_1plate/mass; 
% T_2plate = T_2plate/mass; 

Tz1 = Tz1/mass;
Tz2 = Tz2/mass;

F_rankle = F_rankle/mass;
F_lankle = F_lankle/mass;
F_rknee =F_rknee/mass;
F_lknee = F_lknee/mass;
F_rhip = F_rhip/mass;
F_lhip =F_lhip/mass;

M_rankle =M_rankle/mass;
M_lankle =M_lankle/mass;
M_rknee =M_rknee/mass;
M_lknee =M_lknee/mass;
M_rhip =M_rhip/mass;
M_lhip =M_lhip/mass;

% P_rankle =P_rankle/mass;
% P_lankle =P_lankle/mass;
% P_rknee =P_rknee/mass;
% P_lknee =P_lknee/mass;
% P_rhip =P_rhip/mass;
% P_lhip =P_lhip/mass;
% 

%-----------EXPORT JOINT KINEMATICS with known events (toe off on plates)

%data.fx1.event.stepwidth = [1 50.1 0];


%---------- EXPORT COP AS STRUCT-----------

COP = struct;           %for export in LCS of each FP
COP.COP_1 = COP_1;
COP.COP_2 = COP_2;
COP.COP1 = COP1;
COP.COP2 = COP2;

%-----------EXPORT FREE TORQUE AS STRUCT--------

Tz = struct; 

Tz.Tz1 = Tz1;
Tz.Tz2 = Tz2;


%-----------EXPORT JOINT DYNAMICS AS STRUCT------------
%
%   Units:      Force:    N/m/kg
%               Moments:  N*m/kg
%               Power:    W/kg

DYNAMICS= struct;


DYNAMICS.ForcePlate1.Force = F_1plate(:,1:3);
DYNAMICS.ForcePlate2.Force = F_2plate(:,1:3);

DYNAMICS.RightAnkle.Force = [F_rankle(:,6) F_rankle(:,4) F_rankle(:,5)];
DYNAMICS.RightAnkle.Moment= [M_rankle(:,4) M_rankle(:,6) M_rankle(:,5)] ;    %export both global and anatomical

DYNAMICS.LeftAnkle.Force = [F_lankle(:,6) F_lankle(:,4) F_lankle(:,5)];
DYNAMICS.LeftAnkle.Moment= [M_lankle(:,4) M_lankle(:,6) M_lankle(:,5)];

DYNAMICS.RightKnee.Force = [F_rknee(:,5) F_rknee(:,4) F_rknee(:,6)];
DYNAMICS.RightKnee.Moment = M_rknee(:,4:6);

DYNAMICS.LeftKnee.Force = [F_lknee(:,5) F_lknee(:,4) F_lknee(:,6) ];
DYNAMICS.LeftKnee.Moment = M_lknee(:,4:6);

DYNAMICS.RightHip.Force = [F_rhip(:,5) F_rhip(:,4) F_rhip(:,6)] ;
DYNAMICS.RightHip.Moment = M_rhip(:,4:6);

DYNAMICS.LeftHip.Force = [F_lhip(:,5) F_lhip(:,4) F_lhip(:,6)] ;
DYNAMICS.LeftHip.Moment = M_lhip(:,4:6);





%-------EMBEDDED FUNCTIONS--------





%------------------------------------STRIDE PROPERTIES FP + KIN--------------



function [r,HS0,HS3,TO0] = GetStrideProperties(zdata,idadata,zfilename)


if ~isempty(findstr(zfilename,'T-Pose'))
       
r_heel = mean(idadata.RightFoot.prox_end(:,2));         %average position while standing
l_heel = mean(idadata.LeftFoot.prox_end(:,2));      
    
    r.StrideLength = 0;
    r.StepLength = 0;
    r.StepWidth = l_heel - r_heel;
    r.LegLength = 1;
    HS0 = [1 1 1];
    HS3 = [1 1 1];
    TO0 = [1 1 1];
    
     
else



HS1 = zdata.fz1.event.HS1(1);              %frame of right foot heel strike 1
HS2 = zdata.fz2.event.HS2(1);              %frame of left foot heel strike 1
TO2 = zdata.fz2.event.TO2(1);                %frame of left foot toe off

r_heel = idadata.RightFoot.prox_end(HS1,:);         % position @HS1
l_heel = idadata.LeftFoot.prox_end(HS2,:);          % position @HS2

%---------------------FINDING HEEL STRIKE 0 & 3  + TO 0 BASED ON IDA BONES------------------

zone = idadata.RightFoot.prox_end(HS2:TO2,3);       %heel strike 3 must be btw HS2 and TO2
HS3 = min(find(zone == min(zone)));
HS3 = HS3 + HS2-1;                                  %frame of right foot heel strike 2
r_heel_hs2 = idadata.RightFoot.prox_end(HS3,:);        %x position @HS3


zone= idadata.LeftFoot.prox_end(HS1:HS2,3);                %dogdy...
TO0 = find(zone >=idadata.LeftFoot.prox_end(TO2,3), 1);
TO0 = TO0 + HS1-1;

zone= idadata.LeftFoot.prox_end(1:TO0,3);                %dogdy...
HS0 = min(find(zone == min(zone)));

% zone= idadata.LeftFoot.prox_end(1:HS1,3);                %based on LHEE marker do it later.
% HS0 = min(find(zone == min(zone)));




%-----------------------CALCULATE LEG LENGTH---------

L_rthigh = magnitude(idadata.RightFemur.prox_end - idadata.RightFemur.dist_end) ;
L_rshank = magnitude(idadata.RightTibia.prox_end - idadata.RightTibia.dist_end) ;

L_rthigh = mean(L_rthigh(isfinite(L_rthigh))) ; %remove NaNs and take average in meters
L_rshank =  mean(L_rshank(isfinite(L_rshank)));

Leg_length = L_rthigh + L_rshank;

%----------NORMALIZED STRIDE LENGTH------------


r.StrideLength = (abs(r_heel_hs2(1) - r_heel(1)))/Leg_length;      %force plate +kinematics

r.StepLength = abs( l_heel(1) - r_heel(1))/Leg_length;             %force plate &kinematics


r.StepWidth = abs( l_heel(2) - r_heel(2));                       %force plate & kinematics

r.LegLength = Leg_length;


end

%------------------------------STRIDE PROPERTIES FP ONLY---------
% calculates stride properies based on COP only. 
%
% 



function d = GetCOPStrideProperties(COP,dis,Leg_length,zfilename)


if ~isempty(findstr(zfilename,'T-Pose'))
    
    d.StepLength = 0;
    d.StepWidth = 0;
     
else


dis =dis(1);


d = struct;

HS1 = find(~isnan(COP.COP1(:,1)),1,'first');   % Heel Strike 1
HS2 = find(~isnan(COP.COP2(:,1)),1,'first');   % Heel Strike 2



d.StepLength = dis + abs( COP.COP2(HS2,1)   - COP.COP1(HS1,1));
d.StepLength = d.StepLength/Leg_length;


d.StepWidth =  abs (COP.COP2(HS2,2)    - COP.COP1(HS1,2));



end


function r = displace(m,vec)

if isempty(m) || isempty(vec)
    r = m;
    return
end
r(:,1) = m(:,1)+vec(1);
r(:,2) = m(:,2)+vec(2);
r(:,3) = m(:,3)+vec(3);

function r = gunit
r = [1 0 0;0 1 0;0 0 1];

function vout = ctransform(c1,c2,vec)

%vout = ctransform(c1,c2,vec)
%this function will transform vec from c1 to c2
%c1 and c2 are the unit vectors in coordinate system 1 and 2 respectively

ic1 = c1(1,:);
jc1 = c1(2,:);
kc1 = c1(3,:);

ic2 = c2(1,:);
jc2 = c2(2,:);
kc2 = c2(3,:);

t = [dot(ic1,ic2),dot(ic1,jc2),dot(ic1,kc2);...
        dot(jc1,ic2),dot(jc1,jc2),dot(jc1,kc2);...
        dot(kc1,ic2),dot(kc1,jc2),dot(kc1,kc2)];
if nargin == 3
    vout = vec*t;
else
    vout = t;
end


function r = makeunit(unt)
r = [];
if iscell(unt)
    for i = 1:length(unt)
        plate = unt{i};
        mg = diag(sqrt(plate*plate'));
        plate = plate./[mg,mg,mg];
        r{i} = plate;
    end
else
    mg = diag(sqrt(unt*unt'));
    plate = unt./[mg,mg,mg];
    r = plate;
end
    
