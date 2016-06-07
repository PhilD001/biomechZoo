function clearcolorbars

% updated by Philippe C. Dixon June 2016
% - all color bar graphics removed 

figs = findobj('type','fig');


% clear the comparison bars 
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

% Clear the color bar
if verLessThan('matlab','8.4.0')
    cbar = findobj('type','axes','Tag','Colorbar');
else
    cbar = findobj('type','colorbar');
end
delete(cbar)

ctext = findobj('type','text','Tag','');

for i = 1:length(ctext)
    delete(ctext(i))
end

% clear the text box with the colorbar comps
csbox = findobj('tag','cstatsbox');
delete(csbox);