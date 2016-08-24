function M_prox =M_segment_2(Fd, Fp, Md, jd, LKIN, COM, ANTHRO, AKIN, dsegment,ref)


%   M_ANKLE determines the moment at the ankle
%
%   ARGUMENTS
%
%   Fd        ...  Distal force 
%   Fp        ...  Proximal force 
%   Md        ...  Moment at distal joint
%   jd        ...  joint center of distal joint
%   jp        ...  joint center of proximal joint
%   I         ...  Moment of interia  
%   Euler     ...  euler angles
%   dsegment  ...  distal segment
%   GS        ...  Grood and suntay angles (i,k,l)


Fd, F_rmfoot(:,1:3), Md, jd, LKIN.RightForeFoot.MidFootJoint, COM.RightForeFoot.Pos, ANTHRO.RightForeFoot.Inertia,AKIN.RightForeFoot.AngVel, AKIN.RightForeFoot.AngAcc,AKIN.RightHindFoot.GSAxes,LKIN,'RightHindFoot' );

M_rmfoot = M_segment_2(Fd, F_rmfoot(:,1:3), Md, jd, LKIN, COM, ANTHRO ,AKIN,'RightHindFoot' );

jp = jp.(segment).MidFootJoint;
COM = COM.(segment).Pos;
I = I.(segment).Inertia;
omega = omega.(segment).AngVel;
alpha = alpah.(segment).AngAcc;
GS = GS.(segment).GSAxes;


% SETTING ANATOMICAL JOINT AXES

if nargin ==12
    ref = 'vicon';
end


if ~isempty(strfind(ref,'vicon'))
    i = LKIN.(dsegment).Axes.i;
    j = LKIN.(dsegment).Axes.j;
    k = LKIN.(dsegment).Axes.k;

else
    i = GS.i;
    j = GS.l;
    k = GS.k;
end



%--------MOMENT ARMS-------
%
rd = jd-COM;     
rp = jp-COM;

M_fdis = cross(rd,Fd,2);      %moment due to Fdis
M_fprox =cross(rp,Fp,2);      %moment due to fprox                       
                              

%-------RESIDUAL MOMENTS-----
%
M_res = -Md - M_fdis + M_fprox;  


%--------RATE OF CHANGE OF ANGULAR MOMENTUM----
%

Ldot = rate_of_change_momentum(I, omega, alpha); % probably right since anatomical Moments are correct


%-------MOMENTS AT ANKLE in XYZ------
%
M_dsegment_XYZ = Ldot-M_res;



%---------MOMENTS IN ANATOMICAL USING DISTAL dsegment------
%
M_dsegment_1 = -1*dot(M_dsegment_XYZ,i,2);
M_dsegment_2 = -1*dot(M_dsegment_XYZ,j,2);
M_dsegment_3 = -1*dot(M_dsegment_XYZ,k,2);
    

switch dsegment 

   
    case 'RightHindFoot'
        M_dsegment_Anatomical = [ M_dsegment_2      M_dsegment_3       -M_dsegment_1];
        M_dsegment_global     = M_dsegment_XYZ;
    
    case 'LeftHindFoot'
        M_dsegment_Anatomical = [ M_dsegment_2      -M_dsegment_3      M_dsegment_1];
        M_dsegment_global     = M_dsegment_XYZ;

       
    case {'RightShankPG','RightShankOFM'}
        M_dsegment_Anatomical = [ M_dsegment_3  M_dsegment_2   M_dsegment_1];
        M_dsegment_global     =   M_dsegment_XYZ;
    
    case {'LeftShankPG','LeftShankOFM'}
        M_dsegment_Anatomical = [ M_dsegment_3  -M_dsegment_2  -M_dsegment_1];
        M_dsegment_global     =   M_dsegment_XYZ;
    
    case 'RightThigh'
        M_dsegment_Anatomical = [-M_dsegment_3 M_dsegment_2 M_dsegment_1];
        M_dsegment_global     = M_dsegment_XYZ;
    
    case 'LeftThigh'
        M_dsegment_Anatomical = [-M_dsegment_3 -M_dsegment_2 -M_dsegment_1];
        M_dsegment_global     = M_dsegment_XYZ;
    
    otherwise
        M_dsegment_Anatomical = [M_dsegment_3 M_dsegment_2 M_dsegment_1];
end




%--------CREATE MATRIX of XYZ and ANATOMICAL---------

M_prox = [M_dsegment_global M_dsegment_Anatomical];