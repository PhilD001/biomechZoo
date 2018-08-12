function director_unitsload

fl = which('unitmenu.prf');

if isempty(fl)
    error('missing unitmenu.prf file')
end

t = load(fl,'-mat');
[~,all] = finddobj('units');
for i = 1:length(t.unitvar)
    obj = findobj(all,'tag',t.unitvar(i).tag);
    set(obj,'userdata',t.unitvar(i).userdata,'string',t.unitvar(i).string);
end