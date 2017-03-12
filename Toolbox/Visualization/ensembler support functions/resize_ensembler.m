function resize_ensembler(ax)

% RESIZE_ENSEMBLER(AX) automaticall resizes bar and line graph axes in ensembler figures
%
% ARGUMENTS
%  ax  ...   axis handle. Used for bar graphs. Default none

% Revision history
%
% Updated by Philippe C. Dixon Jan 2017
% - improved algorithm for resizing of bar graphs
% - cleaned up function by adding subfunction resize_bar and resize_line
% - Not tested on < r2014b
% - bug fix for -ive bar graph resize
%
% Updated by Philippe C. Dixon Feb 2017
% - further improvements to resizing algorithm


% Set defaults
%
if nargin==1
    resize_bar(ax)                                      % short cut used by makebar
    return
else
    ax = findobj('type','axes');                        % regular run by GUI menu
    legend = findobj('type','axes','tag','legend');
    ax = setdiff(ax,legend);
end

extra = 0.05;                                           % extra space multiplier yaxis


% Run resize algorithm
%
for a = 1:length(ax)
    xlabel = get(ax(a),'xlabel');
    if isin(xlabel,'bar graph') || isempty(get(ax(a),'Xtick'))
        resize_bar(ax(a))
    else
        resize_line(ax(a),extra)
    end
end


function resize_line(ax,extra)

ln  = findobj(ax,'type','line');   % find all lines

if ~isempty(ln)
    pch = findobj(ax,'type','patch','visible','on');
    
    max_ystk = [];
    min_ystk = [];
    max_xstk = [];
    min_xstk = [];
    max_sstk = [];
    min_sstk = [];
    
    for i = 1:length(ln)
        if ~isempty(get(ln(i),'UserData'))
            y_max = max(get(ln(i),'ydata'));
            y_min = min(get(ln(i),'ydata'));
            
            x_max = max(get(ln(i),'xdata')); % all x mins should be the same
            x_min = min(get(ln(i),'xdata')); % all x max should be the same
            
            max_xstk = [max_xstk x_max]; %#ok<*AGROW>
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
    
    if dymin <0
        dymin = dymin + dymin*extra;
    else
         dymin = dymin - dymin*extra;
    end
    
    if dymax < 0
       dymax = dymax - dymax*extra;
    else
       dymax = dymax + dymax*extra;
    end
    
    if ~isempty(dymin)
        set(ax,'Ylim',[dymin dymax]);
        
        if isin(computer,'MAC')
            set(ax,'Xlim', [dxmin-1 dxmax+1] )  % mac fix for std patch overlap with axis
        else
            set(ax,'Xlim', [dxmin dxmax] )
        end
        
    end
end



function resize_bar(ax)

if verLessThan('matlab','8.4.0')
    bars  = findobj(ax,'Tag','ebar');
else
    bars  = findobj(ax,'Type','ErrorBar');
end

disp(['resizing bar graph for: ',get(ax,'Tag')])

max_xstk = NaN*zeros(length(bars),1);
max_ystk = NaN*zeros(length(bars),1);

for j = 1:length(bars)   % extract x-values
    x = get(bars(j),'XData');
    y = get(bars(j),'YData');
    u = get(bars(j),'UData'); % half width of error bar
    
    if y > 0
        y = y+u;
    else
        y = y-u;
    end
    
    max_xstk(j) = x;
    max_ystk(j) = y;
    
end

x_max = max(max_xstk);
x_min = min(max_xstk);

y_max = max(max_ystk);
y_min = min(max_ystk);

% get actual bar width
%
bhnd = findobj(ax,'type','bar');
bar_width = get(bhnd(1),'BarWidth');

% Set new x-limits
%
set(ax,'Xlim', [x_min-bar_width x_max+bar_width] )

% set new y-limits
%
if y_min >= 0
    y_min = 0;
    set(ax,'Ylim', [y_min y_max+0.2*y_max] )
elseif y_max <0
    y_max = 0;
    set(ax,'Ylim', [y_min+0.2*y_min y_max] )
end












