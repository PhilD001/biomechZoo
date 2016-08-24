function colordobj(hnd);

clr = finddobj('colorpallete');
if isempty(clr)
    return
end
clr = get(clr,'backgroundcolor');

switch get(hnd,'type');
    case 'patch'
        set(hnd,'facecolor',clr);
end