function ort = transform_ort(ort,option)

%option 


coeff = option;
option = abs(option);

for i = 1:length(ort)
    ort{i} = ort{i}(option,:);
    for j = 1:3
        if coeff(j) < 0
            ort{i}(j,:) = ort{i}(j,:)*-1;
        end
    end
end
