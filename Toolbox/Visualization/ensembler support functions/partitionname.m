

function nm = partitionname(str)

indx = strfind(str,' ');

if isempty(indx)
    nm = {str};
    return
end

nm = {str(1:indx(1)-1)};

for i = 1:length(indx)
    if i == length(indx)
        plate = str(indx(end)+1:end);
    else
        plate = str(indx(i)+1:indx(i+1)-1);
    end
    if isempty(plate)
        continue
    end
    nm = [nm;{plate}];
end