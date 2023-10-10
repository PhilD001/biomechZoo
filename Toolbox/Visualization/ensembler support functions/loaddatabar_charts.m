function loaddatabar_charts(fld,figs,settings,combine,chartType,color)

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
    axs = findobj(fig,'type','axes');
    for j = 1:length(axs)
        ch = get(axs(j),'tag');
        if ~isempty(ch) && isempty(strfind(ch,' '))
            if(combine)
                ydata = [];
                for k = 1:size(figs, 1)
                    figYdata = findfigure(fl{k},figs);
                    ydata = cat(k, ydata, ydataForZooFiles(figYdata.Number).(ch));
                end
            else
                ydata = ydataForZooFiles(i).(ch);
            end
            ax = findobj(fig,'type','axes','tag',ch);
            figure(fig.Number)
            axes(ax)
            set(ax,'XLim',[-inf inf]);
            if(combine)
                set(ax,'YLim',[-inf inf])
            end
            if strcmp(chartType, 'whisker')
                if ~isempty(color)
                    bplot(ydata,'color',color);
                else
                    bplot(ydata);
                end
            elseif strcmp(chartType, 'violin')
                hold on
                if ~isempty(color)
                    violin(ydata,'facecolor', color);
                else
                    violin(ydata);
                end
                hold off
            elseif strcmp(chartType, 'bar(SD)')
                meanVal = [];
                stdVal = [];
                if(combine)
                    for k = 1:ndims(ydata)
                        meanVal = cat(k, meanVal, mean(ydata(:, k)));
                        stdVal = cat(k, stdVal, std(ydata(:, k)));
                    end
                else
                    meanVal = mean(ydata);
                    stdVal = std(ydata);  
                    set(ax,'XLim',[0 2]);
                end                 
                if min(meanVal) < 0
                    set(ax,'YLim',[max(meanVal)-100-(1.2*max(stdVal)) 0]);
                else
                    set(ax,'YLim',[0 max(meanVal)+100+(1.2*max(stdVal))]);
                end
                hold on
                if ~isempty(color)
                    bar(meanVal,'FaceColor', color);
                    
                else
                    bar(meanVal);
                end
                er = errorbar(meanVal, stdVal, '.');
                er.Color = [0 0 0];         
                er.LineStyle = 'none';
                hold off
            elseif strcmp(chartType, 'bar(CI)')
                meanVal = [];
                stdVal = [];
                ciVal = [];
                if(combine)
                    for k = 1:ndims(ydata)
                        meanVal = cat(k, meanVal, mean(ydata(:, k)));
                        stdVal = cat(k, stdVal, std(ydata(:, k)));
                        ciVal = cat(k, ciVal, 1.96*stdVal(k)./sqrt(length(ydata(:, k))));
                    end
                else
                    meanVal = mean(ydata);
                    stdVal = std(ydata);  
                    ciVal = 1.96*stdVal./sqrt(length(ydata));
                    set(ax,'XLim',[0 2]);
                end
                if min(meanVal) < 0
                    set(ax,'YLim',[max(meanVal)-100-(1.2*max(ciVal)) 0]);
                else
                    set(ax,'YLim',[0 max(meanVal)+100+(1.2*max(ciVal))]);
                end
                hold on
                if ~isempty(color)
                    bar(meanVal,'FaceColor', color);
                else
                    bar(meanVal);
                end
                er = errorbar(meanVal, ciVal, '.');
                er.Color = [0 0 0];         
                er.LineStyle = 'none';
                hold off
            end
        end
    end
end