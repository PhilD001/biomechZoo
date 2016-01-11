
function buttondown
hnd = gcbo;

switch get(gcf,'selectiontype')
    
    case 'open'
        
        allhnd = findobj('type',get(gcbo,'type'),'tag',get(gcbo,'tag'));
        switch get(hnd,'type')
            case 'axes'
                clr = get(gcbo,'color');
                nclr = colorpallete(clr);
                set(allhnd,'color',nclr);
            case 'line'
                clr = get(gcbo,'color');
                nclr = colorpallete(clr);
                set(allhnd,'color',nclr);
            case 'stdev'
                clr = get(gcbo,'facecolor');
                nclr = colorpallete(clr);
                set(allhnd,'facecolor',nclr);
        end
        
    case 'normal'
        
        if ischar(get(gcbo,'userdata'))
            txt = findensobj('prompt',gcf);
            set(txt,'string',get(gcbo,'userdata'));
            set(findobj('string','\diamondsuit'),'color',[1 0 0]); % set back to red
            set(findobj('type','line'),'color',[0 0 0]); % set back to red
            
            ax = findobj(gcf,'type','axes');
            for i = 1:length(ax)
                
                if ~isin( get(ax(i),'tag'),'legend')  
                    set(findobj(ax(i),'type','hggroup'),'LineStyle','-')
                end
                
            end
            
            if ~isin(get(hnd,'type'),'hggroup')
                set(gcbo,'color',[0 0 .98])
            else
                set(gcbo,'LineStyle',':')
            end
            
        elseif isnumeric(get(gcbo,'userdata'));
            
            if strcmp(get(gcbo,'type'),'patch') || strcmp(get(gcbo,'type'),'axes')
                return
            end
            
            txt = findensobj('prompt',gcf);
            set(txt,'string',get(gcbo,'tag'));
            %  set(findensobj('highlight'),'color',[0 0 0]);
            
            set(findobj('string','\bullet'),'color',[1 0 0]);
            set(findobj('string','\diamondsuit'),'color',[1 0 0]);
            set(findobj('type','line'),'color',[0 0 0]); % set back to red
            
            set(gcbo,'color',[0 0 .98])
            %   set(findobj('userdata',gcbo),'color',[0 0 .98]);
        end
end



