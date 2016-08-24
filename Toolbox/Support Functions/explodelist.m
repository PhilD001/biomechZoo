function nlist = explodelist(list)

% explodes a list of channel names. This is useful to avoid a long list in
% your data files



dims = {'_x','_y','_z'};
nlist = cell(3*length(list),1);
count = 1;
for i = 1:length(list)
    for j = 1:length(dims)
        nlist{count} = [list{i},dims{j}];
        count = count+1;
    end
end

