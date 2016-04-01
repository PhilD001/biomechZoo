function buttondown

% BUTTONDOWN controls behavior of button clicks in ensembler
%

% Created by JJ Loh 2006
%
% Updated bu Philippe C. Dixon March 2016
% - improved behavior for ensembled lines
% - improved contrast of selected line

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
            
            if isempty(strfind(get(gcbo,'userdata'),'average_'))
                set(findobj('string','\diamondsuit'),'color',[1 0 0]); % set back to red
                

                lns = findobj(gca,'type','line','linestyle','-');
                lns = setdiff(lns,gcbo);
                
                if isempty(lns)
                    return
                end
                ln = lns(1);
                normalWidth = get(ln,'LineWidth');
                normalColor = get(ln,'Color');
                normalStyle = get(ln,'LineStyle');
                
                % reset all lines
                set(findobj('type','line','ButtonDownFcn','ensembler(''buttondown'')'),...
                            'color',normalColor,'LineWidth',normalWidth,...
                            'LineStyle',normalStyle); % set back to oroginal
                %set(findobj('type','line','MarkerSize',6),'color',[0 0 0])
                ax = findobj(gcf,'type','axes');
                for i = 1:length(ax)
                    
                    if ~isin( get(ax(i),'tag'),'legend')
                        set(findobj(ax(i),'type','hggroup'),'LineStyle','-')
                    end
                    
                end
                
                if ~isin(get(hnd,'type'),'hggroup')
                    set(gcbo,'color',[0 0 .98],'LineWidth',2,'LineStyle','--')
                else
                    set(gcbo,'LineStyle',':')
                end
                
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



