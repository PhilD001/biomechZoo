function [f,p] = directory(pth)

t = dir(pth);
f = [];
p = [];
for i = 1:length(t)
    if strcmp(t(i).name,'.')
        continue
    elseif strcmp(t(i).name,'..');
        continue
    elseif t(i).isdir
        p = union(p,{t(i).name});
    else
        f = union(f,{t(i).name});
    end
end