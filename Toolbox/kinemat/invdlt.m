function [xy] = invdlt(A,XYZ)
% function [xy] = invdlt(A,XYZ)
% Description:	This program calculates the local (camera) xy coordinates
%		of a known point XYZ in space using the known DLT coefficients
%		of that specific camera.
%		This program can for instance be used to plot finite helical 
%               axes into stereo x-rays. (similar procedure to Blankevoort 
%		et al. (1990), J.Biomechanics 21, 705-720)
% Input:	- A:	11 DLT coefficients. A has to be 11x1 in size.
%		- XYZ:  three dimensional coordinates of point in space
%			XYZ can have several rows (different time/points)
%			XYZ must have 3 columns: X,Y,Z
% Output:	- xy:	camera coordinates ([x,y])
%			xy will have the same number of rows as XYZ
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		November, 1996
% Last changes: November 29, 1996
% Version:	1.0
% References:	e.g.: Nigg and Herzog (1995) Biomechanics of the musculo-
%		      skeletal system. Wiley and Son., p. 265.


% CHECKING PROPER SIZE OF INPUT MATRICES
if size(XYZ,2)~=3,
 disp('Try again! Your input matrix XYZ did not contain enough columns'), 
  break
end

[s1,s2]=size(A);
if s1~=11 | s2~=1
 disp('Try again! Your input DLT matrix does not have the right size'), break
end

% RENAMING 
X=XYZ(:,1); Y=XYZ(:,2); Z=XYZ(:,3);
for i=1:11, eval(['a' num2str(i) '=A(i,1);']), end

% Calculating the local coordinates.
x=(X.*a1+Y.*a2+Z.*a3+a4)./(X.*a9+Y.*a10+Z.*a11+1);
y=(X.*a5+Y.*a6+Z.*a7+a8)./(X.*a9+Y.*a10+Z.*a11+1);

xy=[x,y];
