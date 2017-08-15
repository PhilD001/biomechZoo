function [M_prox,rd,rp] = M_foot (Fd, Fp, Tz, jc,COP,COM,I,AKIN,LKIN,dsegment,ref)

%   M_ANKLE determines the moment at the ankle
%
% ARGUMENTS
%
%  Fd        ...  Distal force (GRF)
%  Fp        ...  Proximal force (F ankle or F midfoot for OFM)
%  Tz        ...  Free Torque from force plate (column vector)
%  jc        ...  joint center coordinates
%  COP       ...  Point of application of force
%  COM       ...  Center of mass coordinates
%  I         ...  Moment of interia  
%  omega     ...  Angular velocity of distal segment
%  alpha     ..   Angular Acceleration of distal segment
%  GS        ...  Grood and suntay angles (i,k,l)
%  LKIN      ...  embedded axes of distal segment
%  segment   ...  local coordinate system must be in columns...
%  ref       ...  distal segment
%
% RETURNS
%  M_prox    ...  Moment at proximal joint
%  rd        ...  distal moment arm
%  rp        ...  proximal moment arm
%
% NOTES
%
% using newton:  sum moments = I*alpha
%                sum moments = Mankle + Tz + MduetoFankle + MduetoFplate
%                sum of moments = Mankle + Mres
%                Mankle = I*alpha - Mres;
%
% Segment embedded axes convention
% - Segment embedded axes defined by LINEAR_KIN are in the Vaughan
% reference frame 
%  i: points proximal (distal for OFM)
%  j: points anterior
%  k: points medial (right) and lateral (left)
% - data is output in the vicon reference frame
%  
% Updated 26/10/2007
%  -torques are now free torques calculated by FREE_TORQUE
%
% Updated March 2011 by Phil Dixon
% - corrected sign for midfoot moments, there may still be problems
%
% Updated May 24th 2011
% - rearranged midfoot anatomical moments to match vicon


%--EXTRACT VALUES FROM STRUCT------
COM   = COM.(dsegment).Pos;
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


%--COMPUTE MOMENTS DUE TO PROX AND DIST FORCES--------
%
rp = jc-COM;                    % prox moment arm
rd = COP-COM;                   % dist moment arm     

M_fdis = cross(rd,Fd,2);       % moment due to distal force
M_fprox = cross(rp,Fp,2);      % moment due to proximal force   
                        

%--SUM RESIDUAL MOMENTS-------------------------------
%
zero  = zeros(length(Tz),1);
Tz = [zero zero Tz];

M_res = Tz + M_fprox + M_fdis;    


%--GET RATE OF CHANGE OF ANGULAR MOMENTUM-------------
%
Ldot = rate_of_change_momentum(I, omega, alpha);    % n x 3


%--COMPUTE MOMENTS AT PROXIMAL JOINT IN GLOBAL XYZ------
%
M_prox_XYZ = Ldot-M_res;


%--COMPUTE MOMENTS IN ANATOMICAL-----------------------
%
M_prox_plan_dorsi = dot(M_prox_XYZ,k,2);
M_prox_inv_ev = -1*dot(M_prox_XYZ,i,2);
M_prox_var_val = -1*dot(M_prox_XYZ,j,2);
    

%--CHANGE SIGN BASED ON JOINT-------------------------
%
switch dsegment
    
    case 'RightForeFoot'
         M_prox_Anatomical  = [ M_prox_var_val     -M_prox_plan_dorsi   -M_prox_inv_ev  ];  
          
    case 'LeftForeFoot'
        M_prox_Anatomical   = [ M_prox_var_val      M_prox_plan_dorsi    M_prox_inv_ev  ];
    
    case 'RightFoot'
          M_prox_Anatomical = [ M_prox_plan_dorsi  -M_prox_inv_ev        M_prox_var_val ];
               
    case 'LeftFoot'
        M_prox_Anatomical   = [ M_prox_plan_dorsi   M_prox_inv_ev       -M_prox_var_val ];
        
end

%--------CREATE MATRIX of XYZ and G&S---------

M_prox = [M_prox_XYZ M_prox_Anatomical];



