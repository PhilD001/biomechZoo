
function clear999

ax = findensobj('axes');

for i = 1:length(ax)
    ln = findobj(ax(i),'type','line');
    evt = findobj(ax(i),'string','\diamondsuit');
    for k = 1:length(evt)
        
        P = get(evt(k),'Position');
        if P(2) == 999
            delete(evt(k))
        end
    end
    
    for j = 1:length(ln)
        yd = get(ln(j),'ydata');
        if mean(yd)==999
            delete(ln(j))
        end
    end
end

disp('removed 999 outliers')
