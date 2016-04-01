function [alpha]=angle2d(data)
% function [alpha]=angle2d(data)
% Description:  Calculates the angle between 2 vectors (given by pairs of points)
%               in 2 dimensions.
% Input:        data:   data = [P1x P1y P2x P2y P3x P3y P4x P4y]
%               Note that "data" can have several rows (e.g. different time
%		points).
% Output:       alpha:  angle (in deg) between the vectors P1-P2 and P3-P4
% Author:       Christoph Reinschmidt, HPL, The University of Calgary
% Date:         October, 1994
% Last Changes: November 28, 1996
% Version:	1.0

if ~(size(data,2)==8)
   disp('Error: # of rows of input matrix has to be 8!')
   break;
end

% "assigning" zero to the z-coordinates 
tmp=data; data=[]; data(:,[1 2 4 5 7 8 10 11])=tmp; 
data(size(data,1),12)=[0];

r1=data(:,1:3); r2=data(:,4:6); r3=data(:,7:9); r4=data(:,10:12); 
v1=r2-r1; v2=r4-r3;

% Preassigning alpha to speed up program
alpha=zeros(size(v1,1),1);

for i=1:size(v1,1);
  vect1=[v1(i,:)]'; vect2=[v2(i,:)]';
  x=cross(vect1,vect2);
  alphacos=rad2deg(acos(sum(vect1.*vect2)/(norm(vect1)*norm(vect2))));
  y=x(3,1);
  % Determining if alpha b/w 0 and pi or b/w -pi and 0
  if sign(y)==-1;   alphacos=-alphacos; end
  alpha(i,:)=[alphacos];
end


