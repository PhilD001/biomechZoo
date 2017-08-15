function r = getcurrentactor;

[tp,hnd] = currentobject;
if strcmp(tp,'actor');
    r = get(hnd(1),'tag');
else
    hnd = finddobj('actor');
    if isempty(hnd)
        r = ''
    else
        r = get(hnd(1),'tag');
    end
end