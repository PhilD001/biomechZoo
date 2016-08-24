function export


data = findobj(gcf,'type','line');

if ~isempty(findobj(gcf,'type','patch'))
    std = findobj(gcf,'type','patch','visible','on');
end

ylab = get(gca,'YLabel');
xlab = get(gca,'XLabel');

xlim = get(gca,'Xlim');
ylim = get(gca,'Ylim');

title = get(gca,'Title');

lhnd = findobj(gcf,'type','axes','tag','legend');
if ~isempty(lhnd)
    delete(lhnd)
    return
end
tg = get(data,'tag');


fig = figure;

for i = 1:length(data)          % copies all line info to new plot
    copyobj(data(i),gca)
end

for j = 1:length(std)           % copies STD to new plot
    copyobj(std(j),gca)
end

copyobj(ylab,gca)               % copies axis labels to subplot
copyobj(xlab,gca)

set(gca,'Xlim',xlim);           % maintain proper axis limits
set(gca,'Ylim',ylim);

copyobj(title,gca)

hline(0,'k')
legend(tg)
          