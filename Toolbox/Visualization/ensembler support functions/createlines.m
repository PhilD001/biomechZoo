

function createlines(fig,data,fl)

ch = fieldnames(data);

tch = unique(ch);

if length(tch) ~=length(ch)
    error('you have repeated a channel name')
end

for j = 1:length(ch)
    ax = findobj(fig,'type','axes','tag',ch{j});
    if isempty(ax)
        continue
    end
    
    ydata = data.(ch{j}).line;
  
    if isfield(data.zoosystem, 'VideoSampleNum')
        xdata = makecolumn(data.zoosystem.VideoSampleNum.Indx);
        offset = xdata(1);
        
    else
        xdata = (0:length(data.(ch{j}).line)-1);
        offset = 0;
    end
    
    xdata = makecolumn(xdata);
    
    [~,c] = size(ydata);
    
    if c~=1
        error('data must be n x 1 for graphing, explode first')
    end
    
    ln = line('parent',ax,'ydata',ydata,'xdata',xdata,'userdata',fl,...
        'buttondownfcn',get(ax,'buttondownfcn'));
    
    evt = fieldnames(data.(ch{j}).event);
    for e = 1:length(evt)
        text('parent',ax,'position',[data.(ch{j}).event.(evt{e})(1)+offset data.(ch{j}).event.(evt{e})(2)],...
            'tag',evt{e},'string','\diamondsuit','verticalalignment',...
            'middle','horizontalalignment','center','color',[1 0 0],...
            'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
    end
    
end