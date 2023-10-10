function combineData()      
figs = findobj('type','figure');
name = ' ';
for i = 1:length(figs)
    n = get(figs(i),'name');
    if i == 1
        name = n;
    else
        name = [name ' and ',n];
        set(figs(i),'visible','off')
    end
end
set(gcf,'name',name)