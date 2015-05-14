function data = renamech(data,och,nch)



for i = 1:length(och)

    if isempty(findfield(data,och{i}))

        disp(['channel: ',och{i}, ' does not exist'])

    else

        data.(nch{i}).line = data.(och{i}).line;
        data.(nch{i}).event = data.(och{i}).event;

        data = rmfield(data,och{i});

    end
end