function jc = chordPiG(a,b,c,delta)

% jc = CHORDPIG(a,b,c,delta) computes knee and ankle joint centres
% according to the plug-in gait 'chord' function 
%
% ARGUMENTS 
%  a       ...  wand marker data (n x 3 matrix)
%  b       ...  proximal joint centre (n x 3 matrix)
%  c       ...  distal marker (n x 3 matrix)
%  delta   ... (jointWidth/2) + mDiameter/2 (double);
%
% RETURNS
%  jc      ...  The joint centre in global coordinate system
%
% See also bmech_jointcentrePiG, jointcentrePiG_dat
%
% NOTES
% - See vicon user manual for chord function definition (see help fileS)
% - Thanks to  Seungeun Yeon, Mathew Schwartz, Filipe Alves Caixeta, 
%   and Robert Van-wesep. See: https://github.com/cadop/pyCGM


% Revision history
%
% Updated by Philippe C. Dixon June 2016
% - Updated code translated into Matlab from pyCGM.py's findJointC method.This removes
%   difficult (slow) call to symbolic math and uses Rodriques's method instead. 


% make the two vector using 3 markers, which is on the same plane.
%  
v1 = a-c;
v2 = b-c;


% v3 is cross vector of v1, v2 and then it normalized.
%
v3 = makeunit(cross(v1,v2));
	
m = (b+c)/2;
len = magnitude(b-m);

theta = acos(delta./magnitude(v2));

csVec = cos(theta*2);
snVec = sin(theta*2);

uxMat = v3(:,1);
uyMat = v3(:,2);
uzMat = v3(:,3);
	
% this rotation matrix is called Rodriques' rotation formula. In order to 
% make a plane, at least 3 number of markers is required which means three
% physical markers on the segment can make a plane. Then the orthogonal vector
% of the plane will be rotating axis. joint center is determined by rotating
% the one vector of plane around rotating axis.
% 
jc = zeros(size(a));

for i = 1:length(uxMat)
    cs = csVec(i);
    sn = snVec(i);
    ux = uxMat(i,:);
    uy = uyMat(i,:);
    uz = uzMat(i,:);
    
    rot =  [cs+ux^2*(1-cs), ux*uy*(1-cs)-uz*sn, ux*uz*(1-cs)+uy*sn; ...
        uy*ux*(1.0-cs)+uz*sn,cs+uy^2*(1-cs),uy*uz*(1-cs)-ux*sn;...
        uz*ux*(1.0-cs)-uy*sn,uz*uy*(1.0-cs)+ux*sn,cs+uz^2*(1-cs)];
    
    r = rot*(v2(i,:)');
    r = (r*len(i)/magnitude(r'))';
    
    jc(i,:) = r+m(i,:);
end


