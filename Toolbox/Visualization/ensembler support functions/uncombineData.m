function uncombineData()      
figs = findobj('type','figure');
for i = 1:length(figs)
    n = get(figs(i),'name');
    if i == 1
        name = extractBefore(n, ' and');
        if isempty(name)
            name = n;
        end
        set(gcf,'name',name)
    else
        set(figs(i),'visible','on')
    end  
end