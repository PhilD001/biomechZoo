function plotdata


% EMG
musnames   = { ...
'TibialisAnt',...
'GastrocnemiusMed', ...
'RectusFem', ...
'HamstringsLat', ...
'HamstringsMed'};

anglenames = { ...
'AAPelvicObliquity_UpDn', ...   
'APelvicRotation_IntExt', ...   
'APelvicTilt_AntPost', ...      
'ATrunkObliquity_UpDn', ...     
'ATrunkRotation_IntExt', ...    
'ATrunkTilt_AntPost'}; 

plotnames(musnames,'muscles EMG', 'EMG')
plotnames(anglenames,'angles OK', 'angle [°]');



function plotnames(names,type,ylab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('name',type)
n = length(names);
ncol = 2;
nrow = ceil(n/ncol);

for i=1:length(names)
    
    name = char(names(i));
    data = load([name '.txt']);

    time = data(:,1);

    veryslow = data(:,2:4);
    slow     = data(:,5:7);
    free     = data(:,8:10);
    fast     = data(:,11:13);
    veryfast = data(:,14:16);
    
    subplot(nrow,ncol,i)   
        plot(time,free(:,2),'b')
        hold on
        plot(time,veryslow(:,2),'g')
        plot(time,slow(:,2),'g')
        plot(time,fast(:,2),'r')
        plot(time,veryfast(:,2),'r')
        
        title(name)
        xlabel('time [%]')
        ylabel(ylab)
    
end

