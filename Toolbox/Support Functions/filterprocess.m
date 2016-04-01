function data = filterprocess(data,chfilt,filt)

% data = FILTERPROCESS(data,chfilt,filt) standalone function for bmech_filter

% Find channels and filter
%
if strcmp(chfilt,'all')==1
    ch = fieldnames(data);
    ch = setdiff(ch,{'zoosystem'});
else    
    ch = chfilt;
end

% Error checking
%
if ~iscell(ch)
    ch = {ch};
end



for j = 1:length(ch)

    if isfield(data,ch{j})  
        ach = data.zoosystem.Analog.Channels;
        vch = data.zoosystem.Video.Channels;
        
        if ismember(ch{j},ach)
            fsamp = data.zoosystem.Analog.Freq;
        elseif ismember(ch{j},vch)
            fsamp = data.zoosystem.Video.Freq;
        else
            error('channel not in zoosystem list')
        end
       
        data.(ch{j}).line = filterline(data.(ch{j}).line,fsamp,filt);
    
    else
        disp(['ch ',ch{j},' does not exist, not filtering'])
    end
end

