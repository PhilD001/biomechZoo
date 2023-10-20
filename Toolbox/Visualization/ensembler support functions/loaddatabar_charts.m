function loaddatabar_charts(fld,figs,settings,combine,chartType,color)

% LOADDATABOX_WHISKER(fld,figs,settings) loads box and whisker data into ensembler
%
%  todo: allow for numerous events to be plotted


fl = engine('path',fld,'extension','zoo');

if isempty(fl)
    ensembler_msgbox(fld,'No zoo files found')
end

if isempty(color)
    color = [0 0 1];
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

% extract struct to create graphs
for i = 1:length(figs)
    fig = figs(i);
    figName = fig.Name;
    axs = findobj(fig,'type','axes');                        % assumes all figures have the same axes
    
    for j = 1:length(axs)    
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
                    for k = 1:length(figs)
                        edata = cat(k, edata, edataForZooFiles.(figName).(ch).event.(evt));
                        xpos{count} = [figs(k).Name, ' ', evts{e}];
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
        

        % plot event matrices
        % set(fig, 'CurrentAxes', axs(j))
        axes(axs(j))
        set(axs(j),'XAxis', matlab.graphics.axis.decorator.NumericRuler); % remove categorital x ticks
        set(axs(j),'XLim',[-inf inf]);
        if(combine)
            set(axs(j),'YLim',[-inf inf])
        end
        
        if strcmp(chartType, 'whisker')
           bplot(evt_val_stk,'color',color);  % If ydata is a matrix, there is one box per column
          
            
        elseif strcmp(chartType, 'violin')
            hold on
            violin(evt_val_stk,'facecolor', color);
            
            hold off
            
        elseif contains(chartType, 'bar')
            
            meanVal = mean(evt_val_stk, 1);
            stdVal = std(evt_val_stk, 1);
                        
            if strcmp(chartType, 'bar(CI)')
                stdVal = 1.96*stdVal./sqrt(length(evt_val_stk));
            end
                        
            if min(meanVal) < 0
                set(axs(j),'YLim',[max(meanVal)-100-(1.2*max(stdVal)) 0]);
            else
                set(axs(j),'YLim',[0 max(meanVal)+100+(1.2*max(stdVal))]);
            end
            hold on
          
            % plot bar graph
            X = categorical(xpos);
            X = reordercats(X, xpos);
            bar(X, meanVal, 'FaceColor', color);
       
            % Add corresponding error bars
            er = errorbar(X, meanVal, stdVal, '.');
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            hold off
        else
            error(['unknown chart type', chartType])
        end
    end
end
