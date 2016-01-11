function clear999outliers
a = findobj('type','line');
b = findobj('String','\diamondsuit');

for i = 1:length(a)
    y = get(a(i),'YData');
    
    if mean(y) ==999
        delete(a(i))
    end
    
end

for i = 1:length(b)
    e = get(b(i),'Position');
    
    if e(2)==999
        delete(b(i))
    end
    
end