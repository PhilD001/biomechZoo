function fig2paper


axWidth = 1;
axHeight = 1;


FontName = 'Arial';
FontSize = 10; %axWidth*10;
FontWeight = 'normal';
TitleFontSizeMultiplier = 0.8;
TitleFontWeight = 'normal';
LabelFontSizeMultiplier = 1;




% Set up axes font
%
ax = findobj(gcf,'type','axes');
for i = 1:length(ax)
    position = get(ax(i),'position');
    set(ax(i),'FontName',FontName,'FontSize',FontSize,'FontWeight',FontWeight,...
        'TitleFontSizeMultiplier',TitleFontSizeMultiplier,'TitleFontWeight',...
        TitleFontWeight,'LabelFontSizeMultiplier',LabelFontSizeMultiplier,...
        'position',[position(1:2) axWidth axHeight])
end

% Set up text fonts
%
txt = findobj(gcf,'type','text');
for i = 1:length(txt)
    set(txt(i),'FontName',FontName,'FontSize',FontSize,'FontWeight',FontWeight)
end

% set up legend fonts
%
lg = findobj(gcf,'type','legend');
set(lg,'FontName',FontName,'FontSize',FontSize-2,'FontWeight',FontWeight); %,...
  %  'position',[position(1:2) axWidth axHeight/2])

    