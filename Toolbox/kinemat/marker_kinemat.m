function [cols]=marker_kinemat(in)

% function [cols]=marker(in)
% Description: 	This is an auxiliary function which returns the column 
% 		numbers of markers. This function is helpful to extract 
%		the XYZ columns of specific markers from the large 
%		matrix obtained from "reconfu.m". Note that for every 
% 		marker typically five columns are assigned from the matrix
%		obtained from reconfu.m: X,Y,Z,residuals,Cameras_used
% Input: 	in:   marker for which the columns should be returned.
%                     e.g. [1,4] -> output: cols=[1 2 3, 16 17 18] where
%                                           X Y Z of the markers are.
% Output: 	cols: column numbers where the XYZ values of the markers 
%		      can be found.
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:	  	March, 1995
% Last Changes: November 19, 1996
% Version:	1.0

% Renamed from 'marker.m' by Phil Dixon to avoid conflct with director. No check for 
% erros on functions other than 'cardan.m' in the kinemat toolbox

cols=[];
for i=1:size(in,2)
cols=[cols, in(1,i)*5-4 : in(1,i)*5-2];
end


