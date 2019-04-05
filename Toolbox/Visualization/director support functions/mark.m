function mark(action,varargin)

% MARK(action,varargin) is an director function

% Updated by Philippe C. Dixon Nov 2017
% - Made into 'standalone function'

frm = finddobj('frame','number');

switch action
    
    case 'next'
        frm = frm+1;
        direction = 'forward';
        
    case 'prev'
        frm = frm-1;
        direction = 'backward';
        
    case 'goto'
        nfrm = varargin{1};
        if nfrm > frm
            direction = 'forward';
        elseif nfrm < frm
            direction = 'backward';
        else
            direction = 'still';
        end
        frm = nfrm;
        
    case 'refresh'
        direction = 'still';
end

frm = max(frm,1);
set(finddobj('frame'),'string',num2str(frm));
actor('goto',frm);
grips('goto image',frm);
grips('goto data',frm);
grips('goto iimage',frm);
marker('goto',frm);
%specialobject('stick');
%costume('stick');
%accessoryfxn('stick');
grips('random task');
props('goto',frm);
cameraman('goto',frm,direction);

lightman('refresh');

as = findobj('type','axes','tag','data display');

if ~isempty(as)
    graph_mark(frm,varargin)
end

pause(0.000001)  % needed to allow button stop to stop animation




function graph_mark(frm,varargin)

mkr = '^';
c = 'k';
as = get(findobj('type','axes','tag','data display'),'Visible');
ax = findobj('type','axes','tag','data display');



if frm==1
    star = findobj('Marker',mkr);
    if ~isempty(star)
        delete(star)
        return
    end
end

if strcmp(as,'on')
    delete(findobj('type','line','tag','ln frame'));
    ln = get(findobj('type','axes','tag','data display'),'Children');
    
    if ~isempty(ln)
        
        a = varargin{1,1};
        numframes = a{1};
        av_ratio = a{2};
        
        if length(a)>2
            numframes = a{3};
        end
        
            yd = get(ln(1),'ydata');
            
            if length(yd)==numframes*av_ratio
                frm = frm*av_ratio;
            end
            y = get(ax,'ylim');
            line('parent',ax,'xdata',[frm frm],'ydata',y,'Marker',mkr,...
                'MarkerSize',4,'tag','ln frame','color',c,...
                'LineWidth',1.5);
            %delete(findobj('tag','vline'))
            %h = vline(frm,ax);
         
    end
end

function h=vline(x,ax)
% function h=vline(x, linetype, label)
% 
% Draws a vertical line on the current axes at the location specified by 'x'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = vline(42,'g','The Answer')
%
% returns a handle to a green vertical line on the current axes at x=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% vline also supports vector inputs to draw multiple lines at once.  For example,
%
% vline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001


linetype='k';

    


g=ishold(ax);
hold on

y=get(ax,'ylim');
h=plot([x x],y,linetype);


if g==0
    hold off
end
set(h,'tag','vline','handlevisibility','off')


