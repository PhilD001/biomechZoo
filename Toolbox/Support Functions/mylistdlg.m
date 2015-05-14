function varargout = mylistdlg(varargin);

if nargin == 1
    action = varargin{1};
else
    action = 'start';
    kw = load(which('mylistdlg.prf'),'-mat');
    kw = kw.keyword;
    tl = '';
    nm = '';
    tl2 = '';
    slist = {};
    for i = 1:2:nargin;
        switch varargin{i};
            case 'list'
                kw = varargin{i+1};
            case 'name'
                nm = varargin{i+1};
            case 'title'
                tl = varargin{i+1};
            case 'source list'
                slist = varargin{i+1};
            case 'source title'
                tl2 = varargin{i+1};
        end
    end
end
switch action
    case 'start'
        kw = makecolumn(kw);
        ss = screensize('centimeters');
        pt = ss(3:4)/2;
        fig = figure('windowstyle','modal','closerequestfcn','mylistdlg(''closereq'')',...
            'units','centimeters','position',[pt(1)-6, pt(2)-5, 12 10],'menubar','none',...
            'name',nm,'numbertitle','off','keypressfcn','mylistdlg(''keypress'')');
        tl = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string',tl,'units','centimeters',...
            'position',[0 0 4 .5]);
        position(tl,fig,'top right',[1,1]);
        ls = uicontrol('style','listbox','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string',kw,'units','centimeters',...
            'position',[0 0 4 5],'tag','keywords','value',length(kw),'callback','mylistdlg(''list callback'')');
        position(ls,tl,'bottom',[0 0]);
        ed2 = uicontrol('style','edit','units','centimeters','position',[0 0 4 .5],'tag','tag','string','','callback','mylistdlg(''edit callback'')');
        position(ed2,ls,'bottom',[0 0]);

        ok = uicontrol('style','togglebutton','value',0,'units','centimeters','position',[0 0 1.5 .5],'string','OK','callback','uiresume');
        position(ok,fig,'bottom right',[.1 .1]);

        cancel = uicontrol('style','togglebutton','value',0,'units','centimeters','position',[0 0 1.5 .5],'string','Cancel','callback','uiresume');
        position(cancel,ok,'left',[.2 0]);
        
        
        tl2 = uicontrol('style','text','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string',tl2,'units','centimeters',...
            'position',[0 0 4 .5]);
        position(tl2,fig,'top left',[1,1]);
        ls2 = uicontrol('style','listbox','backgroundcolor',get(fig,'color'),'foregroundcolor',[0 0 0],'string',slist,'units','centimeters',...
            'position',[0 0 4 5],'tag','source','value',length(slist));
        position(ls2,tl2,'bottom',[0 0]);
        
        pb = uicontrol('style','pushbutton','backgroundcolor',[.8 .8 .8],'units','centimeters','position',[0 0 .7 .5],...
            'string','>>','callback','mylistdlg(''transfer'')');
        position(pb,ls2,'right',[.6 0]);
        
        pb2 = uicontrol('style','pushbutton','backgroundcolor',[.8 .8 .8],'units','centimeters','position',[0 0 .7 .5],...
            'string','del','callback','mylistdlg(''delete'')');
        position(pb2,pb,'bottom',[0 .2]);
        
        uiwait
        vl = get(ok,'value');
        
        if vl
            keyword = get(ls,'string');
            save(which('mylistdlg.prf'),'keyword');
            varargout{1} = keyword;
        else
            varargout{1} = {};
        end
        delete(fig);
        
    case 'delete'
        dellist;
        figure(gcf);
    case 'transfer'
        ls = findobj(gcf,'style','listbox','tag','keywords');
        str = get(ls,'string');
        vl = get(ls,'value');
        sls = findobj(gcf,'style','listbox','tag','source');
        sstr = get(sls,'string');
        svl = get(sls,'value');
        if isempty(sstr)
            return
        end
        estr = sstr(svl);                        
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
        set(sls,'value',min(length(sstr),svl+1));
        
    case 'edit callback'
        ls = findobj(gcf,'style','listbox','tag','keywords');
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

function hnd = findbarobj(action,varargin)
switch action
    case 'figure'
        hnd = findobj('type','figure','tag','mylistdlg');
    case 'bar'
        hnd = findobj(findbarobj('figure'),'createfcn','mylistdlg(''createfcn'')');
    case 'list'
        hnd = findobj(findbarobj('figure'),'style','listbox');
end
