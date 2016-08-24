function [P_prox,mwdg,mwpg]=P_segment(Mp,wd,wp,lcsd,lcsp,segment)



% ARGUMENTS
%
% Mp        ...    Moment at joint in Global
% wp        ...    Proximal segment angular velocity in local
% wd        ...    Distal segment angular velocity in local
% lcsp      ...    local coordinate system of proximal segment
% lcs_dist  ...    local coordinate system of distal segment
% segment   ...    optional input. Required for changing sign of midfoot
%                    power. Default empty string ''
%
% RETURNS
% 
% P_prox   ...     Power at proximal segment
% mwdg       ...   magnitude of angular velocity vector at distal joint
% mwdp       ...   magnitude of angular velocity vector at proximal joint
%
%
% Created by Phil Dixon Dec 2008
%
% Updated January 2011
% 
% - After first trying in 2008, this function finally works. Must transform
%  segment angular velocities to Global!
%
% Updated March 2011
% - Since the forefoot and hindfoot vectors both point the same way (unlike
%   PIG foot and tibia) Midfoot power sign must be changed (I think)
%
%
% NOTES
%- Formula based on Kwon3d 
% KWON says...
% http://www.kwon3d.com/theory/jtorque/jen.html  eq [7]

% figure
% plot(Mp)

if nargin ==5
    segment = '';
end

% transform segment angular velocities into GLOBAL

wpg = [];
wdg = [];

for a = 1:length(wp)

    Lp = [lcsp.i(a,:);
        lcsp.j(a,:);
        lcsp.k(a,:)];

    Ld = [lcsd.i(a,:);
        lcsd.j(a,:);
        lcsd.k(a,:)];

    p = ctransform(Lp,gunit,wp(a,:));
    wpg = [wpg; p];

    d = ctransform(Ld,gunit,wd(a,:));
    wdg = [wdg; d];

end



if isin(segment,'ForeFoot')
    P_prox = -dot(Mp,(wdg-wpg),2); % Kwon Equation
else
    P_prox = dot(Mp,(wdg-wpg),2); % Kwon Equation
end


%--compute magintude of quantities

Mp = magnitude(Mp);
mwdg = magnitude(wdg);
mwpg = magnitude(wpg);


