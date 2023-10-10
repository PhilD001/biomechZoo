function combineData()      
figs = findobj('type','figure');
name = ' ';
for i = 1:length(figs)
    n = get(figs(i),'name');
    figObj = findobj(get(figs(i), 'Children'), 'Type', 'uimenu');
    if ~isempty(figObj)
        mainObj = figs(i);
    end
    if i == 1
        name = n;
    else
        name = [name ' and ',n];
    end
end

set(mainObj,'name',name)

for i = 1:length(figs)
    if mainObj ~= figs(i)
        set(figs(i),'visible','off')
    end
end        
