function  display_director_graph(data,ch)

if nargin==2
    xcol = [1 0 0]; % red color for x axis arrow
    ycol = [0 1 0]; % green color for y axis arrows
    zcol = [0 0 1]; % blue color for z axis arrows
end

% clear old ones
delete(findobj('type','line','tag','x gdata'));
delete(findobj('type','line','tag','y gdata'));
delete(findobj('type','line','tag','z gdata'));


ax = findobj('type','axes','tag','data display');
[~,c] = size(data.(ch).line);

if c==1
    line('parent',ax,'xdata',1:length(data.(ch).line),'ydata',data.(ch).line(:,1),'color','r','tag','x gdata');
%     if graph_legend
%         lg = legend(ax,'1D');
%         set(lg,'TextColor',[1 1 1],'Position',[0.1459    0.6082    0.0899    0.0890],'tag','graph legend');
%     end
else
    line('parent',ax,'xdata',1:length(data.(ch).line),'ydata',data.(ch).line(:,1),'color',xcol,'tag','x gdata');
    line('parent',ax,'xdata',1:length(data.(ch).line),'ydata',data.(ch).line(:,2),'color',ycol,'tag','y gdata');
    line('parent',ax,'xdata',1:length(data.(ch).line),'ydata',data.(ch).line(:,3),'color',zcol,'tag','z gdata');
%     if graph_legend
%         lg = legend(ax,'X','Y','Z');
%         set(lg,'TextColor',[1 1 1],'Position',[0.1459    0.6082    0.0899    0.0890],'tag','graph legend');
%         
%     end
end

% show title
set(get(ax,'Title'),'string',ch, 'Color',[0.8 0.8 0.8])