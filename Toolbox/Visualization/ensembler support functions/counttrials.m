
function counttrials


figs = findobj('type','figure');

for i = 1:length(figs)
    
    ax =  findobj(figs(i),'type','axes');
    
    pt = get(ax(1),'parent');       %parent of axis is figure
    nm = get(pt,'name');
    
    ln = findobj(ax(1),'type','line');
    disp(['for ',nm,' n = ',num2str(length(ln))])
    
    
    
end