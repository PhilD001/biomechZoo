function r = allfieldnames(st);

r = [];
if ~isstruct(st)
    return;
else
    fld = fieldnames(st);
    for i = 1:length(fld)
        r = union(r,allfieldnames(getfield(st,fld{i})));
    end
    r = union(r,fld);
end
    