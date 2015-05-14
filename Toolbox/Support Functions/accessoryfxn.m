function varargout = accessoryfxn(action,varargin)

switch action
    case 'load'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        sg = {'head','neck','trunk','pelvis','Lupperarm','Rupperarm','Lforearm','Rforearm','Lhand','Rhand','Lthigh','Rthigh','Lshank','Rshank','Lfoot','Rfoot'};
        answer = listdlg('liststring',sg,'selectionmode','single','name','select segment');
        if isempty(answer)
            return
        end
        nm = inputdlg('enter name of accessory','name');
        if isempty(nm)
            return
        end
        nm = nm{1};
        fl = varargin{1};
        t = load(fl,'-mat');
        sg = sg{answer};
        ud.segment = sg;
        ud.actor = get(hnd(1),'tag');
        ud.cdata = t.accessory.cdata;

        if isfield(t.accessory,'ort')
            ud.ort = t.accessory.ort;
        else
            ud.ort = [1 0 0;0 1 0;0 0 1];
        end
        if isfield(t.accessory,'dis')
            ud.dis = t.accessory.dis;
        else
            ud.dis = [0 0 0];
        end
        if isfield(t.accessory,'vertices');
            ud.vertices = t.accessory.vertices;
            ud.faces = t.accessory.faces;
        else
            ud.xdata = t.accessory.xdata;
            ud.ydata = t.accessory.ydata;
            ud.zdata = t.accessory.zdata;
        end
        ud.tag = nm;
        create(ud)
        stick;
        varargout{1} = nm;

    case 'save'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'accessory')
            return
        end
        accessory = get(hnd,'userdata');
        [f,p] = uiputfile('*.acs','save your accessory');
        if f == 0
            return
        end
        f = extension(f,'.acs');
        save([p,f],'accessory');

    case 'copy'
        answer = inputdlg('enter another name','another name');
        if isempty(answer)
            return
        end

        ud = get(varargin{1},'userdata');
        ud.tag = answer{1};
        create(ud)
        stick;
        set(finddobj('current object'),'string',ud.tag);
    case 'buttondown'
        cameraman('buttondown');
        set(finddobj('current object'),'string',get(gcbo,'tag'));

    case 'resize'
        [tp,hnd] = currentobject;
        [utp,val] = currentunits;
        if ~strcmp(tp,'accessory')
            return
        end
        ud = get(hnd,'userdata');
        if isfield(ud,'vertices');
            switch varargin{1}
                case 'leftarrow'
                    ud.vertices(:,1) = ud.vertices(:,1)/val;
                case 'rightarrow'
                    ud.vertices(:,1) = ud.vertices(:,1)*val;
                case 'downarrow'
                    ud.vertices(:,2) = ud.vertices(:,2)/val;
                case 'uparrow'
                    ud.vertices(:,2) = ud.vertices(:,2)*val;
                case 'pagedown'
                    ud.vertices(:,3) = ud.vertices(:,3)/val;
                case 'pageup'
                    ud.vertices(:,3) = ud.vertices(:,3)*val;
            end
        else
            switch varargin{1}
                case 'leftarrow'
                    ud.xdata = ud.xdata/val;
                case 'rightarrow'
                    ud.xdata = ud.xdata*val;
                case 'downarrow'
                    ud.ydata = ud.ydata/val;
                case 'uparrow'
                    ud.ydata = ud.ydata*val;
                case 'pagedown'
                    ud.zdata = ud.zdata/val;
                case 'pageup'
                    ud.zdata = ud.zdata*val;
            end
        end
        set(hnd,'userdata',ud);
        stick;
    case 'displacement'
        [tp,hnd] = currentobject;
        [utp,val] = currentunits;
        if ~strcmp(tp,'accessory')
            return
        end
        ud = get(hnd,'userdata');
        switch varargin{1}
            case 'leftarrow'
                ud.dis(:,1) = ud.dis(:,1)-val;
            case 'rightarrow'
                ud.dis(:,1) = ud.dis(:,1)+val;
            case 'downarrow'
                ud.dis(:,2) = ud.dis(:,2)-val;
            case 'uparrow'
                ud.dis(:,2) = ud.dis(:,2)+val;
            case 'pagedown'
                ud.dis(:,3) = ud.dis(:,3)-val;
            case 'pageup'
                ud.dis(:,3) = ud.dis(:,3)+val;
        end
        set(hnd,'userdata',ud);
        stick;

    case 'rotation'
        [tp,hnd] = currentobject;
        [utp,val] = currentunits;
        if ~strcmp(tp,'accessory')
            return
        end
        ud = get(hnd,'userdata');
        if ~isfield(ud,'ort');
            ud.ort = [1 0 0;0 1 0;0 0 1];
            set(hnd,'userdata',ud);
            return
        end

        switch varargin{1}
            case 'leftarrow'
                ud.ort = unitrotate(ud.ort,1,-val);
            case 'rightarrow'
                ud.ort = unitrotate(ud.ort,1,val);
            case 'downarrow'
                ud.ort = unitrotate(ud.ort,2,-val);
            case 'uparrow'
                ud.ort = unitrotate(ud.ort,2,val);
            case 'pagedown'
                ud.ort = unitrotate(ud.ort,3,-val);
            case 'pageup'
                ud.ort = unitrotate(ud.ort,3,val);
        end
        set(hnd,'userdata',ud);
        stick;
    case 'stick'
        stick;
end

function r = unitrotate(unt,indx,val);

eu = unit2euler(unt);
eu(indx) = eu(indx)+val;
r = euler2unit(eu);



function create(ud)

if isfield(ud,'vertices')
    patch('vertices',ud.vertices,'faces',ud.faces,'facecolor','flat','edgecolor','none','userdata',ud,'buttondownfcn','accessoryfxn(''buttondown'')',...
        'cdata',ud.cdata,'tag',ud.tag,'clipping','off','createfcn','accessoryfxn(''createfcn'')');
else
    surface('xdata',ud.xdata,'ydata',ud.ydata,'zdata',ud.zdata,'cdata',ud.cdata,'facecolor','flat','edgecolor','none','userdata',ud,...
        'buttondownfcn','accessoryfxn(''buttondown'')','tag',ud.tag,'clipping','off','createfcn','accessoryfxn(''createfcn'')');
end

function stick;

acs = finddobj('accessory');

for i = 1:length(acs)
    ud = get(acs(i),'userdata');
    ac = ud.actor;
    part = ud.segment;
    hd = findpart(ac,'head');
    hud = get(hd,'userdata');
    ort = getfield(hud.currentorientation,part);
    dis = getfield(hud.currentposition,part);
    gunit = [1 0 0;0 1 0;0 0 1];
    if isfield(ud,'vertices');
        vr = ud.vertices;
        if isfield(ud,'ort')
            vr = ctransform(ud.ort,o,vr);
        end
        vr = ctransform(o,gunit,vr);
        d2 = ctransform(o,gunit,ud.dis);
        vr(:,1) = vr(:,1)+dis(1)+d2(1);
        vr(:,2) = vr(:,2)+dis(2)+d2(2);
        vr(:,3) = vr(:,3)+dis(3)+d2(3);
        set(acs(i),'vertices',vr);
    elseif isfield(ud,'xdata')
        xd = ud.xdata;
        yd = ud.ydata;
        zd = ud.zdata;
        if isfield(ud,'ort')
            [xd,yd,zd] = mtransform(ud.ort,o,xd,yd,zd);
        end
        [xd,yd,zd] = mtransform(o,gunit,xd,yd,zd);
        d2 = ctransform(o,gunit,ud.dis);
        xd = xd+dis(1)+d2(1);
        yd = yd+dis(2)+d2(2);
        zd = zd+dis(3)+d2(3);
        set(acs(i),'xdata',xd,'ydata',yd,'zdata',zd);
    end
end

