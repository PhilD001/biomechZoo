function uncombineData()

    
% This function is used to uncombine the axes
figs = findobj('type','figure');
axesNames = [];
otherAxes = [];
for i = 1:length(figs)
    n = get(figs(i),'name');
    axesNamesForCurrentFig = [];
    figObj = findobj(get(figs(i), 'Children'), 'Type', 'uimenu');
    if ~isempty(figObj)
        mainObj = figs(i);
    end
    if contains(n,'and')
        removeAndStr = replace(n, ' and ', ' ');
        axesNamesForCurrentFig = split(removeAndStr);
    end
    if length(axesNamesForCurrentFig) > 1
        axesNames = axesNamesForCurrentFig;
    else
        set(figs(i),'visible','on')
        otherAxes = cat(1, otherAxes, {n});
    end  
end

for i = 1:length(otherAxes)
    axesNames(strcmp(axesNames,otherAxes(i))) = [];
end

if length(axesNames) == 1
    set(mainObj,'name',string(axesNames(1)))
end

% remove objects from main figure that belong to other figures
for i = 1:length(otherAxes)
    objs = findobj(mainObj, 'tag', otherAxes{i});
    delete(objs)
end