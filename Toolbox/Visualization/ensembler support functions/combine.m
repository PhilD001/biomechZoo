function combine
%
% COMBINE is main function for combining ensembled graphs for different condition windows
% The following 'objects' will be combined: 
% - average lines
% - variability clouds
% - event error bars


% Updated by Philippe C. Dixon March 2016
% - compatible with r2014b + 
%
% Updated by Philippe C. Dixon July 2016
% - Fixed bug with ordering of ensemble elements


ax = findensobj('axes',gcf);

for i = 1:length(ax)
    tg = get(ax(i),'tag');
    
    axs = setdiff(findobj('type','axes','tag',tg),ax(i),'stable');
    
    ln    = findobj(axs,'type','line','LineWidth',1);          % average lines
    pch   = findobj(axs,'type','patch');                       % variability clouds
    ebarh = findobj(axs,'LineWidth',1.1);                      % error bar vertical
    ebarv = findobj(axs,'LineWidth',1.12);                     % error bar horizontal
    evt   = findobj(axs,'type','text');                        % event mark
    
    set(ln,'parent',ax(i));
    set(pch,'parent',ax(i));
    set(ebarh,'parent',ax(i));
    set(ebarv,'parent',ax(i));
    set(evt,'parent',ax(i));
    bottomhnd(pch);
end

% Update figure names
%
figs = findobj('type','figure');
name = ' ';
for i = 1:length(figs)
    n = get(figs(i),'name');
    if i == 1
        name = n;
    else
        name = [name ' and ',n];
        delete(figs(i))
    end
    
    
end

set(gcf,'name',name)



