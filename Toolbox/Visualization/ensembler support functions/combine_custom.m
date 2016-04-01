function combine_custom
%
% used to combine different axes with full freedom

fig = findobj('type','figure');

for j = 1:length(fig)
    
    ax = findensobj('axes',fig(j));
    tg = cell(size(ax));
    
    for i = 1:length(ax)
        tg{i} = get(ax(i),'tag');
    end
    
    if j==1
        a = associatedlg(tg,tg);
    end
    
    [r,~] = size(a);
    
    if r==1
        axh = findobj(fig(j),'type','axes','tag',a{1,1});
        axm = findobj(fig(j),'type','axes','tag',a{1,2});
        
        ln = findobj(axm,'type','line');
        pch = findobj(axm,'type','patch');
        txt = findobj(axm,'string','\diamondsuit');  % line events
        mtxt = findobj(axm,'string','\bullet');   % mean event
        set(ln,'parent',axh);
        set(pch,'parent',axh);
        set(txt,'parent',axh);
        set(mtxt,'parent',axh);
        bottomhnd(pch);
        
    else
        
        for i = 1:length(a)
            
            axh = findobj(fig(j),'type','axes','tag',a{i,1});
            axm = findobj(fig(j),'type','axes','tag',a{i,2});
            
            ln = findobj(axm,'type','line');
            pch = findobj(axm,'type','patch');
            txt = findobj(axm,'string','\diamondsuit');  % line events
            mtxt = findobj(axm,'string','\bullet');   % mean event
            set(ln,'parent',axh);
            set(pch,'parent',axh);
            set(txt,'parent',axh);
            set(mtxt,'parent',axh);
            bottomhnd(pch);
            
        end
        
    end
    
    axs = setdiff(findobj('type','axes','tag',tg),ax(i));
    ln = findobj(axs,'type','line');
    pch = findobj(axs,'type','patch');
    txt = findobj(axs,'string','\diamondsuit');
    set(ln,'parent',ax(i));
    set(pch,'parent',ax(i));
    set(txt,'parent',ax(i));
    bottomhnd(pch);
    
    
end

