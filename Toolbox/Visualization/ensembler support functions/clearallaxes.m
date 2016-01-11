
function clearallaxes

ax = findobj('type','axes');

for i = 1:length(ax)
    
    ln = findobj(ax(i),'type','line');
    tag = get(ax(i),'Tag');
    if isempty(ln)  && ~isin(tag,'Colorbar')
        delete(ax(i))
    end
    
    
end