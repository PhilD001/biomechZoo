function [out]=rad2deg(in)

% function [out]=rad2deg(in)
% Description:	Conversion of radians to degrees applied to the entire matrix
% Input:	in (values in radians)
% Output:	out (values in degrees)
% Author:	Christoph Reinschmidt, HPL, The University of Calgary
% Date:		October, 1994
% Last Changes:	November 29, 1996
% Version:	1.0

out=in.*(180/pi);


