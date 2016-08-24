function data = pelvisOrientation(data,filt)

% GetPelvisOrientation determines the turn angle, angular velocity and angular acceleration 
% between the pelvis and the GCS using both the euler method and a simple vector approach
%
% ARGUMENTS
% data   ...   zoodata containing the pelvis channels PELO, PELA
% filt   ...   filter settings. Default no filter
%
% RETURNS
% data   ... data with new channels added
%
% NOTES:
% - This is the same calculation as the PiG based on Cardan sequence YXY.
%   See Kadaba et al. 1990 "Measurement of Lower Extremity Kinematics
%   During Level Walking". Journal of Orthopaedic Research.
%   Therefore the raw turn angle is the same as RPelvisAngles(:,3) from
%   PiG. Except, here we can make sure turn angle is from 0 to 90 deg
%   since.
% - PiG changes its reference axis based on direction of progresion (see
%   PIGmanual ver1). Here I follow this convention and "switch" axes at the +/- 45 deg mark.
%   This causes a small discontinuity that is ALWAYS filered  
%   
%
% Updated October 20th 2013
% old (weak) computation is kept commented below
%
% Updated Dec 3rd 2013
% - Turn angle computed by Euler and vector method consistently work




% Testing mode
%
if nargin==0
    close all
    disp('entering testing mode')
    filt.ftype = 'butterworth';                                            % Simple Butterworth
    filt.forder = 4;                                                       % 4th order is standard
    filt.pass = 'lowpass';                                                 % filter out high freq noise
    filt.cutoff = 3;
    grab
end

if nargin==1
    filt.ftype = 'butterworth';                                            % Simple Butterworth
    filt.forder = 4;                                                       % 4th order is standard
    filt.pass = 'lowpass';                                                 % filter out high freq noise
    filt.cutoff = 3;
end

% Extract trial info
%
dt = 1./data.zoosystem.Video.Freq;



% Error check for missing markers
%
if ~isfield(data,'PELO') || ~isfield(data,'PELA')
    
    if ~isfield(data,'PELO_x')
        error('missing PELO and PELA markers')
    else
        data.PELO.line = [data.PELO_x.line data.PELO_y.line data.PELO_z.line];
        data.PELA.line = [data.PELA_x.line data.PELA_y.line data.PELA_z.line];
        data.PELP.line = [data.PELP_x.line data.PELP_y.line data.PELP_z.line];
    end
end



% Define pelvis unit vectors
%
PELO = data.PELO.line;                                   % pelvis origin
PELA = data.PELA.line;                                   % pelvis virtual marker pointing anteriorly
PELP = data.PELP.line;                                   % pelvis virtual marker pointing proximally

kp = makeunit(PELP-PELO);                                % actual pelvis unit vector in prox dir
ip = makeunit(PELA-PELO);                                % actual pelvis unit vector in ant dir


% Define GCS vectors
%
I = longunit(PELO,'i');
J = longunit(PELO,'j');


% Compute Pelvic angles (Main Method)
%
% a) pelvic tilt
dotp = diag(-kp*J');
phi = asind(dotp);                                        % should match data.RPelvisAngles.line(:,1)
phi_pig = data.RPelvisAngles.line(:,1);

% pelvic obliquity
dotp = diag(kp*I');
theta = asind(dotp./cosd(phi));                           % should match data.RPelvisAngles.line(:,2)
theta_pig = data.RPelvisAngles.line(:,2);

% c) int/ext rotation
dotpx = diag(ip*I');
dotpy = diag(ip*J');
psix = asind( dotpx./cosd(phi));                          % close match to data.RPelvisAngles.line(:,3)
psiy = asind( dotpy./cosd(phi));                          % close match to data.RPelvisAngles.line(:,3)
psi_pig = data.RPelvisAngles.line(:,3);                   % actual angle made up of psix and psiy




% Check Pelvis angles and correct for trials that start around +/- 90 
%
trial_length = length(psi_pig);
frames = round(0.10*trial_length);

if max(psi_pig(1:frames)) >70
        
    temp = -phi;                                        % switch phi and theta                     
    phi = theta;
    theta = temp;
    
    psi_pig = psi_pig-90;                               % change quadrant for psi_pig
    
    psix = asind( dotpx./cosd(phi));                    % new psix based on correct phi
    psiy = asind( dotpy./cosd(phi));                    % new psiy based on correct phi
    
    
%     subplot(1,2,1)                                    % new psiy based on correct phi
%     plot(phi)
%     hold on
%     plot(data.RPelvisAngles.line(:,1),'r')
%     
%     subplot(1,2,2)
%     plot(theta)
%     hold on
%     plot(data.RPelvisAngles.line(:,2),'r')
    
    
elseif min(psi_pig(1:frames)) <-70
    
    temp = -phi;                                        % switch phi and theta 
    phi = theta; 
    theta = temp;
    
    psi_pig = psi_pig+90;                               % change quadrant for psi_pig
  
    psix = asind( dotpx./cosd(phi));                    % new psix based on correct phi
    psiy = asind( dotpy./cosd(phi));                    % new psiy based on correct phi
    
%     subplot(1,2,1)                                    % for checking correct switch
%     plot(phi)
%     hold on
%     plot(data.RPelvisAngles.line(:,1),'r')
%     
%     subplot(1,2,2)
%     plot(theta)
%     hold on
%     plot(data.RPelvisAngles.line(:,2),'r')
    
    
end



[~,Dir] = GetDir(data);                                  % find direction of walking

psi = zeros(length(psiy),1);                             % initiate psi

if isin(Dir,'Jneg')
    
    for i = 1:length(psi)
        
        if psi_pig(i) <= 45 && psi_pig(i) >=-45   % in between -45 and 45 use psix
            psi(i) = psix(i);
            
        elseif psi_pig(i) > 45
            psi(i) = psiy(i)+90;
                        
        elseif psi_pig(i) <-45
            psi(i) = -psiy(i)-90;
            
        else
            error('This angle should not be possible')
        end
    end
    
    
else
    
    for i = 1:length(psi)
        
        if psi_pig(i) <= 45 && psi_pig(i) >=-45     % [-45,45] 
            psi(i) = psix(i);
            
        elseif psi_pig(i) > 45
            psi(i) = psiy(i)-90;
            
        elseif psi_pig(i) <-45
            psi(i) = -psiy(i)+90;
            
        else
            error('This angle should not be possible')
        end
    end
    
end

% Makes output the same as PiG
%
% if isin(Dir,'Jpos')
%     psi = -psi;
% end


% make all turn angles btw 0 and 90
%
if psi(end) < -45
    psi = -psi;
end


% filter psi for discontinuity at 45 deg
%
fsamp = data.zoosystem.Video.Freq;
cut = 8;
psi = bmech_filter('vector',psi,'fsamp',fsamp,'cutoff',cut);


% filter other euler angles (theta, phi)
%
if isstruct(filt)
   theta =  bmech_filter('vector',theta,'fsamp',fsamp,'filt',filt);
   phi =  bmech_filter('vector',phi,'fsamp',fsamp,'filt',filt);
end


% compute 1st derivatives
%
phidot = gradient(phi)./dt;
psidot = gradient(psi)./dt;
thetadot = gradient(theta)./dt;


if isstruct(filt)
   phidot =  bmech_filter('vector',phidot,'fsamp',fsamp,'filt',filt);
   psidot =  bmech_filter('vector',psidot,'fsamp',fsamp,'filt',filt);
   thetadot =  bmech_filter('vector',thetadot,'fsamp',fsamp,'filt',filt);
end

% Compute 2nd derivatives
%
psiddot = gradient(psidot)./dt;
thetaddot = gradient(thetadot)./dt;


if isstruct(filt)
   psiddot =  bmech_filter('vector',psiddot,'fsamp',fsamp,'filt',filt);
   thetaddot =  bmech_filter('vector',thetaddot,'fsamp',fsamp,'filt',filt);
end



% compute angular velocity
%
omega_z = psidot - thetadot.*sind(phi);


% compute angular acceleration
%
alpha_z = psiddot - thetaddot.*sind(phi) - thetadot.*phidot.*cosd(phi);

% 
%  %For checking turning trials
% 
% if max(abs(psi))<45
%     close all
%     figure
%     plot(psi)
%     hold on
%     plot(psi_pig,'r')
%     legend('my calc','PiG')
%     
%     pause(0.5)
% end







% add to zoosystem
%

data = addchannel(data,'TurnPLA',[phi theta psi],'video');
data = addchannel(data,'TurnAngVelEuler',omega_z,'Video');
data = addchannel(data,'TurnAngAccEuler',alpha_z,'Video');

if ~isfield(data.zoosystem.Units,'Angles')
    data.zoosystem.Units.Angles = 'deg';
end




%--VECTOR VERSION------------------
%

% Extract anterior pelvis vector-
% 
pvec = makeunit(PELA-PELO);
pvec(:,3) = 0;

c = cross(I,pvec);
c = c(:,3);

% compute turn angle
%
turn_angle_x = angle(pvec,I,'deg')-90;

turn_angle = zeros(length(pvec),1);
type =  data.zoosystem.Header.Description;

if isin(Dir,'Jpos') 
    
    for i = 1:length(pvec)
    
        if c(i) >0 
            turn_angle(i) =  turn_angle_x(i);
        
        else  % it can only go negative at end of trial for turning trials
            
            if isin(type,'Left')
               turn_angle(i) = -turn_angle_x(i)+180;   

            elseif isin(type,'Right')
                turn_angle(i) = -turn_angle_x(i)-180;  
                
            else
                error('not possible!')
            end
            
        end
    end
    
else
    
    for i = 1:length(pvec)
    
        if c(i) <0 
            turn_angle(i) =  turn_angle_x(i);
        
        else  % it can only go positive at end of trial for turning trials
            
            if isin(type,'Left')
               turn_angle(i) = -turn_angle_x(i)-180;   

            elseif isin(type,'Right')
                turn_angle(i) = -turn_angle_x(i)+180;   
                
            else
                error('not possible!')
            end
           
        end
    end
     
end
    
 

% make all turn angles btw 0 and 90
%
if turn_angle(end) < -45
    turn_angle = -turn_angle;
end

if isstruct(filt)
    turn_angle = bmech_filter('vector',turn_angle,'fsamp',fsamp,'cutoff',cut);
end


% compute turn angular velocity
%
turn_angvel = gradient(turn_angle)./dt;

if isstruct(filt)
   turn_angvel =  bmech_filter('vector',turn_angvel,'fsamp',fsamp,'filt',filt);
end

% Compute turn angular accelerations
%
turn_angacc = gradient(turn_angvel)./dt;

if isstruct(filt)
   turn_angacc =  bmech_filter('vector',turn_angacc,'fsamp',fsamp,'filt',filt);
end


% add to zoosystem
%
data = addchannel(data,'TurnAngle',turn_angle,'Video');
data = addchannel(data,'TurnAngVel',turn_angvel,'Video');
data = addchannel(data,'TurnAngAcc',turn_angacc,'Video');

if ~isfield(data.zoosystem.Units,'Angles')
    data.zoosystem.Units.Angles = 'deg';
end






%=====PLOTS FOR COMPARISONS=============

% Check computations in test mode
%
if nargin==0
    
    t = 1:1:length(psi);

    figure
    subplot(1,3,1)
    plot(t,phi_pig,'b');    % put -ive for right turn
    hold on
    plot(t,phi,'r')
    
    subplot(1,3,2)
    plot(t,theta_pig,'b');    % put -ive for right turn
    hold on
    plot(t,theta,'r')
    
    subplot(1,3,3)
    plot(t,psi_pig,'b');    % put -ive for right turn
    hold on
    plot(t,-psi,'r')
    plot(t,turn_angle,'k')

    legend({'PiG','My Calc'},'location','best')
    fig2ppt
    
    figure
    plot(t,psi_pig,'b');    % put -ive for right turn
    hold on
    plot(t,psi,'r')
    plot(t,turn_angle,'k')
    legend({'psi PiG','psi Euler','Turn Angle'},'location','best')
    fig2ppt

    figure
    plot(t,omega_z)
    hold on
    plot(t,turn_angvel,'k')
    hline(0,'k')
    xlabel('time (s)')
    ylabel('angular velocity (deg/sec)')
    fig2ppt
    legend({'AngVel Euler','AngVel Turn'})
    
    figure
    plot(t,alpha_z)
    hold on
    plot(t,turn_angacc,'k')
    hline(0,'k')
    xlabel('time (s)')
    ylabel('angular acceleration (deg/sec^2)')
    legend({'AngAcc Euler','AngAcc Turn'})
    fig2ppt
   
end

