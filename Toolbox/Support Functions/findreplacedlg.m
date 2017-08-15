function [fd,rp,rpall] = findreplacedlg(action);

if nargin == 0
    action = 'start';
end
switch action
    case 'start'
        ss = screensize('centimeters');
        pt = ss(3:4)/2;
        fig = figure('windowstyle','modal','closerequestfcn','findreplacedlg(''closereq'')',...
            'units','centimeters','position',[pt(1)-3.25, pt(2)-1.5, 6.5 3],'menubar','none',...
            'name','find & replace','numbertitle','off');
        
        tl = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string','find','units','centimeters',...
            'position',[0 0 2.5 .5]);
        position(tl,fig,'top left',[.5 .2]);
        f = uicontrol('style','edit','units','centimeters','position',[0 0 2.5 .5],'tag','find');
        position(f,tl,'bottom',[0 0]);
        
        t2 = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string','replace','units','centimeters',...
            'position',[0 0 2.5 .5]);
        position(t2,tl,'right',[.5 0]);
        r = uicontrol('style','edit','units','centimeters','position',[0 0 2.5 .5],'tag','replace');
        position(r,t2,'bottom',[0 0]);
        
        rb = uicontrol('style','radiobutton','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string','replace all','units','centimeters',...
            'position',[0 0 2.5 .5]);
        position(rb,f,'bottom',[0 .2]);
        
        ok = uicontrol('style','togglebutton','value',0,'units','centimeters','position',[0 0 1.5 .5],'string','OK','callback','uiresume');
        position(ok,fig,'bottom right',[.1 .1]);
        
        ca = uicontrol('style','togglebutton','value',0,'units','centimeters','position',[0 0 1.5 .5],'string','cancel','callback','uiresume');
        position(ca,ok,'left',[.4 0]);
        
        uiwait
        vl = get(ok,'value');
        if vl            
            fd = get(f,'string');
            rp = get(r,'string');
            rpall = get(rb,'value');
            if isempty(fd) | isempty(rp)
                fd = '';
                rp = '';
            end
        else
            fd = '';
            rp = '';
            rpall = 0;
        end
        delete(fig);
    case 'closereq'
        uiresume;
end