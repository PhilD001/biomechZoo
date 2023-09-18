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
            ydata = ydataForZooFiles(i).(ch);
            ax = findobj(fig,'type','axes','tag',ch);
            figure(fig.Number)
            axes(ax)
            if strcmp(chartType, 'whisker')
                bplot(ydata);
            elseif strcmp(chartType, 'violin')
                hold on
                violin(ydata);
                hold off
            elseif strcmp(chartType, 'bar(SD)')
                meanVal = mean(ydata);
                stdVal = std(ydata);                  
                if meanVal < 0
                    set(ax,'YLim',[meanVal-100-(1.2*stdVal) 0]);
                else
                    set(ax,'YLim',[0 meanVal+100+(1.2*stdVal)]);
                end
                set(ax,'XLim',[0 2]);
                hold on
                bar(meanVal);
                er = errorbar(meanVal, stdVal, '.');
                er.Color = [0 0 0];         
                er.LineStyle = 'none';
                hold off
            elseif strcmp(chartType, 'bar(CI)')
                meanVal = mean(ydata);
                stdVal = std(ydata);  
                ciVal = 1.96*stdVal./sqrt(length(ydata));
                if meanVal < 0
                    set(ax,'YLim',[meanVal-100-(1.2*ciVal) 0]);
                else
                    set(ax,'YLim',[0 meanVal+100+(1.2*ciVal)]);
                end
                set(ax,'XLim',[0 2]);
                hold on
                bar(meanVal);
                er = errorbar(meanVal, ciVal, '.');
                er.Color = [0 0 0];         
                er.LineStyle = 'none';
                hold off
            end
        end
    end
end