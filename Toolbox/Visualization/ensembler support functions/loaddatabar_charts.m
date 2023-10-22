function loaddatabar_charts(fld,figs,settings,combine,chartType,color)

% LOADDATABOX_WHISKER(fld,figs,settings) loads box and whisker data into ensembler
%
%  todo: allow for numerous events to be plotted


fl = engine('path',fld,'extension','zoo');

if isempty(fl)
    ensembler_msgbox(fld,'No zoo files found')
end

if isempty(color)
    color = settings.BarChartColor;
end

% gather events by type in a struct
edataForZooFiles = struct();
for i = 1:length(fl)
    data = zload(fl{i});                                       % load zoo data
    fig = findfigure(fl{i},figs);                              % find in which figure it belongs
    figName = fig.Name;
    if ~isfield(edataForZooFiles, figName)
        edataForZooFiles.(figName) = struct;
    end
    batchdisp(fl{i},'loading')                                 % keep old version also
    axs = findobj(fig,'type','axes');
    for j = 1:length(axs)
        ch = get(axs(j),'tag');
        evts = fieldnames(data.(ch).event);
        if isempty(evts)
           ensembler_msgbox(fld,['WARNING : no events found for channel ', ch, ' remove axes'])
           warning(['no events found for channel ', ch]);
        else
            for e = 1:length(evts)
                evt = evts{e};
                if ~isempty(ch) && isempty(strfind(ch,' '))
                    evt_val = data.(ch).event.(evt);
                    evt_val = evt_val(2); % 2 is event value
                    if isfield(edataForZooFiles.(figName), ch)
                        
                        if ~isfield(edataForZooFiles.(figName).(ch), 'event')
                            edataForZooFiles.(figName).(ch).event = struct;
                        end
                        
                        if isfield(edataForZooFiles.(figName).(ch).event, evt)
                            edataForZooFiles.(figName).(ch).event.(evt) = cat(1, edataForZooFiles.(figName).(ch).event.(evt), evt_val);
                        else
                            edataForZooFiles.(figName).(ch).event.(evt) = evt_val;
                        end
                    else
                        edataForZooFiles.(figName).(ch).event.(evt) = evt_val;
                    end
                end
            end
        end
    end
end

% sort figure the same way each run
figs = findobj('type','figure');
other_figs = [];
for i = 1:length(figs)
    figObj = findobj(get(figs(i), 'Children'), 'Type', 'uimenu');
    if ~isempty(figObj)
        mainObj = figs(i);
    else
        other_figs = figs(i);
    end
end

ordered_figs = [other_figs; mainObj];


% extract struct to create graphs
disp(ordered_figs)
for i = 1:length(ordered_figs)
    fig = ordered_figs(i);
    figName = fig.Name;
    axs = findobj(fig,'type','axes');
    
    for j = 1:length(axs)
        set(axs(j),'XAxis', matlab.graphics.axis.decorator.NumericRuler); % remove categorital x ticks
        set(axs(j),'XLim',[-inf inf]);
        
        % Extract matrix of events trials x event type
        ch = get(axs(j),'tag');
        evts = fieldnames(edataForZooFiles.(figName).(ch).event);
        evt_val_stk = [];
        xpos = {};
        count = 1;
        for e = 1:length(evts)
            evt = evts{e};
            if ~isempty(ch) && isempty(strfind(ch,' '))
                if(combine)
                    edata = [];
                    for k = 1:length(ordered_figs)
                        edata = cat(k, edata, edataForZooFiles.(figName).(ch).event.(evt));
                        xpos{count} = [ordered_figs(k).Name, ' ', evts{e}];
                        count = count + 1;
                    end
                else
                    edata = edataForZooFiles.(figName).(ch).event.(evt);
                    xpos{count} = evts{e};
                    count = count + 1;
                end
                evt_val_stk = [evt_val_stk edata];
            end
        end
        
        % make x categorical
        X = categorical(xpos);
        X = reordercats(X, xpos);
        
        % plot event matrices
        axes(axs(j))
        if(combine)
            set(axs(j),'YLim',[-inf inf])
        end
        
        if contains(chartType, 'box whisker')
            set(axs(j), 'XTick', 1:1:length(xpos))
            bplot(evt_val_stk, 'color',color);  % If ydata is a matrix, there is one box per column
            set(axs(j), 'XTickLabel', xpos, 'XTickLabelRotation', 45)
            
        elseif contains(chartType, 'violin')
            hold on
            set(axs(j), 'XTick', 1:1:length(xpos))
            bhnd = violin(evt_val_stk, 'facecolor', color);
            set(axs(j), 'XTickLabel', xpos, 'XTickLabelRotation', 45)
            hold off
            
            % generic handles for now
            for b = 1:length(bhnd)
                set(bhnd(b), 'Tag', 'BarChart')
            end
            
        elseif contains(chartType, 'bar')
            
            meanVal = mean(evt_val_stk, 1);
            stdVal = std(evt_val_stk, 1);
            
            if contains(chartType, '(CI)')
                stdVal = 1.96*stdVal./sqrt(length(evt_val_stk));
            end
            
            if min(meanVal) < 0
                set(axs(j),'YLim',[max(meanVal)-100-(1.2*max(stdVal)) 0]);
            else
                set(axs(j),'YLim',[0 max(meanVal)+100+(1.2*max(stdVal))]);
            end
            hold on
            
            % plot bar graph
            bhnd = bar(X, meanVal, 'FaceColor', color);
            % generic handles for now
            set(bhnd, 'Tag', 'BarChart')
            
            % Add corresponding error bars
            er = errorbar(X, meanVal, stdVal, '.');
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off
        else
            error(['unknown chart type ', chartType])
        end
    end
end
