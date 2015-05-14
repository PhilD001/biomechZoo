function switchmode(varargin);
fig = finddobj('figure');
mod = findobj(fig,'style','togglebutton','callback','director(''units'')');
sel = findobj(mod,'value',1);
set(mod,'value',0,'backgroundcolor',[.8 .8 .8]);
if nargin == 0
    switch get(sel,'tag')
        case 'displacement'
            set(findobj(mod,'tag','angle'),'value',1,'backgroundcolor',[.9 .9 .9]);
        case 'angle'
            set(findobj(mod,'tag','volume'),'value',1,'backgroundcolor',[.9 .9 .9]);
        case 'volume'
            set(findobj(mod,'tag','displacement'),'value',1,'backgroundcolor',[.9 .9 .9]);
    end
else
    switch get(sel,'tag')
        case 'displacement'
            set(findobj(mod,'tag','volume'),'value',1,'backgroundcolor',[.9 .9 .9]);
        case 'angle'
            set(findobj(mod,'tag','displacement'),'value',1,'backgroundcolor',[.9 .9 .9]);
        case 'volume'
            set(findobj(mod,'tag','angle'),'value',1,'backgroundcolor',[.9 .9 .9]);
    end
end