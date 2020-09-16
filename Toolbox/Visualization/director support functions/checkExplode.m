function [explode,ch_exp] = checkExplode(data)

explode = false;
if isfield(data.zoosystem, 'Processing')
    process = data.zoosystem.Processing;
    for i = 1:length(process)
        if strfind(process{i},'explode')
            explode = true;
        end
    end
else
    ch = fieldnames(data);
    loop = true;
    i = 1;
    while loop
        if strfind(ch{i}, '_x')
            explode = true;
            loop = false;
        elseif i == length(ch)
            loop = false;
        end
        
        i = i + 1;
        
    end
          
end

if explode
    ch = data.zoosystem.Video.Channels;
    ch_exp = cell(size(ch));
    for i = 1:length(ch)
        
        if isempty(strfind(ch{i},'Angle'))
            if ~isempty(strfind(ch{i},'_x'))
                temp = ch{i};
                ch_exp{i} = temp(1:end-2);
            end
        end
    end
    
    ch_exp(cellfun(@isempty,ch_exp)) = [];
    
else
    ch_exp = [];
end
