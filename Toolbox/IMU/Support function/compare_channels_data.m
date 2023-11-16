function compare_channels_data(data,pairs2compare,row,colum,titles)
% COMPARE_CHANNELS_DATA to compare and plot multiple channels in one graph
%Arguments
% data          ...   Struct, zoo file struct data
% pairs2compare ...   Cell Array, combinations of channel names which to compare in 1 plot
% row           ...   number, number of rows in the figure
% colum         ...   number, number of colum in the figure
% titles        ...   Cell Array, List of titles
%Return 
% Figure with the comparision plots
% Example check IMU_workboard.m
%
figure
for i=1:length(pairs2compare)
    
    subplot(row,colum,i)
    plot(data.(pairs2compare{i}{1}).line,'b')
    hold on
    plot(data.(pairs2compare{i}{2}).line,'r')
    title(titles{i})
end
set(gcf, 'Position', get(0, 'Screensize'));
leg=legend(["IMU","MoCap"]);

leg.Position=[0.481706686937371,0.474958698844575,0.0587239589417969,0.0487446591385408];