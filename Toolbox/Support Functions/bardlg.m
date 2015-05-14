function [ntg,nkw] = bardlg(tg,kw,action);

if nargin == 2
    action = 'start';
elseif nargin == 1
    action = tg;
elseif nargin == 0
    action = 'all'
end

switch action
    case 'start'
        kw = makecolumn(kw);
        ss = screensize('centimeters');
        pt = ss(3:4)/2;
        fig = figure('windowstyle','modal','closerequestfcn','bardlg(''closereq'')',...
            'units','centimeters','position',[pt(1)-3, pt(2)-5, 6 10],'menubar','none',...
            'name',tg,'numbertitle','off','keypressfcn','bardlg(''keypress'')');
        tl = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string','name','units','centimeters',...
            'position',[0 0 2 .5]);
        position(tl,fig,'top',[0 .5]);
        ed = uicontrol('style','edit','units','centimeters','position',[0 0 2 .5],'tag','tag','string',tg);
        position(ed,tl,'bottom',[0,0]);
        tl = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string','keywords','units','centimeters',...
            'position',[0 0 2 .5]);
        position(tl,ed,'bottom',[0,1]);
        ls = uicontrol('style','listbox','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string',kw,'units','centimeters',...
            'position',[0 0 4 5],'tag','keywords','value',length(kw),'callback','bardlg(''list callback'')');
        position(ls,tl,'bottom',[0 0]);
        ed2 = uicontrol('style','edit','units','centimeters','position',[0 0 4 .5],'tag','tag','string','','callback','bardlg(''edit callback'')');
        position(ed2,ls,'bottom',[0 0]);
        
        ok = uicontrol('style','togglebutton','value',0,'units','centimeters','position',[0 0 1 .5],'string','OK','callback','uiresume');
        position(ok,fig,'bottom right',[.1 .1]);
        
        uiwait
        vl = get(ok,'value');
        if vl
            ntg = get(ed,'string');
            nkw = get(ls,'string');
        else
            ntg = tg;
            nkw = kw;
        end
        delete(fig);
        
    case 'all'
        ss = screensize('centimeters');
        pt = ss(3:4)/2;
        fig = figure('closerequestfcn','bardlg(''closereq'')',...
            'units','centimeters','position',[pt(1)-5.3, pt(2)-5, 10.6 10],'menubar','none',...
            'name',tg,'numbertitle','off','keypressfcn','bardlg(''keypress'')','tag','bardlg');        
        hnd = finddobj('special object');        
        ntgl = [];
        for i = 1:length(hnd)
            ud = get(hnd(i),'userdata');
            if strcmp(ud.fxn,'bargraph');
                ntgl = newtoggle(fig,hnd(i));
            end
        end
        if isempty(ntgl)
            delete(fig)
            return
        end
        pos = get(ntgl,'position');
        h = pos(2)+pos(4)+7;
        fpos = get(fig,'position');
        fpos(4) = h;
        fpos(2) = (ss(4)/2)-(h/2);
        set(fig,'position',fpos);
       
        tl = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string','keywords','units','centimeters',...
            'position',[0 0 2 .5]);
        position(tl,fig,'top',[0,.5]);
        ls = uicontrol('style','listbox','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string',{},'units','centimeters',...
            'position',[0 0 4 5],'tag','keywords','value',0,'callback','bardlg(''list callback'')');
        position(ls,tl,'bottom',[0 0]);
        ed2 = uicontrol('style','edit','units','centimeters','position',[0 0 4 .5],'tag','tag','string','','callback','bardlg(''edit callback'')');
        position(ed2,ls,'bottom',[0 0]);
        
        add = uicontrol('style','pushbutton','units','centimeters','position',[0 0 2 .5],'string','ADD','callback','bardlg(''add'')');
        position(add,ls,'right',[1 0]);
        
        rem = uicontrol('style','pushbutton','units','centimeters','position',[0 0 2 .5],'string','REMOVE','callback','bardlg(''remove'')');
        position(rem,add,'bottom',[0 .3]);
        
        tgl = uicontrol('style','radiobutton','units','centimeters','position',[0 0 2 .5],'string','select','backgroundcolor',get(fig,'color'),...
            'callback','bardlg(''select'')');
        position(tgl,ed2,'left',[1 0]);
        
        ok = uicontrol('style','togglebutton','value',0,'units','centimeters','position',[0 0 1 .5],'string','OK','callback','uiresume');
        position(ok,fig,'bottom right',[.1 .1]);
        uiwait        
        if get(ok,'value')
            tgl = findbarobj('bar');
            for i = 1:length(tgl)
                ud = get(tgl(i),'userdata');
                tg = get(tgl(i),'tag');
                spo = findobj(hnd,'tag',tg);
                sud = get(spo,'userdata');
                sud.keywords = ud;
                set(spo,'userdata',sud);
            end
        end
        delete(fig)
            
    case 'edit callback'
        ls = findobj(gcf,'style','listbox');
        str = get(ls,'string');
        vl = get(ls,'value');
        
        estr = get(gcbo,'string');
        if isempty(estr)
            return
        end
        estr = {estr};
        if isempty(str)
            str = estr;
            vl = 1;
        else            
            top = str(1:vl);
            bot = str(vl+1:end);
            tindx = find(strcmp(top,estr));
            bindx = find(strcmp(bot,estr));
            top(tindx) = [];
            bot(bindx) = [];
            str = [top;estr;bot];
            vl = find(strcmp(str,estr));
        end
        set(ls,'string',str,'value',vl);
        set(gcbo,'string','');
    case 'list callback'
        figure(gcf);
    case 'closereq'
        uiresume;
    case 'keypress'
        switch get(gcf,'currentkey');
            case 'delete'
                dellist;
            case 'backspace'
                dellist;
        end
    case 'select'
        vl = get(gcbo,'value');
        set(findbarobj('bar'),'value',vl);
        set(findbarobj('list'),'value',0,'string',{});
        figure(gcf)
        
    case 'add'
        hnd = findobj(findbarobj('bar'),'value',1);
        str = get(findbarobj('list'),'string');
        if isempty(str)
            return
        end
        for i = 1:length(hnd)
            ud =get(hnd(i),'userdata');
            for j = 1:length(str)
                indx = find(strcmp(ud,str(j)));
                ud(indx) = [];
            end    
            ud = [ud;makecolumn(str)];
            set(hnd(i),'userdata',ud);
        end
        
    case 'remove'
        hnd = findobj(findbarobj('bar'),'value',1);
        str = get(findbarobj('list'),'string');
        if isempty(str)
            return
        end
        for i = 1:length(hnd)
            ud =get(hnd(i),'userdata');
            for j = 1:length(str)
                indx = find(strcmp(ud,str(j)));
                ud(indx) = [];
            end            
            set(hnd(i),'userdata',ud);
        end
    case 'togglebutton'
        set(findbarobj('list'),'string',get(gcbo,'userdata'),'value',1);
        figure(gcf);
end

function dellist
ls = findobj(gcf,'style','listbox','tag','keywords');
str = get(ls,'string');
vl = get(ls,'value');
if isempty(str)
    return
end
str(vl) = [];
vl = min(vl,length(str));
if vl == 0
    vl = 1;
end
set(ls,'string',str,'value',vl);

function hnd = newtoggle(fig,spo)

tgl = findobj(fig,'style','togglebutton','createfcn','bardlg(''createfcn'')');

tg = get(spo,'tag');
ud = get(spo,'userdata');

if isempty(spo)
    return
end

nexpos = nextposition('number',length(tgl)+1,'width',2,'height',.5,'dx',.1,'dy',.1,'yoffset',1);
hnd = uicontrol('parent',fig,'style','togglebutton','units','centimeters',...
    'position',nexpos,'tag',tg,'string',tg,'userdata',ud.keywords,'createfcn','bardlg(''createfcn'')',...
    'callback','bardlg(''togglebutton'')');

function hnd = findbarobj(action,varargin)
switch action
    case 'figure'
        hnd = findobj('type','figure','tag','bardlg');
    case 'bar'
        hnd = findobj(findbarobj('figure'),'createfcn','bardlg(''createfcn'')');
    case 'list'
        hnd = findobj(findbarobj('figure'),'style','listbox');
end

