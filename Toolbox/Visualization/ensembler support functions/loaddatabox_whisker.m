function loaddatabox_whisker(fld,figs,settings,chartType)

% LOADDATABOX_WHISKER(fld,figs,settings) loads box and whisker data into ensembler

fl = engine('path',fld,'extension','zoo');

if isempty(fl)
    ensembler_msgbox(fld,'No zoo files found')
end

ydataForZooFiles(size(figs, 1)) = struct();

for i = 1:length(fl)
    data = zload(fl{i});                                       % load zoo data
    fig = findfigure(fl{i},figs);                              % find in which figure it belongs
    batchdisp(fl{i},'loading')                                 % keep old version also
    axs = findobj(fig,'type','axes');
    for j = 1:length(axs)
        ch = get(axs(j),'tag');
        if ~isempty(ch) && isempty(strfind(ch,' '))
            if isfield(ydataForZooFiles(fig.Number),ch)
                ydataForZooFiles(fig.Number).(ch) = cat(1, ydataForZooFiles(fig.Number).(ch), data.(ch).line);
            else
                ydataForZooFiles(fig.Number).(ch) = data.(ch).line;
            end
        end
    end
end
for i = 1:size(figs, 1)
    fig = findfigure(fl{i},figs);
    for j = 1:length(axs)
        ch = get(axs(j),'tag');
        if ~isempty(ch) && isempty(strfind(ch,' '))
            ax = findobj(fig,'type','axes','tag',ch);
            figure(fig.Number)
            axes(ax)
            if strcmp(chartType, 'whisker')
                bplot(ydataForZooFiles(i).(ch));
            elseif strcmp(chartType, 'violin')
                hold on
                violin(ydataForZooFiles(i).(ch));
                hold off
            elseif strcmp(chartType, 'bar')
                meanVal = mean(ydataForZooFiles(i).(ch));
                if meanVal < 0
                    set(ax,'YLim',[-inf 0]);
                else
                    set(ax,'YLim',[0 inf]);
                end
                hold on
                bar(meanVal);
                hold off
            end
        end
    end
end