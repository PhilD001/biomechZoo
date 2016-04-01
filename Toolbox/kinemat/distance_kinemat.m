function [dist]=distance(XYZmarker1,XYZmarker2)
% function [dist]=distance(XYZmarker1,XYZmarker2)
% Description:	Calculates the distance between two markers.
% Input:	XYZmarker1: [X,Y,Z] coordinates of marker 1
%		XYZmarker2: [X,Y,Z] coordinates of marker 2
%		Note: The distances are calculated for each row
% Output:	distance
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		November, 1996
% Last Changes:	November 29, 1996
% Version:	1.0
		

[s1,t1]=size(XYZmarker1);
[s2,t2]=size(XYZmarker2);

if s1~=s2 | t1~=t2 | t2~=3
 disp('The input matrices must have 3 columns and the same number')
 disp('of rows. Try again.')
 break
end

tmp=[XYZmarker1-XYZmarker2].^2;
dist=[sum(tmp')'].^0.5;

