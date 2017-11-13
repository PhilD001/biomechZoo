function buttondown(settings)

% BUTTONDOWN(settings) controls behavior of button clicks in ensembler
%

% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon March 2016
% - improved behavior for ensembled lines
% - improved contrast of selected line
%
% Updated  by Philippe C. Dixon October 2016
% - use of new function concatEnsPrompt to shorten long ensembler prompts
%
% Updated by Philippe C. Dixon May 2017
% - current axis is highlighted see ensembler_axis_highlight
%
% Updated by Philippe C. Dixon Aug 2017
% - Fixed bug with line width after event buttondown
% - Improved sizing of ensembler prompt at top of figure
% - Removed hard coding for some line styles and colors

hnd = gcbo;
stype = get(gcf,'selectiontype');

switch stype
    
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
            temp = get(gcbo,'userdata');
            
            fsize = get(gcf,'position');
            fsize = fsize(3);
            
            while true
                set(txt,'string',temp);
                tsize = get(txt,'extent');
                
                if isempty(tsize)
                    break
                end
                tsize = tsize(3);
                
                if tsize > fsize
                    temp = concatPrompt(temp);
                else
                    break
                end
            end
            
            
            if isempty(strfind(get(gcbo,'userdata'),'average_'))
                set(findobj('string',settings.string),'color',settings.color); % set back
                
                lns = findobj(gca,'type','line','linestyle',settings.regularLineStyle);
                
                if lns~=gcbo
                    lns = setdiff(lns,gcbo);
                end
                
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
                ax = findobj(gcf,'type','axes');
                for i = 1:length(ax)
                    
                    if ~isin( get(ax(i),'tag'),'legend')
                        set(findobj(ax(i),'type','hggroup'),'LineStyle',settings.regularLineStyle)
                    end
                    
                end
                
                if ~isin(get(hnd,'type'),'hggroup')
                    set(gcbo,'color',settings.selectedLineColor ,'LineWidth',settings.selectedLineWidth,...
                        'LineStyle',settings.selectedLineStyle)
                else
                    set(gcbo,'LineStyle',settings.selectedLineStyle)
                end
                
            elseif ~isempty(strfind(get(gcbo,'userdata'),'average_'))
                %set(findobj('string',settings.string),'color',settings.color); % set back
                
                lns = findobj(gca,'type','line','linestyle',settings.ensembledLineStyle,...
                      'LineWidth',settings.ensembledLineWidth);
                
                if lns~=gcbo
                    lns = setdiff(lns,gcbo);
                end
                
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
                    'LineStyle',normalStyle); % set back to original
                % reset all patches
                 set(findobj('type','patch','ButtonDownFcn','ensembler(''buttondown'')'),...
                     'FaceColor',settings.ensembledPatchColor)
                
                ax = findobj(gcf,'type','axes');
                for i = 1:length(ax)
                    
                    if ~isin( get(ax(i),'tag'),'legend')
                        set(findobj(ax(i),'type','hggroup'),'LineStyle',settings.ensembledLineStyle)
                    end
                    
                end
                
                if strcmp(get(hnd,'type'),'line')
                    set(gcbo,'color',settings.selectedLineColor ,'LineWidth',settings.selectedLineWidth,...
                        'LineStyle',settings.selectedLineStyle)
                elseif strcmp(get(hnd,'type'),'patch')
                     set(gcbo,'FaceColor',settings.selectedPatchColor)
                elseif ~isin(get(hnd,'type'),'hggroup')
                    set(gcbo,'color',settings.selectedLineColor ,'LineWidth',settings.selectedLineWidth,...
                        'LineStyle',settings.selectedLineStyle)
                else
                    set(gcbo,'LineStyle',settings.selectedLineStyle)
                end
                
            end
            
        elseif isnumeric(get(gcbo,'userdata'))
            
            if strcmp(get(gcbo,'type'),'axes')
                ensembler_axis_highlight(true)
                return
            end
            
            
            if strcmp(get(gcbo,'type'),'patch')
                return
            end
            
            txt = findensobj('prompt',gcf);
            set(txt,'string',get(gcbo,'tag'));
            set(findobj('string',settings.string),'color',settings.color);
            set(findobj('string',settings.ensstring),'color',settings.color);
            set(findobj('type','line'),'color',settings.regularLineColor); % set back to black
            set(gcbo,'color',settings.selectedLineColor)
            
        elseif strcmp(get(gcbo,'string'),settings.string) % this is an event
            
            % set up msg
            txt = findensobj('prompt',gcf);
            evt = get(gcbo,'tag');                       % event tag
            trial = get(get(gcbo,'UserData'),'UserData'); % trial tag
            trial = concatEnsPrompt(trial);
            msg = [trial,': ', evt];
            set(txt,'string',msg);
            
            % change color of current event (red to blue)
            %
            set(findobj('string',settings.string ),'color',settings.color); % all others red
            set(gcbo,'color',settings.selectedLineColor)                          % set current blue
            
            % set all lines back to normal
            %
            set(findobj('type','line','ButtonDownFcn','ensembler(''buttondown'')'),...
                'color',settings.regularLineColor,'LineStyle','-','LineWidth',0.5); % set back to oroginal
            
            
        end
end



