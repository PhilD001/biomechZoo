function [out] = ryxzsolv(T)
% Description:	Solves for alpha,beta,gama,Hx,Hy,Hz of the transformation
%               matrix with the order Ryxz ([rz] [rx] [ry])
%
% Input:	- T      Transformation matrix
% Output:	- out    [alpha,beta,gama,Hx,Hy,Hz]
%                        Note that the angles are given in the range 
%                        from -180 to +180 deg.
%                        gama is not a typo: gamma could not be used because
%                        it is an existing matlab function. 
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		October, 1994
% Last changes: February 13, 1995
% Version:	1.0

% Updated by Philippe C. Dixon March 17th 2016
% - changed 'break' statement for 'return' at line 22. Original code
%   failed in Matlab r2014b

if size(T)~=[4,4]; 
   disp('Error: transformation matrix has to be a 4x4 matrix')
   return
end

if sum(isnan(T(:)))~=0, out=[NaN,NaN,NaN,NaN,NaN,NaN]; return; end

alpha = asin(T(3,2));  %'assumption' that cos(alpha)>0

betasin = -asin(T(3,1)/cos(alpha));
betacos = acos(T(3,3)/cos(alpha));
if (betacos>pi/2 & betasin>0); beta=pi-betasin; end;
if (betacos>pi/2 & betasin<0); beta=-pi-betasin; end; 
if (betacos<=pi/2); beta=betasin; end;

gamasin= asin(-T(1,2)/cos(alpha));
gamacos= acos(T(2,2)/cos(alpha));
if (gamacos>pi/2 & gamasin>0); gama=pi-gamasin;  end;
if (gamacos>pi/2 & gamasin<0); gama=-pi-gamasin; end; 
if (gamacos<=pi/2);            gama=gamasin;     end;


% Calculation of Hx,Hy,Hz

A=[cos(gama),-cos(alpha)*sin(gama),0;...
   sin(gama),cos(alpha)*cos(gama),0;...
   0, sin(alpha),1];
H=A\T(1:3,4); H=H';

out=[rad2deg(alpha),rad2deg(beta),rad2deg(gama),H];

