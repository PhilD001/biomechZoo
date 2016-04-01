function combine_all
%
% - used to combine ensembled graphs of all subfigures into a same main figure

prmt = findobj('Tag','prompt');

if ~isempty(prmt)
    set(prmt,'string','')
end

figs = findobj('type','figure');

for j = 1:length(figs)
    
    name = get(figs(j),'name');
    
    ax = findensobj('axes',figs(j));
    ca=ax(1);     % goes into first figure
    
    for i = 2:length(ax)
        ln = findobj(ax(i),'type','line');
        pch = findobj(ax(i),'type','patch');
        txt = findobj(ax(i),'string','\diamondsuit');
        mtxt = findobj(ax(i),'string','\bullet');
        set(ln,'parent',ca);
        set(ln,'tag',get(ax(i),'tag'))
        set(pch,'parent',ca);
        set(txt,'parent',ca);
        set(mtxt,'parent',ca);
        bottomhnd(pch)
    end
    
    set(figs(j),'name',[name,'_combined'])
    
end




