% get normative data into matlab file format 
%
% original values from Stebbins G&P 2006 401-410
% 15 healthy children walking at free speed, speed was not 
% reported so it was assumed normal according to Schwartz JB 2008
%
% Updated by Phil Dixon
% Above is not true. Data comes from the green bands in "Oxford foot model training day"
% document (see current folder for document Oxford Foot Model presentation.pdf)

clear all
close all

normdata =[];
anglelist=[];
timen = (0:0.25:100)';

% cycle events: ----------------------------------------------------------
% [Free]	
velnd.m = 0.429; % typical average 
velnd.s = 0.026;
velnd.b = []; 
normdata.velnd =velnd;

% cycle events: ----------------------------------------------------------
% 
eve.OppositeFootOff.m     =  [];
eve.OppositeFootOff.s     =  [];

eve.OppositeFootContact.m =  [];
eve.OppositeFootContact.s =  [];

eve.IpsilateralFootOff.m  = 58.50;
eve.IpsilateralFootOff.s  = 1.73;

eve.DoubleSupport.m  = [];
eve.DoubleSupport.s  = [];

normdata.eve =eve;

% angles data ----------------------------------------------------------

anglenames = { ...
'AForefootHindfootAdduction', ...     
'AForefootHindfootDorsiflexion', ... 
'AForefootHindfootSupination', ...    
'AForefootTibiaAdduction', ...        
'AForefootTibiaDorsiflexion', ...        
'AForefootTibiaSupination', ...       
'AHindfootTibiaDorsiflexion', ...     
'AHindfootTibiaInversion', ...         
'AHindfootTibiaRotation', ...   
'ATibiaFemurFlexion', ...
'ATibiaFemurAdduction', ...
'ATibiaFemurRotation', ...
'AHalluxForefootDorsiflexion', ...           
'DNormalisedArchHeight'};              

[b,a] = butter(3,0.2);
          
for i=1:length(anglenames)
    name = char(anglenames(i));
    data = load([name '.txt']);
 
    time = data(:,1);
    sms = data(:,2:4);   % free (-1sd m +1sd)
    
    figure('name',name)
    % filter data
    for j=1:3
        smsi = interp1(time,sms(:,j),timen,'spline','extrap');
        vel.sms(:,j) = filtfilt(b,a,smsi);
        
        plot(time,sms(:,j),'b')
        %plot(timen,smsi,'g')
        hold on
        plot(timen,vel.sms(:,j),'r')
    end
    
    anglelist(i).name  = name; 
    anglelist(i).vel = vel;  
    anglelist(i).time  = timen;
end   

normdata.anglelist =anglelist;

% save to mat file
save('norm_oxford', 'normdata');
    
  
