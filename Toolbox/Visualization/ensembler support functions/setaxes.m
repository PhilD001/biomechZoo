function setaxes(prop)

ax = findensobj('axes',gcf);

switch prop
    
    case 'ylimmode'
        str2 = {'manual','auto'};
        
    case 'ylim'
        ylim = get(ax,'ylim');
        if ~iscell(ylim)
            ylim = {ylim};
        end
        
        m = cell2mat(ylim);
        ylim = [ylim;{[min(min(m)),max(max(m))]}];
        for i = 1:length(ylim)
            str2{i} = num2str(ylim{i});
        end
        
    case 'xlim'
        xlim = get(ax,'xlim');
        if ~iscell(xlim)
            xlim = {xlim};
        end
        
        m = cell2mat(xlim);
        xlim = [xlim;{[min(min(m)),max(max(m))]}];
        for i = 1:length(xlim)
            str2{i} = num2str(xlim{i});
        end
        
    case 'xlimmode'
        str2 = {'manual','auto'};
    case 'xtickmode'
        str2 = {'none','auto'};
    case 'ytickmode'
        str2 = {'none','auto'};
end

tg = get(ax,'tag');
if ~iscell(tg)
    tg = {tg};
end
a = associatedlg(tg,str2);

for i = 1:length(a(:,1))
    if strcmp(prop,'xtickmode') && strcmp('none',a{i,2})
        aprop = 'xtick';
        aval = [];
    elseif strcmp(prop,'ytickmode') && strcmp('none',a{i,2})
        aprop = 'ytick';
        aval = [];
    elseif strcmp(prop,'ylim') || strcmp(prop,'xlim')
        aprop = prop;
        aval = str2double(a{i,2});
    else
        aprop = prop;
        aval = a{i,2};
    end
    ax = findobj('type','axes','tag',a{i,1});
    set(ax,aprop,aval);
end
