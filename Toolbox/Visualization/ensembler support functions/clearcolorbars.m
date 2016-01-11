function clearcolorbars


figs = findobj('type','fig');

for j = 1:length(figs)
    
    sfigs = findobj(figs(j),'type','Patch','tag','');
    back = findobj(figs(j),'type','axes','Tag','colormap');
    
    for i = 1:length(sfigs)
        delete(sfigs(i))
    end
    
    for i = 1:length(back)
        delete(back(i))
    end
    
end

cbar = findobj('type','axes','Tag','Colorbar');
delete(cbar)

ctext = findobj('type','text','Tag','');

for i = 1:length(ctext)
    delete(ctext(i))
end
