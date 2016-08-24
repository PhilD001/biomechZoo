function [M_prox,M_res, Md, M_fdis, M_fprox,M_g, rd, rp, rg] =M_foot_hf(Fd, Fp, GRF, Tz, Md, jd, jp, COP, COM, I, AKIN, LKIN, dsegment, ref)

%   M_ANKLE determines the moment at the ankle
%
%   ARGUMENTS
%r
%   Fd         ... Distal force 
%   Fp         ... Proximal force 
%   GRF        ... Ground reaction force 
%   Tz         ... Free vetical torque
%   Md         ... Moment at distal joint
%   jd         ... joint center of distal joint
%   jp         ... joint center of proximal joint
%   COP        ... coordinates of centre of pressure
%   COM        ... struct containing position of centre of mass
%   I          ... Moment of interia  
%   AKIN       ... struct containing angular vel, angular acc and axes for
%                  distal segment
%   LKIN       ... struct containing euler angles
%   dsegment   ... name of distal segment 
%   ref        ... refence system. Default 'Vicon'




%--EXTRACT VALUES FROM STRUCT------

COM   = COM.(dsegment).Pos;
omega =  AKIN.(dsegment).AngVel;
alpha =  AKIN.(dsegment).AngAcc;
GS    =  AKIN.(dsegment).GSAxes;


% SETTING ANATOMICAL JOINT AXES

if nargin == 13
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



%--COMPUTE MOMENTS DUE TO ALL FORCES--------------------------
%
rd = jd-COM;                      % prox moment arm
rp = jp-COM;                      % dist moment arm
rg = COP-COM;                     % additional moment arm (GRF)     

M_fdis  = cross(rd,Fd,2);         % moment due to Fdis
M_fprox = cross(rp,Fp,2);         % moment due to fprox                       
M_g     = cross(rg,GRF,2);        % moment due to GRF                              


%--SUM RESIDUAL MOMENTS--------------------------------------
%
zero  = zeros(length(Tz),1);
Tz = [zero zero Tz];

% M_res = - Md + M_fdis + M_fprox  + Tz + M_g ;    % original 


M_res = - Md - M_fdis + M_fprox + Tz  + M_g ;    % Md is equal and opposite to Mp calculated previously 

% M_res   are equal in both methods
% M_fprox are equal in both methods

% plot(-Md-M_fdis+Tz+M_g)  
% 
% hold on


%--------RATE OF CHANGE OF ANGULAR MOMENTUM----
%
Ldot = rate_of_change_momentum(I, omega, alpha); % probably right since anatomical Moments are correct


%-------MOMENTS AT ANKLE in XYZ------
%
M_dsegment_XYZ = Ldot-M_res;



%------MOMENTS IN ANATOMICAL USING DISTAL dsegment------
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
        M_dsegment_global     = M_dsegment_XYZ;

end




%--------CREATE MATRIX of XYZ and ANATOMICAL---------

M_prox = [M_dsegment_global M_dsegment_Anatomical];