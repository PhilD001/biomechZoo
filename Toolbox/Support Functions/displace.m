function r = displace(m,vec)

% DISPLACE moves a matrix m to vector vec
%
% R = DISPLACE(m,vec)
%
% ARGUMENTS
%   m       ...  matrix to be displaced
%   vec     ...  displacement vector

if isempty(m) || isempty(vec)
    r = m;
    return
end
r(:,1) = m(:,1)+vec(1);
r(:,2) = m(:,2)+vec(2);
r(:,3) = m(:,3)+vec(3);