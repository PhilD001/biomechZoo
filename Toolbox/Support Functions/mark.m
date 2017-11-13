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
specialobject('stick');
costume('stick');
accessoryfxn('stick');
grips('random task');
props('goto',frm);
cameraman('goto',frm,direction);

lightman('refresh');

as = get(findobj('type','axes','tag','data display'),'Visible');

if ~isempty(as)
    graph_mark(frm,varargin)
end

pause(0.01)  % needed to allow button stop to stop animation




function graph_mark(frm,varargin)

as = get(findobj('type','axes','tag','data display'),'Visible');
ax = findobj('type','axes','tag','data display');

if frm==1
    star = findobj('Marker','*');
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
        
        for i = 1:length(ln)
            c = get(ln(i),'Color');
            yd = get(ln(i),'ydata');
            
            if length(yd)==numframes*av_ratio
                frm = frm*av_ratio;
            end
            
            line('parent',ax,'xdata',frm,'ydata',yd(frm),'Marker','*',...
                 'MarkerSize',8,'tag','ln frame','color',c,...
                 'LineWidth',1.5);
            
        end 
    end
end