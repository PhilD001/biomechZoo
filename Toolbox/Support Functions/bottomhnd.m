function bottomhnd(hnd)
%   BOTTOMHND move a handle to the bottom of the list among children
%   The object is brought to the back  
if isempty(hnd)
    return
end
for i = length(hnd);
    pt = get(hnd(i),'parent');
    ch = get(pt,'children');
    cindx = find(ch~=hnd(i));
    ch =[ch(cindx);hnd(i)];
    set(pt,'children',ch);
end