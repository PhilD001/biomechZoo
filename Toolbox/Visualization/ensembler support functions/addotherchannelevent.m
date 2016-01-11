function addotherchannelevent(fld)


fl = engine('path',fld,'extension','zoo');

data = load(fl{1},'-mat');
data = data.data;
ch = setdiff(fieldnames(data),'zoosystem');



evts = {};
for i = 1:length(ch)
    evt = fieldnames(data.(ch{i}).event);
    evts = [evts; evt];
end

evts = unique(evts);
indx = listdlg('promptstring','choose your event','liststring',evts);
evts =evts(indx);


figs = findobj('type','figure');

for i =1:length(figs)
    
    ax = findobj(figs(i),'type','axes');
    
    for j =1:length(ax)
        
        %         ch = get(get(ax(j),'Title'),'String');
        lines = findobj(ax(j),'type','line');
        
        for k = 1:length(lines)
            
            file = get(lines(k),'UserData');
            ln = get(lines(k),'YData');
            
            for m = 1:length(evts)
                
                data = load(file,'-mat');
                data = data.data;
                
                if isfield(data.zoosystem,'VideoSampleNum')
                    offset = abs(data.zoosystem.VideoSampleNum.Indx(1));
                else
                    offset = 0;
                end
                
                
                indx = findfield(data,evts{m});
                xpos = indx(1);
                ypos = ln(xpos);
                
                text('parent',ax(j),'position',[xpos-offset ypos ],...
                    'tag',evts{m},'string','\diamondsuit','verticalalignment',...
                    'middle','horizontalalignment','center','color',[1 0 0],...
                    'buttondownfcn',get(ax(j),'buttondownfcn'),'userdata',evts{m});
                
            end
            
        end
        
    end
    
end