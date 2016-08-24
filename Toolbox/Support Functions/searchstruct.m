function r = searchstruct(st,kw)

if isempty(kw)
    r = [];
    return
end
r = searchengine(st,kw);


if length(r) == 1
    r = r{1};
end

function r = searchengine(st,kw)
r = [];
if isempty(kw)
    r = {st};
    return
elseif ~isstruct(st)
    return
end

fld = fieldnames(st);

for i = 1:length(fld);
    vl = getfield(st,fld{i});
    if ~isempty(intersect(fld{i},kw));
        plate = searchengine(vl,setdiff(kw,fld(i)));
    else
        plate = searchengine(vl,kw);
    end
    if ~isempty(plate)
        r = [r;plate];
        break
    end
end
    