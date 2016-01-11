
function combine
%
% main function for combining ensembled graphs for different condition windows

ax = findensobj('axes',gcf);
for i = 1:length(ax)
    tg = get(ax(i),'tag');
    axs = setdiff(findobj('type','axes','tag',tg),ax(i));
    ln = findobj(axs,'type','line');
    pch = findobj(axs,'type','patch');
    %     txt = findobj(axs,'string','\diamondsuit');
    txt = findobj(axs,'type','text');
    set(ln,'parent',ax(i));
    set(pch,'parent',ax(i));
    set(txt,'parent',ax(i));
    bottomhnd(pch);
end