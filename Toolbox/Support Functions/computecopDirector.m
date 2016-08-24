function data = computecopDirector(data,P,Or,fpch)


% computes COP in global coordinate system according to Kwon
% see http://www.kwon3d.com/theory/grf/cop.html
%
% ARGUMENTS
% data     ...    struct containing required channel data
% P        ...    struct containing true manufacturer computed origin of force plate (m)
% Or       ...    struct containing origin in global coordinate system
% fpch     ...    names of force plate channels. Default 'Fx1','Fy1',...
%
% NOTES
% - placement of force plates may not be correct depending on lab settings
%   Code must be improved for better generalizability
%

% Revision history
%
% Created Jan 2013
%
% Updated April 1th 2013
% -back compatibility
%
% updated May 1st 2013
% - can be used with 3 force plates
%
% Updated August 23rd 2013
% - translation of COP from local to global is done in a sloppy fashion. Current code works for Oxford and
%   Singapore, but probably won't work for other gait lab setups. Check for possible improvements
%
% Updated January 2014
% - test for new OGL setup where force plate position has been changed.




%--DEFAULTS---
thresh = 20 ; % cop only cacluated when magnitude of F > 20 N. Agrees with Vicon


%--TRUE FORCE PLATE CENTRE COORDINATES IN GLOBAL (g) and LOCAL OGL (mm)----
%

g = struct;  % for global
l = struct;  % for local
COP = struct;

nplates = length(fieldnames(Or));

for i = 1:nplates
    
    g.(['a',num2str(i),'g']) = Or.(['Or',num2str(i)])(1)*1000;
    g.(['b',num2str(i),'g']) = Or.(['Or',num2str(i)])(2)*1000;
    g.(['c',num2str(i),'g']) = Or.(['Or',num2str(i)])(3)*1000;
    
    l.(['a',num2str(i)]) = P.(['p',num2str(i)])(1)*1000;
    l.(['b',num2str(i)]) = P.(['p',num2str(i)])(2)*1000;
    l.(['c',num2str(i)]) = P.(['p',num2str(i)])(3)*1000;
    
    % extract force plates
    if i ==1
        ch = fpch(1:6);
    else
        ch = fpch(6*i-5:6*i);
    end
    
    Fx = data.(ch{1}).line;
    Fy = data.(ch{2}).line;
    Fz = data.(ch{3}).line;
    Mx = data.(ch{4}).line;
    My = data.(ch{5}).line;
    Mz = data.(ch{6}).line;
    
    a = l.(['a',num2str(i)]);
    b = l.(['b',num2str(i)]);
    c = l.(['c',num2str(i)]);
    
    
    COP.(['COP',num2str(i)]) = COP_oneplate([Fx Fy Fz],[Mx My Mz],a,b,c,thresh); % in local
     
    
end



% PLACEMENT OF FORCE PLATE

if isnear(l.a1,0.33,0.001)
    
    % original OGL configuration
    %
    disp('implementing original OGL FP position setings')
    
    COP.COP1(:,1) = COP.COP1(:,1) + g.a1g; % in global
    COP.COP1(:,2) = -COP.COP1(:,2) + g.b1g; % in global
    COP.COP1(:,3) = COP.COP1(:,3) + g.c1g; % in global
    
    COP.COP2(:,1) = -COP.COP2(:,1) + g.a2g; % in global
    COP.COP2(:,2) = COP.COP2(:,2) + g.b2g; % in global
    COP.COP2(:,3) = COP.COP2(:,3) + g.c2g; % in global
    
elseif isnear(l.a1,1.6764,0.001) %
    
    % post 12.15.2013 Force plates moved
    %
    disp('implementing post Dec 2013 OGL FP position setings')
    
    COP.COP1(:,1) = -COP.COP1(:,1) + g.a1g; % in global graph must be the SAME as in vicon cop
    COP.COP1(:,2) = COP.COP1(:,2) + g.b1g; % in global
    COP.COP1(:,3) = COP.COP1(:,3) + g.c1g; % in global
    
    COP.COP2(:,1) = COP.COP2(:,1) + g.a2g; % in global
    COP.COP2(:,2) = -COP.COP2(:,2) + g.b2g; % in global
    COP.COP2(:,3) = COP.COP2(:,3) + g.c2g; % in global
    
else
    disp('implementing othere FP position setings, please check your lab setup')
    COP.COP1(:,1) = -COP.COP1(:,1) + g.a1g; % in global
    COP.COP1(:,2) = COP.COP1(:,2) + g.b1g; % in global
    COP.COP1(:,3) = COP.COP1(:,3) + g.c1g; % in global
    
    COP.COP2(:,1) = -COP.COP2(:,1) + g.a2g; % in global
    COP.COP2(:,2) = COP.COP2(:,2) + g.b2g; % in global
    COP.COP2(:,3) = COP.COP2(:,3) + g.c2g; % in global
   
end



if nplates >2
    COP.COP3(:,1) =  COP.COP3(:,1) + g.a3g; % in global
    COP.COP3(:,2)= - COP.COP3(:,2) + g.b3g; % in global
    COP.COP3(:,3) =  COP.COP3(:,3) + g.c3g; % in global
end


%----ADD TO ZOOSYSTEM-----
%
for i = 1:nplates
    
    data.(['COP',num2str(i),'_X']).line = COP.(['COP',num2str(i)])(:,1);
    data.(['COP',num2str(i),'_X']).event = struct;
    
    data.(['COP',num2str(i),'_Y']).line = COP.(['COP',num2str(i)])(:,2);
    data.(['COP',num2str(i),'_Y']).event = struct;
    
    data.(['COP',num2str(i),'_Z']).line = COP.(['COP',num2str(i)])(:,3);
    data.(['COP',num2str(i),'_Z']).event = struct;
    
end


