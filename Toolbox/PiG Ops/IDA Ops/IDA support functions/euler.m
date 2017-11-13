function Euler=euler(LKIN,fsamp,f)

% EULER creates euler transformations.
%
% ARGUMENTS
%
% LKIN    ...  segment embedded coordinate system
% fsamp   ...  sampling frequency
% f       ...  choice to filter. f = 0 no, f=1 yes
% cut     ...  cut-off frequency for filter
%
% RETURNS
% Euler  ...   structured array containing phi, theta, psi angles for
%                each segment
% NOTES
% 1) Steps in Euler   a) move COM of segment to origin of global (XYZ)
%                       b) define line of nodes L
%                       c) perform the three rotations: phi, theta, psi
%
% Updated Jan 4th 2008
% - Euler angle output is in radians
%
% Updated Jan 13th 2008
% -Changed computation of Euler angles. acos has been used to fix problem
%  areas
%
% Updated Jan 22 2011
% -Euler outputs match Vaughan
%
% Updated August 15th 2013
% - user has control over filtering
%
% Updated Nov 13th 2017
% - big fix (typo) when run with filter



%------------GLOBAL COORDINATES---------

d = size(LKIN.RightThigh.Axes.k);
empty = zeros(d(1),1);          %column of zeros the length of sampling points

unity = ones(d(1),1);           %column of ones the length of sampling points

I = [unity empty empty];      % n x 3 matrix
K = [empty empty unity];      % K global axis



%----FOR PLUGINGAIT BONES-----

%  1) Creation of line of nodes (L)------

% create line of nodes    (K x k) / |K x k|

ipelvis = makeunit(LKIN.Pelvis.Axes.i);
kpelvis = makeunit(LKIN.Pelvis.Axes.k);
Lpelvis = makeunit(cross(K,kpelvis,2));

i1 = makeunit(LKIN.RightThigh.Axes.i);
k1 = makeunit(LKIN.RightThigh.Axes.k);            %Right Thigh
L1 = makeunit(cross(K,k1,2));                         %   L is n x 3 matrix

i2 = makeunit(LKIN.LeftThigh.Axes.i);
k2 = makeunit(LKIN.LeftThigh.Axes.k);             %Left Thigh
L2 = makeunit(cross(K,k2,2));

i3 = makeunit(LKIN.RightShank.Axes.i);
k3 = makeunit(LKIN.RightShank.Axes.k);            %Righ shank
L3 = makeunit(cross(K,k3,2));

i4 = makeunit(LKIN.LeftShank.Axes.i);
k4 = makeunit(LKIN.LeftShank.Axes.k);             %Left shank
L4 = makeunit(cross(K,k4,2));

i5 = makeunit(LKIN.RightFoot.Axes.i);
k5 = makeunit(LKIN.RightFoot.Axes.k);            %Right foot
L5 = makeunit(cross(K,k5,2));

i6 = makeunit(LKIN.LeftFoot.Axes.i);
k6 = makeunit(LKIN.LeftFoot.Axes.k);             %left foot
L6 = makeunit(cross(K,k6,2));


% 2) EULER ROTATIONS----------

% Original code I used. This is different from Vaughan
%

r = struct; % temp struct

r.theta_pelvis =  acos(dot(K,kpelvis,2));                       % Please check with Vaughan data
r.phi_pelvis   = -asin( dot(cross(I,Lpelvis,2),K,2))+pi;                        % Please check with Vaughan data
r.psi_pelvis   =  acos(dot(ipelvis,Lpelvis,2));

r.theta_rthigh =  acos(dot(K,k1,2));                       %works
r.phi_rthigh   = -asin( dot(cross(I,L1,2),K,2))+pi;                        %works !!
r.psi_rthigh   =  acos(dot(i1,L1,2));                      %works

r.theta_lthigh =  acos(dot(K,k2,2));                       %works
r.phi_lthigh   = -asin( dot(cross(I,L2,2),K,2))+pi;                    %works!!!
r.psi_lthigh   =  acos( dot(i2,L2,2));                     %works

r.theta_rshank =  acos ( dot(K,k3,2));                     %works
r.phi_rshank   = -asin( dot(cross(I,L3,2),K,2))+pi;       %works!!
r.psi_rshank   =  acos(dot(i3,L3,2));                      %works

r.theta_lshank =  acos(dot(K,k4,2));                       %works
r.phi_lshank   = -asin( dot(cross(I,L4,2),K,2))+pi;       %works!!
r.psi_lshank   =  acos(dot(i4,L4,2));                      %works

r.theta_rfoot =   acos(dot(K,k5,2));                       %works
r.phi_rfoot   =  -asin( dot(cross(I,L5,2),K,2))+pi;       %works!!
r.psi_rfoot   =   asin ( dot(cross(L5,i5,2),k5,2));        %good

r.theta_lfoot =   acos(dot(K,k6,2));                       %works
r.phi_lfoot   =  -asin( dot(cross(I,L6,2),K,2))+pi;       %works!!
r.psi_lfoot   =   asin ( dot(cross(L6,i6,2),k6,2));        %good


% filter if selected by user

if f==1    % default filtering settings
    %cut = 10;
    %ftype = 'butterworth';
    %order = 4;
    %pass = 'lowpass';
    filt = setFilt;
    
    ch = fieldnames(r);
    for i = 1:length(ch)
        r.(ch{i}) = filter_line(r.(ch{i}),filt,fsamp);
    end
    
elseif isstruct(f)
    ch = fieldnames(r);
   
    for i = 1:lenght(ch)
        r.(ch{i}) = filter_line(r.(ch{i}),filt,fsamp);
    end
end

% Here we have exact Vaughan method does not work!
%
% phi_pelvis   = my_filter(   asin( dot(cross(I,Lpelvis,2),K,2))             ,fsamp);                        % Please check with Vaughan data
% theta_pelvis = my_filter(   asin(dot(cross(K,kpelvis,2),Lpelvis,2))        ,fsamp);                       % Please check with Vaughan data
% psi_pelvis   = my_filter(   asin(dot(cross(Lpelvis,ipelvis,2),kpelvis,2))  ,fsamp);
%
% phi_rthigh   = my_filter(   asin( dot(cross(I,L1,2),K,2))                  ,fsamp);                        % Please check with Vaughan data
% theta_rthigh = my_filter(   asin(dot(cross(K,k1,2),L1,2))                  ,fsamp);                       % Please check with Vaughan data
% psi_rthigh   = my_filter(   asin(dot(cross(L1,i1,2),k1,2))                ,fsamp);
%
% phi_lthigh   = my_filter(   asin( dot(cross(I,L2,2),K,2))                  ,fsamp);                        % Please check with Vaughan data
% theta_lthigh = my_filter(   asin(dot(cross(K,k2,2),L2,2))                  ,fsamp);                       % Please check with Vaughan data
% psi_lthigh   = my_filter(   asin(dot(cross(L2,i2,2),k2,2))               ,fsamp);
%
% phi_rshank   = my_filter(   asin( dot(cross(I,L3,2),K,2))                  ,fsamp);                        % Please check with Vaughan data
% theta_rshank = my_filter(   asin(dot(cross(K,k3,2),L3,2))                  ,fsamp);                       % Please check with Vaughan data
% psi_rshank   = my_filter(   asin(dot(cross(L3,i3,2),k3,2))               ,fsamp);
%
% phi_lshank   = my_filter(   asin( dot(cross(I,L4,2),K,2))                  ,fsamp);                        % Please check with Vaughan data
% theta_lshank = my_filter(   asin(dot(cross(K,k4,2),L4,2))                  ,fsamp);                       % Please check with Vaughan data
% psi_lshank   = my_filter(   asin(dot(cross(L4,i4,2),k4,2))               ,fsamp);
%
% phi_rfoot   = my_filter(   asin( dot(cross(I,L5,2),K,2))                  ,fsamp);                        % Please check with Vaughan data
% theta_rfoot = my_filter(   asin(dot(cross(K,k5,2),L5,2))                  ,fsamp);                       % Please check with Vaughan data
% psi_rfoot   = my_filter(   asin(dot(cross(L5,i5,2),k5,2))               ,fsamp);
%
% phi_lfoot   = my_filter(   asin( dot(cross(I,L6,2),K,2))                  ,fsamp);                        % Please check with Vaughan data
% theta_lfoot = my_filter(   asin(dot(cross(K,k6,2),L6,2))                  ,fsamp);                       % Please check with Vaughan data
% psi_lfoot   = my_filter(   asin(dot(cross(L6,i6,2),k6,2))               ,fsamp);



%------------------EXPORT AS STRUCT ARRAY-------

Euler.Pelvis = [r.theta_pelvis r.phi_pelvis  r.psi_pelvis];
Euler.RightThigh = [r.theta_rthigh r.phi_rthigh  r.psi_rthigh];
Euler.LeftThigh = [r.theta_lthigh r.phi_lthigh  r.psi_lthigh];
Euler.RightShank = [r.theta_rshank r.phi_rshank r.psi_rshank];
Euler.LeftShank = [r.theta_lshank r.phi_lshank  r.psi_lshank];
Euler.RightFoot = [r.theta_rfoot r.phi_rfoot  r.psi_rfoot];
Euler.LeftFoot = [r.theta_lfoot r.phi_lfoot  r.psi_lfoot];



%----OXFORD BONES-----

if isfield(LKIN,'RightHindFoot')
    
    %  1) Creation of line of nodes (L)------
    
    % k_pelvis = LKIN.Pelvis.kpelvis;
    % Lpelvis = cross(L,kpelvis,2);
    
    % create line of nodes    (K x k) / |K x k|
    
    iRTIB = makeunit(LKIN.RightShankOFM.Axes.i);
    kRTIB = makeunit(LKIN.RightShankOFM.Axes.k);            %Righ shank
    LRTIB = makeunit(cross(K,kRTIB,2));
    
    iLTIB = makeunit(LKIN.LeftShank.Axes.i);
    kLTIB = makeunit(LKIN.LeftShank.Axes.k);             %Left shank
    LLTIB = makeunit(cross(K,kLTIB,2));
    
    iRHF = makeunit(LKIN.RightHindFoot.Axes.i);
    kRHF = makeunit(LKIN.RightHindFoot.Axes.k);            %Right foot
    LRHF = makeunit(cross(K,kRHF,2));
    
    iLHF = makeunit(LKIN.LeftHindFoot.Axes.i);
    kLHF = makeunit(LKIN.LeftHindFoot.Axes.k);            %Right foot
    LLHF = makeunit(cross(K,kLHF,2));
    
    iRFF = makeunit(LKIN.RightForeFoot.Axes.i);
    kRFF = makeunit(LKIN.RightForeFoot.Axes.k);            %Right foot
    LRFF = makeunit(cross(K,kRFF,2));
    
    iLFF = makeunit(LKIN.LeftForeFoot.Axes.i);
    kLFF = makeunit(LKIN.LeftForeFoot.Axes.k);            %Right foot
    LLFF = makeunit(cross(K,kRFF,2));
    
    % 2) EULER ROTATIONS----------
    
    r = struct; % temp struct
    
    r.theta_rshank =  acos ( dot(K,kRTIB,2));                     %works
    r.phi_rshank   = -asin( dot(cross(I,LRTIB,2),K,2))+pi ;       %works!!
    r.psi_rshank   =  acos(dot(iRTIB,LRTIB,2));                      %works
    
    r.theta_lshank =  acos(dot(K,kLTIB,2));                       %works
    r.phi_lshank   = -asin( dot(cross(I,LLTIB,2),K,2))+pi;       %works!!
    r.psi_lshank   =  acos(dot(iLTIB,LLTIB,2));                      %works
    
    r.theta_rhfoot =  acos ( dot(K,kRHF,2));                     %works
    r.phi_rhfoot   = -asin( dot(cross(I,LRHF,2),K,2))+pi;       %works!!
    r.psi_rhfoot   =  acos(dot(iRHF,LRHF,2));                      %works
    
    r.theta_lhfoot =  acos(dot(K,kLHF,2));                       %works
    r.phi_lhfoot   = -asin( dot(cross(I,LLHF,2),K,2))+pi;       %works!!
    r.psi_lhfoot   =  acos(dot(iLHF,LLHF,2));                      %works
    
    
    r.theta_rffoot =  acos(dot(K,kRFF,2));                       %works
    r.phi_rffoot   = -asin( dot(cross(I,LRFF,2),K,2))+pi;       %works!!
    r.psi_rffoot   =  asin ( dot(cross(LRFF,iRFF,2),kRFF,2));        %good
    
    r.theta_lffoot =  acos(dot(K,kLFF,2));                       %works
    r.phi_lffoot   = -asin( dot(cross(I,LLFF,2),K,2))+pi;       %works!!
    r.psi_lffoot   =  asin ( dot(cross(LLFF,iLFF,2),kLFF,2));        %good
    
    
    % filter if selected by user
    
    if f==1
        ch = fieldnames(r);
        for i = 1:lenght(ch)
            r.(ch{i}) = bmech_filter('vector',r.(ch{i}),'fsamp',fsamp,'cut-off',cut');
        end
    end
    
    %-----------------EXPORT AS STRUCT ARRAY-------
    
    Euler.RightShankOFM = [r.theta_rshank r.phi_rshank  r.psi_rshank];
    Euler.LeftShankOFM = [r.theta_lshank r.phi_lshank  r.psi_lshank];
    Euler.RightHindFoot = [r.theta_rhfoot r.phi_rhfoot  r.psi_rhfoot];
    Euler.LeftHindFoot = [r.theta_lhfoot r.phi_lhfoot r. psi_lhfoot];
    Euler.RightForeFoot = [r.theta_rffoot r.phi_rffoot r.psi_rffoot];
    Euler.LeftForeFoot = [r.theta_lffoot r.phi_lffoot  r.psi_lffoot];
    
    
end




































