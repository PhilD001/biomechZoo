function r_rev = reversepol_line(r)

% r_rev = REVERSEPOL_line(r) polarity reversing for a vector
%
% ARGUMENTS
%  r         ...  n x 1 or n x 3 matrix 
% 
% RETURNS
%  r_rev     ...  n x 1 or n x 3 matrix with poliarity reversed (negated)
%
% See also bmech_reversepol, reversepol_data


r_rev = -1.*r;

