
function [ch,ev] = listchannel_event(fl)
t = load(fl,'-mat');
data = t.data;
ev = {};
ch = fieldnames(data);
ch = setdiff(ch,{'zoosystem'});
for i = 1:length(ch)
    vl = getfield(data,ch{i});
    if isstruct(vl)
        if isstruct(vl.event);
            ev = union(ev,fieldnames(vl.event));
        end
    end
end