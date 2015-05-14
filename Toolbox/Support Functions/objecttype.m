function tp = objecttype(hnd);

switch get(hnd,'createfcn');
    case 'actor(''createfcn'')'
        tp = 'actor';
    case 'grips(''data createfcn'')'
        tp = 'graph';
    case 'grips(''internal image createfcn'')'
        tp = 'internal image';
    case 'accessoryfxn(''createfcn'')'
        tp = 'accessory';
    case 'specialobject(''createfcn'')'
        tp = 'special object';
    case 'costume(''createfcn'')'
        tp = 'costume';
    case 'sculpttool(''createfcn'')'
        tp = 'tool';
    otherwise
        tp = 'unknown';
end
