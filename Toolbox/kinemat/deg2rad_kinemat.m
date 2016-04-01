function [out]=deg2rad(in)

% function [out]=deg2rad(in)
% Description:	Conversion of degrees to radians applied to the entire matrix
% Input:	in (values in degrees)
% Output:	out (values in radians)
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		October, 1994
% Last Changes:	November 29, 1996
% Version:	1.0

out=in./(180/pi);

