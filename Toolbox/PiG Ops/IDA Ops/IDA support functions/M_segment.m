function [M_prox,M_res, Md,M_fdis,M_fprox,rd,rp] =M_segment(Fd, Fp, Md, jd, jp, COM, I, AKIN, LKIN, dsegment,ref)


%   M_ANKLE determines the moment at the ankle
%
%   ARGUMENTS
%
%   Fd         ... Distal force 
%   Fp         ... Proximal force 
%   Md         ... Moment at distal joint
%   jd         ... joint center of distal joint
%   jp         ... joint center of proximal joint
%   COM        ... coordinates of distal segment centre of mass
%   I          ... Moment of interia of distal segment  
%   AKIN       ... struct containing angular velocity, angualr acceleration
%                  and grood and suntay axes of distal segment
%   Euler      ... euler angles of distal segment
%   dsegment   ... name of distal segment
%   GS         ... Grood and suntay angles for distal segment (i,k,l)



%--EXTRACT VALUES FROM STRUCT------
COM   =  COM.(dsegment).Pos;
omega =  AKIN.(dsegment).AngVel;
alpha =  AKIN.(dsegment).AngAcc;
GS    =  AKIN.(dsegment).GSAxes;

% SETTING ANATOMICAL JOINT AXES

if nargin ==10
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

% plot(-Md-M_fdis)

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

       
    case {'RightShank','RightShankOFM'}
        M_dsegment_Anatomical = [ M_dsegment_3  M_dsegment_2   M_dsegment_1];
        M_dsegment_global     =   M_dsegment_XYZ;
    
    case {'LeftShank','LeftShankOFM'}
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
        M_dsegment_global     = M_dsegment_XYZ;

end




%--------CREATE MATRIX of XYZ and ANATOMICAL---------

M_prox = [M_dsegment_global M_dsegment_Anatomical];