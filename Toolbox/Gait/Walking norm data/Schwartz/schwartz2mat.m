% get normative data into matlab file format 
%
% Created by Harald Boehm
%
% Updated by Philippe C. Dixon

file = which('schwartz2mat.m');
[pth,file] = fileparts(file);
s = filesep;    % determine slash direction based on computer type


normdata =[];
anglelist=[];

% cycle events: ----------------------------------------------------------
velnd.str = {'Very Slow', 'Slow', 'Free', 'Fast', 'Very Fast'};	
velnd.m = [0.172 0.290 0.429 0.560 0.694];
velnd.s = [0.035 0.027 0.026 0.031 0.047];
velnd.b = [0 0.231 0.360 0.494 0.627 9]; 
normdata.velnd =velnd;

% cycle events: ----------------------------------------------------------
% [Very Slow, Slow, Free, Fast, Very Fast]	
eve.OppositeFootOff.m     =  [18 12 10  8  7];
eve.OppositeFootOff.s     =  [-5 -2	-2 -2 -2];

eve.OppositeFootContact.m =  [50 50 50 50 49];
eve.OppositeFootContact.s =  [-3 -2 -2 -2 -2];

eve.IpsilateralFootOff.m  = [68 62 59 58 56];
eve.IpsilateralFootOff.s  = [-5 -2 -2 -2 -2];

eve.DoubleSupport.m  = [36  24 19 16 14];
eve.DoubleSupport.s  = [-10 -4 -2 -3 -3];


% other parameters required for power integration 
toff = eve.IpsilateralFootOff.m; 
bodyh  = [1.55 1.55 1.56 1.55 1.49];  % Table 1
tgesnd  =[3.20 2.24 2.55 2.20 1.60];  % Fig 2 

tges = tgesnd .* sqrt(bodyh/9.81);  % !! bodyh not leg length
dt = tges/51;

normdata.eve =eve;

% angles data ----------------------------------------------------------
% [Very Slow, Slow, Free, Fast, Very Fast]	

parnames = { ...
'ATrunkObliquity_UpDn', ...     
'ATrunkRotation_IntExt', ...    
'ATrunkTilt_AntPost', ...
'APelvicObliquity_UpDn', ...   
'APelvicRotation_IntExt', ...   
'APelvicTilt_AntPost', ...      
'AHip_AddAbd', ...               
'AHip_FlexExt', ...              
'AHip_IntExt', ...   
'AKnee_AddAbd', ...              
'AKnee_FlexExt', ...             
'AKnee_IntExt', ...  
'AAnkle_DfPf', ...               
'AFootProgress_IntExt', ...
'MHip_AddAbd', ...               
'MHip_FlexExt', ...              
'MKnee_AddAbd', ...              
'MKnee_FlexExt', ...             
'MAnkle_DfPf', ... 
'PHip', ...               
'PKnee', ...              
'PAnkle',...
'MHamstringsLat','MHamstringsMed','MGastrocnemiusMed','MRectusFem','MTibialisAnt'};

pwrnames = { ...
'PHip', ...               
'PKnee', ...              
'PAnkle'}; 


for i=1:length(parnames)
    name = char(parnames(i));
    data = load([name '.txt']);
 
    time = data(:,1);
    vel(1).sms = data(:,2:4);   % veryslow (-1sd m +1sd)
    vel(2).sms = data(:,5:7);   % slow  
    vel(3).sms = data(:,8:10);  % free 
    vel(4).sms = data(:,11:13); % fast 
    vel(5).sms = data(:,14:16); % veryfast
    
    anglelist(i).name  = name; 
    anglelist(i).vel = vel;  
    anglelist(i).time  = time;
end   


for i=1:length(pwrnames)
    name = char(pwrnames(i));
    for j=1:length(anglelist)
        if strcmpi(name,anglelist(j).name)
            vel = anglelist(j).vel;
            for k=1:5
                for t=1:length(anglelist(i).time) % get stance duration
                    if anglelist(i).time(t) >= toff(k)  
                        ntoff = t; 
                        break
                    end
                end
                
                P = vel(k).sms(:,2);
                PG = zeros(size(P));
                PA = PG;

                for t=1:length(PG)
                        if P(t) >= 0
                           PG(t) = P(t);
                        else  
                           PA(t) = -P(t);
                        end
                end %t

                anglelist(j).tintG(k) = trapz(PG)*dt(k);  
                anglelist(j).tintA(k) = trapz(PA)*dt(k); 

                anglelist(j).tintGS(k) = trapz(PG(1:ntoff))*dt(k);  
                anglelist(j).tintAS(k) = trapz(PA(1:ntoff))*dt(k); 
  
            end % if
        end %k
    end %j
end   %i

normdata.anglelist = anglelist;

% save to mat file
save([pth,s,'norm_schwartz'], 'normdata');
    
  