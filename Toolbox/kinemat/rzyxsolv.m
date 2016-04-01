function [out] = rzyxsolv(T)
% Description:	Solves for alpha,beta,gama,Hx,Hy,Hz of the transformation
%               matrix with the order Rzyx (Rzyx = [rx] [ry] [rz])
%
% Input:	- T      Transformation matrix
% Output:	- out    [alpha,beta,gama,Hx,Hy,Hz]
%                        Note that the angles are given in the range 
%                        from -180 to +180 deg.
%                        gama is not a typo: gamma could not be used because
%                        it is an existing matlab function 
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		October, 1994
% Last changes: February 13, 1995
% Version:	1.0

if size(T)~=[4,4]; 
   disp('Error: transformation matrix has to be a 4x4 matrix')
   break;
end;

if sum(isnan(T(:)))~=0, out=[NaN,NaN,NaN,NaN,NaN,NaN]; return; end

beta  = asin(T(1,3));  %'assumption' that cos(beta)>0

alphasin = asin(-T(2,3)/cos(beta));
alphacos = acos(T(3,3)/cos(beta));
if (alphacos>pi/2 & alphasin>0); alpha=pi-alphasin; end;
if (alphacos>pi/2 & alphasin<0); alpha=-pi-alphasin; end; 
if (alphacos<=pi/2); alpha=alphasin; end;

gamasin = asin(-T(1,2)/cos(beta));
gamacos = acos(T(1,1)/cos(beta)); 
if (gamacos>pi/2 & gamasin>0); gama=pi-gamasin;  end;
if (gamacos>pi/2 & gamasin<0); gama=-pi-gamasin; end; 
if (gamacos<=pi/2);            gama=gamasin;     end;


% Calculation of Hx,Hy,Hz

A=[1, 0, sin(beta);...
   0, cos(alpha), -sin(alpha)*cos(beta);...
   0, sin(alpha), cos(alpha)*cos(beta)];
H=A\T(1:3,4); H=H';

out=[rad2deg(alpha),rad2deg(beta),rad2deg(gama),H];

