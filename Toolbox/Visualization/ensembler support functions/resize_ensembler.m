function resize_ensembler

% resizes axes in enselbler figure


extra = 1.05; % extra space multiplier yaxis

ax = findobj('type','axes');
legend = findobj('type','axes','tag','legend');
ax = setdiff(ax,legend);

for a = 1:length(ax)
    
    xlabel = get(get(gca,'XLabel'),'String');
    
    max_ystk = [];
    min_ystk = [];
    
    max_xstk = [];
    min_xstk = [];
    
    max_sstk = [];
    min_sstk = [];
    
    
    if isin(xlabel,'bar graph') || isempty(get(gca,'Xtick'))
        
        bars  = findobj('Tag','ebar');        
        disp('resizing for bar graphs')
        
        for j = 1:length(bars)   % extract x-values
            
            x = get(bars(j),'XData');
            y = get(bars(j),'YData');
            u = get(bars(j),'UData'); % half width of error bar
            
            x = x(:,1);         
            y = y(:,1);
            
            if y > 0 
                y = y+u;
            else
                y = y-u;
            end
            
            x_max = max(x);
            x_min = min(x);
            
            y_max = max(y);
            y_min = min(y);
            
            max_xstk = [max_xstk x_max];
            max_ystk = [max_ystk y_max];
            
        end
        
        x_max = max(max_xstk);
        x_min = min(max_xstk);
        
        y_max = max(max_ystk);
        y_min = min(max_ystk);
        
        if verLessThan('matlab','8.4.0')
            set(gca,'Xlim', [x_min-0.2*x_min x_max+0.2*x_max] )
        else
            set(gca,'Xlim', [x_min-0.7*x_min x_max+0.3*x_max] )
        end
        
        % set new limits
        %

        if y_min > 0
            y_min = 0;
            set(gca,'Ylim', [y_min y_max+0.2*y_max] )
                        
        elseif y_max <0
            y_max = 0;
            set(gca,'Ylim', [y_min-0.2*y_min y_max] )
        end
        
       

    else    % ensembled lines
            
        ln = findobj(ax(a),'type','line');   % find all lines
        
        if ~isempty(ln)
            pch = findobj(ax(a),'type','patch','visible','on');
            
            for i = 1:length(ln)
                
                if ~isempty(get(ln(i),'UserData'))
                    
                    y_max = max(get(ln(i),'ydata'));
                    y_min = min(get(ln(i),'ydata'));
                    
                    x_max = max(get(ln(i),'xdata')); % all x mins should be the same
                    x_min = min(get(ln(i),'xdata')); % all x max should be the same
                                        
                    max_xstk = [max_xstk x_max];
                    min_xstk = [min_xstk x_min];
                    
                    max_ystk = [max_ystk y_max];
                    min_ystk = [min_ystk y_min];
                end
            end
            
            
            for j = 1:length(pch)
                p_max = max(get(pch(j),'YData'));
                p_min = min(get(pch(j),'YData'));
                
                max_sstk = [max_sstk p_max];
                min_sstk = [min_sstk p_min];
            end
            
            
            dymax = max([max_ystk max_sstk]);
            dymin = min([min_ystk min_sstk]);
            
            dxmax = max(max_xstk);
            dxmin = min(min_xstk);
        
            if ~isempty(dymin)
                set(ax(a),'Ylim',[extra*dymin extra*dymax]);
                   
                if isin(computer,'MAC')
                    set(ax(a),'Xlim', [dxmin-1 dxmax+1] )  % mac fix for std patch overlap with axis
                else
                    set(ax(a),'Xlim', [dxmin dxmax] ) 
                end
                  
            end 
        end   
    end
end













