function fade(pch)

fc = get(pch,'faces');
if ~iscell(fc)    
    fc = {fc};
end
for i = 1:length(fc)
   remain{i} = (1:length(fc{i}(:,1)));
   shown{i} = [];
end
while 1
    if isdone(remain)
        break
    end
    for i = 1:length(remain)
        r = remain{i};
        s = shown{i};
        if isempty(r)
            continue
        end
        num = ceil(rand*length(r));
        
        num = max(min(num,length(r)),1);
        num = r(num);
        r = setdiff(r,num);
        s = union(s,num);
        remain{i} = r;
        shown{i} = s;
        set(pch(i),'faces',fc{i}(s,:));
    end            
    pause(0)
end

function b = isdone(rm)

b = 1;
for i = 1:length(rm)
    if ~isempty(rm{i});
        b = 0;
        return
    end
end