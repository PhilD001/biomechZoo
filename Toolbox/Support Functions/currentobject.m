function varargout = currentobject(varargin)

co = finddobj('current object','name');
if isempty(co);
    varargout{1} = [];
    varargout{2} = [];
    return
end
ax = finddobj('axes');
hnd = findobj(ax,'tag',co);

if isempty(hnd)
    fig = finddobj('figure');
    hnd = findobj(fig,'tag',co);
end

hi = finddobj('highlight');
if ~isempty(hi);
    hnd = intersect(hnd,hi);
end
if isempty(hnd)
    varargout{1}= 'unknown';
    varargout{2} = [];
    return
end
switch get(hnd(1),'createfcn');
    case 'actor(''createfcn'')'
        tp = 'actor';
    case 'grips(''createfcn'')'
        tp = 'object';
    case 'grips(''graph createfcn'')'
        tp = 'graph';
        hnd = findobj(hnd,'type','axes');
    case 'grips(''internal image createfcn'')'
        tp = 'internal image';
    case 'accessoryfxn(''createfcn'')'
        tp = 'accessory';
    case 'specialobject(''createfcn'')'
        tp = 'special object';
    case 'costume(''createfcn'')'
        tp = 'costume';
    case 'props(''createfcn'')';
        tp = 'props';
    case 'marker(''createfcn'')';
        tp = 'marker';    
    case 'sculpttool(''createfcn'')'
        tp = 'tool';
    case 'props(''prop marker createfcn'')'
        tp = 'prop marker';
    otherwise
        tp = 'unknown';
        hnd = [];
end
if nargin == 0
    varargout{1} = tp;
    varargout{2} = hnd;
else
    varargout{1} = hnd;
end
