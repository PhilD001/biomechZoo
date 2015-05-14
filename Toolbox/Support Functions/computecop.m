function data = computecop(data,P,Or)


% computes COP in global coordinate system according to Kwon
% see http://www.kwon3d.com/theory/grf/cop.html
%
% ARGUMENTS
% data     ...    struct containing required channel data
% P        ...    struct containing true manufacturer computed origin of force plate (m)
% Or       ...    struct containing origin in global coordinate system
%
%
% must be edited for use with n~=2 force plates
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
%
% ---------Part of the Zoosystem Biomechanics Toolbox 2006-2014------------------------------%
%                                                                                            %                
% MAIN CONTRIBUTORS                                                                          %
%                                                                                            %
% Philippe C. Dixon         Dept. of Engineering Science. University of Oxford, Oxford, UK   %
% JJ Loh                    Medicus Corda, Montreal, Canada                                  %
% Yannick Michaud-Paquette  Dept. of Kinesiology. McGill University, Montreal, Canada        %
%                                                                                            %
% - This toolbox is provided in open-source format with latest version available on the      %
%   Mathworks file exchange under the name 'zoosystem'.                                      %
%                                                                                            %
% - Users are encouraged to edit and contribute to functions                                 %
%                                                                                            %
% main contact: philippe.dixon@gmail.com                                                     %
%                                                                                            %
%--------------------------------------------------------------------------------------------%



%--DEFAULTS---
thresh = 20 ; % cop only cacluated when magnitude of F > 20 N. Agrees with Vicon

p3 = [];

if nargin==3
    
    p1 = P.p1;
    p2 = P.p2;
    
    Or1 = Or.Or1;
    Or2 = Or.Or2;
    
    if isfield(P,'p3')
        p3 = P.p3;
        Or3 = Or.Or3;
    end
    
else
    
    %---oxford settings----
    p1 = [0.0003302	0.0002286	0.04034]; %true 
    p2 = [0.001397	-0.0000254	0.03757];
    p3 = [0.0000508	-0.001473	0.03873]; %
    
    Or1 = [0.232	0.254	0];
    Or2 = [0.232	-0.324	0];
    Or3 = [0.233	0.916	0];   
end

%--TRUE FORCE PLATE CENTRE COORDINATES IN GLOBAL (g) and LOCAL OGL (mm)----
%

a1g = Or1(1)*1000;
b1g = Or1(2)*1000;
c1g = Or1(3)*1000;

a2g = Or2(1)*1000;
b2g = Or2(2)*1000;
c2g = Or2(3)*1000;

a1 = p1(1)*1000; 
b1 = p1(2)*1000;
c1 = p1(3)*1000;

a2 = p2(1)*1000;
b2 = p2(2)*1000;
c2 = p2(3)*1000;


%---EXTRACT FORCES AND MOMENTS----
%
Fx1 = data.Fx1.line; % N
Fy1 = data.Fy1.line;
Fz1 = data.Fz1.line;
Mx1 = data.Mx1.line; %Nmm
My1 = data.My1.line;
Mz1 = data.Mz1.line;

Fx2 = data.Fx2.line;
Fy2 = data.Fy2.line;
Fz2 = data.Fz2.line;
Mx2 = data.Mx2.line;
My2 = data.My2.line;
Mz2 = data.Mz2.line;


%---COMPUTE COPL ----------
%
COP1 = COP_oneplate([Fx1 Fy1 Fz1],[Mx1 My1 Mz1],a1,b1,c1,thresh); % in local
COP2 = COP_oneplate([Fx2 Fy2 Fz2],[Mx2 My2 Mz2],a2,b2,c2,thresh); % in local

% if round(a1g)-232==0 % OGL SETTINGS

if isnear(a1,0.33,0.001)    
      
    % original OGL configuration
    %
    disp('implementing original OGL FP position setings')
    
    COP1_X = COP1(:,1) + a1g; % in global
    COP1_Y = -COP1(:,2) + b1g; % in global
    COP1_Z = COP1(:,3) + c1g; % in global
    
    COP2_X = -COP2(:,1) + a2g; % in global
    COP2_Y = COP2(:,2) + b2g; % in global
    COP2_Z = COP2(:,3) + c2g; % in global
    
    
    
    
elseif isnear(a1,1.6764,0.001) %
    
    
    % post 12.15.2013 Force plates moved
    %
    disp('implementing post Dec 2013 OGL FP position setings')
    
    COP1_X = -COP1(:,1) + a1g; % in global graph must be the SAME as in vicon cop
    COP1_Y = COP1(:,2) + b1g; % in global
    COP1_Z = COP1(:,3) + c1g; % in global
    
    COP2_X = COP2(:,1) + a2g; % in global
    COP2_Y = -COP2(:,2) + b2g; % in global
    COP2_Z = COP2(:,3) + c2g; % in global
    
    
    
    
else 
    disp('implementing othere FP position setings, please check your lab setup')
    COP1_X = -COP1(:,1) + a1g; % in global
    COP1_Y = COP1(:,2) + b1g; % in global
    COP1_Z = COP1(:,3) + c1g; % in global
    
    COP2_X = -COP2(:,1) + a2g; % in global
    COP2_Y = COP2(:,2) + b2g; % in global
    COP2_Z = COP2(:,3) + c2g; % in global
    
    
end




%----ADD TO ZOOSYSTEM-----
%
data.COP1_X.line = COP1_X;
data.COP1_X.event = struct;

data.COP1_Y.line = COP1_Y;
data.COP1_Y.event = struct;

data.COP1_Z.line = COP1_Z;
data.COP1_Z.event = struct;


data.COP2_X.line = COP2_X;
data.COP2_X.event = struct;

data.COP2_Y.line = COP2_Y;
data.COP2_Y.event = struct;

data.COP2_Z.line = COP2_Z;
data.COP2_Z.event = struct;






if ~isempty(p3)  % for 3 force plates
    
    a3g = Or3(1)*1000;
    b3g = Or3(2)*1000;
    c3g = Or3(3)*1000;
    
    a3 = p3(1)*1000;
    b3 = p3(2)*1000;
    c3 = p3(3)*1000;
    
    Fx3 = data.Fx3.line;
    Fy3 = data.Fy3.line;
    Fz3 = data.Fz3.line;
    Mx3 = data.Mx3.line;
    My3 = data.My3.line;
    Mz3 = data.Mz3.line;
   
    COP3 = COP_oneplate([Fx3 Fy3 Fz3],[Mx3 My3 Mz3],a3,b3,c3,thresh); % in local
    
    COP3_X = COP3(:,1) + a3g; % in global
    COP3_Y = -COP3(:,2) + b3g; % in global
    COP3_Z = COP3(:,3) + c3g; % in global
    
    data.COP3_X.line = COP3_X;
    data.COP3_X.event = struct;
    
    data.COP3_Y.line = COP3_Y;
    data.COP3_Y.event = struct;
    
    data.COP3_Z.line = COP3_Z;
    data.COP3_Z.event = struct;
    
    
end

