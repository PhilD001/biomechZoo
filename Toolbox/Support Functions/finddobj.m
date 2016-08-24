function varargout = finddobj(action,varargin)

switch action
    case 'figure'
        varargout{1} = findobj('tag','space','type','figure');
    case 'axes'
        varargout{1} = findobj(finddobj('figure'),'type','axes','units','normalized','tag','space');
    case 'person menu'
        varargout{1} = findobj('parent',finddobj('figure'),'tag','current person');
    case 'view menu'
        varargout{1} = findobj('label','view','parent',finddobj('figure'));
    case 'ice'
        varargout{1} = findobj(finddobj('axes'),'tag','ice','type','patch');
    case 'camera grid'
        varargout{1} = findobj(finddobj('axes'),'type','line','tag','camera grid');
    case 'camera light'
        varargout{1} = findobj(finddobj('axes'),'type','light','tag','camera light');
    case 'contextmenu'
        varargout{1} = findobj(finddobj('figure'),'type','uicontextmenu','tag','main');
    case 'orientation window'
        varargout{1} = findobj(finddobj('figure'),'type','axes','tag','orientation window');
    case 'current object'
        if nargin == 1
            varargout{1} = findobj('parent',finddobj('figure'),'tag','current object','type','uicontrol');
        else
            varargout{1} = get(finddobj('current object'),'string');
        end
    case 'frame'
        if nargin == 1
            varargout{1} = findobj('parent',finddobj('figure'),'tag','frame','style','text');
        else
            varargout{1} = str2num(get(finddobj('frame'),'string'));
        end
    case 'special object'
        if nargin == 1
            varargout{1} = findobj(finddobj('axes'),'buttondownfcn','specialobject(''buttondown'')');
        else
            ac = varargin{1};
            hnd = finddobj('special object');
            stk = [];
            for i = 1:length(hnd);
                ud = get(hnd(i),'userdata');
                d = ud.data;
                for j = 1:length(d)
                    if ~isempty(intersect(ac,{d(j).actor}))
                        stk = [stk;hnd(i)];
                        break
                    end
                end
            end
            varargout{1} = stk;
        end
    case 'units'
        if nargin == 1
            fig = finddobj('figure');
            unt = findobj(fig,'style','togglebutton','callback','director(''units'')');
            varargout{1} = findobj(unt,'value',1);
            varargout{2} = unt;
        elseif nargin == 2
            [a,hnd] = finddobj('units');
            switch varargin{1}
                case 'displacement'
                    varargout{1} = findobj(hnd,'tag','displacement');
                case 'rotation'
                    varargout{1} = findobj(hnd,'tag','angle');
                case 'volume'
                    varargout{1} = findobj(hnd,'tag','volume');
            end
        else
            varargout{1} = get(finddobj('units',varargin{1}),'userdata');
        end
    case 'actor'
        varargout{1} = findobj(finddobj('axes'),'type','patch','createfcn','actor(''createfcn'')');
    case 'whole actor'
        anm = varargin{1};
        ac = findobj(finddobj('actor'),'tag',anm);
        cos = finddobj('costume');
        for i = 1:length(cos)
            ud = get(cos(i),'userdata');
            if strcmp(ud.actor,anm)
                ac = [ac;cos(i)];
            end
        end
        varargout{1} = ac;
    case 'marker'
        varargout{1} = findobj(finddobj('axes'),'createfcn','marker(''createfcn'')');
                
    case 'props'
        if nargin ==1
            varargout{1} = findobj(finddobj('axes'),'createfcn','props(''createfcn'')');
        else
            switch varargin{1}
                case 'joint'
                    hnd = finddobj('props');
                    ud = get(hnd,'userdata');
                    if ~iscell(ud)
                        ud = {ud};
                    end
                    stk = [];
                    for i = 1:length(ud)
                        if isfield(ud{i},'joint')
                            stk = [stk,hnd(i)];
                        end
                    end
                    varargout{1} = stk;
            end
        end                                    
    case 'accessory'
        varargout{1} = findobj(finddobj('axes'),'buttondownfcn','accessoryfxn(''buttondown'')');
    case 'graph'
        varargout{1} = findobj(finddobj('figure'),'type','axes','buttondownfcn','grips(''data buttondown'')');
    case 'colorpallete'
        varargout{1} = findobj(finddobj('figure'),'tag','color','style','pushbutton');
    case 'image'
        varargout{1} = findobj(finddobj('figure'),'type','axes','units','pixels');
    case 'internal image'
        varargout{1} = findobj(finddobj('axes'),'type','surface','buttondownfcn','grips(''internal image buttondown'')');
    case 'top menu'
        varargout{1} = findobj('parent',finddobj('figure'),'type','uimenu');
    case 'invisible wand'
        varargout{1} = findobj(finddobj('figure'),'label','invisible wand');
    case 'track'
        varargout{1} = findobj(finddobj('axes'),'type','patch','buttondownfcn','actor(''track buttondown'')');
    case 'costume pointer'
        varargout{1} = findobj(finddobj('axes'),'type','surface','tag','costumepointer');
    case 'costume'
        varargout{1} = findobj(finddobj('axes'),'buttondownfcn','costume(''buttondown'')');
    case 'bomb'
        varargout{1} = findobj(finddobj('axes'),'tag','bomb');
    case 'highlight'
        varargout{1} = findobj(finddobj('axes'),'ambientstrength',.6);
    case 'garbage'
        ax = finddobj('axes');
        fig = finddobj('figure');
        h1 = findobj(fig,'style','pushbutton','tag','specialobject');
        h2 = findobj(ax,'tag','costumepointer');        
        h3 = findobj(ax,'tag','bomb1');
        h4 = findobj(ax,'tag','bomb2');
        h5 = findobj(ax,'tag','bomb3');
        h6 = findobj(fig,'tag','zoofiltmenu');
        varargout{1} = [h1;h2;h3;h4;h5;h6];
    case 'tool'
        varargout{1} = findobj(finddobj('axes'),'buttondownfcn','sculpttool(''buttondown'')');
    case 'controls'
        varargout{1} = findobj(finddobj('figure'),'createfcn','controls(''createfcn'')');
    case 'object'
        switch length(varargin)
            case 3
                ac = varargin{1};
                bp = varargin{2};
                tg = varargin{3};
                hd = findpart(ac,'head');
                hud = get(hd,'userdata');
                if isempty(hud)
                    varargout{1} = [];
                else
                    varargout{1} = findobj(hud.associateobj,'tag',tg);
                end
            case 2
                ac = varargin{1};
                bp = varargin{2};
                varargout{1} = findpart(ac,bp);
            case 1
                varargout{1} = findobj(finddobj('axes'),'tag',varargin{1});
        end
end
        
end