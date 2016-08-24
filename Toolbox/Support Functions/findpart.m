function hnd = findpart(ac,part)
ax = finddobj('actor');
if strcmp(ac,'all')
    switch part
        case 'head'
            hnd = findobj(finddobj('actor'),'deletefcn','actor(''deletefcn'')');
        otherwise
            hnd = findobj(ax,'userdata',part);
    end
else
    switch part
        case 'head'
            hnd = findobj(ax,'tag',ac,'deletefcn','actor(''deletefcn'')');
        otherwise
            hnd = findobj(ax,'tag',ac,'userdata',part);
    end
end
