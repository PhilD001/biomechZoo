function M_prox =M_segment(Fd, Fp, Md, jd,jp,COM,I,omega,alpha,GS,LKIN,segment,ref)


%   M_ANKLE determines the moment at the ankle
%
%   ARGUMENTS
%
%   Fd    ... Distal force 
%   Fp    ... Proximal force 
%   Md    ... Moment at distal joint
%   jd     ...joint center of distal joint
%   jp     ...joint center of proximal joint
%   I     ... Moment of interia  
%   Euler     ... euler angles
%   segment   ... local coordinate system
%   GS   ... Grood and suntay angles (i,k,l)


% SETTING ANATOMICAL JOINT AXES

if nargin ==12
    ref = 'vicon';
end


if ~isempty(strfind(ref,'vicon'))
    i = LKIN.(segment).Axes.i;
    j = LKIN.(segment).Axes.j;
    k = LKIN.(segment).Axes.k;

else
    i = GS.i;
    j = GS.l;
    k = GS.k;
end



%--------MOMENT ARMS-------

rd = jd-COM;     
rp = jp-COM;


M_fdis = cross(rd,Fd,2);      %moment due to Fdis
M_fprox =cross(rp,Fp,2);      %moment due to fprox                       
                              


%-------RESIDUAL MOMENTS-----


M_res = -Md - M_fdis + M_fprox;  


%--------RATE OF CHANGE OF ANGULAR MOMENTUM----


Ldot = rate_of_change_momentum (I, omega, alpha);

%-------MOMENTS AT ANKLE in XYZ------


M_segment_XYZ = Ldot-M_res;


%---------MOMENTS IN ANATOMICAL USING DISTAL SEGMENT------


M_segment_flx_ext = -1*dot(M_segment_XYZ,k,2);
M_segment_abd_add = -1*dot(M_segment_XYZ,j,2);
M_segment_int_ext = -1*dot(M_segment_XYZ,i,2);
    

switch segment

    case 'RightHindFoot'
        M_segment_Anatomical = [ -M_segment_abd_add M_segment_flx_ext M_segment_int_ext];
    
    case 'LeftHindFoot'
        M_segment_Anatomical = [ -M_segment_abd_add -M_segment_flx_ext -M_segment_int_ext];
    
    case 'RightShankOFM'
        M_segment_Anatomical = [ M_segment_abd_add M_segment_flx_ext     M_segment_int_ext];
    
    case 'LeftShankOFM'
        M_segment_Anatomical = [ M_segment_abd_add -M_segment_flx_ext    -M_segment_int_ext];
    
    case 'RightShankPG'
        M_segment_Anatomical = [ M_segment_flx_ext M_segment_abd_add    M_segment_int_ext];
    
    case 'LeftShankPG'
        M_segment_Anatomical = [ M_segment_flx_ext -M_segment_abd_add    -M_segment_int_ext];
    
    case 'RightThigh'
        M_segment_Anatomical = [-M_segment_flx_ext M_segment_abd_add M_segment_int_ext];
    
    case 'LeftThigh'
        M_segment_Anatomical = [M_segment_flx_ext M_segment_abd_add M_segment_int_ext];
    
    otherwise
        M_segment_Anatomical = [M_segment_flx_ext M_segment_abd_add M_segment_int_ext];
end




%--------CREATE MATRIX of XYZ and ANATOMICAL---------

M_prox = [M_segment_XYZ M_segment_Anatomical];