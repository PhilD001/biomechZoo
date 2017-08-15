function varargout = lightman(action,varargin);

switch action
    case 'refresh'
        ax = finddobj('axes');
        cl =finddobj('camera light');
        set(cl,'position',get(ax,'cameraposition'));
        
        lg = setdiff(findobj(ax,'type','light'),cl);
        
        cpos = get(ax,'cameraposition');
        ctarg = get(ax,'cameratarget');
        cup = get(ax,'cameraupvector');
        cvec = ctarg-cpos;
        
        i = cvec;
        j = cross(cup,cvec);
        k = cross(i,j);
        gunit = [1 0 0;0 1 0;0 0 1];
        unt = makeunit([i;j;k]);

        for i = 1:length(lg)
            ud = get(lg(i),'userdata');
            if ~isstruct(ud)
                continue
            end
            pos = cpos+ctransform(unt,gunit,ud.rposition);
            set(lg(i),'position',pos);
        end
        
    case 'create'
        a = inputdlg({'x (+ve = towards target)','y (+ve = left)','z (+ve = up)'},'enter relative coordinates to camera',1,{'0','0','0'});
        if isempty(a)
            return
        end
        ud.rposition =  [str2num(a{1}) str2num(a{2}) str2num(a{3})];
        light('parent',finddobj('axes'),'userdata',ud,'style','local');
        lightman('refresh');
        
    case 'save'
        ax = finddobj('axes');
        cl =finddobj('camera light');
        set(cl,'position',get(ax,'cameraposition'));
        
        lg = setdiff(findobj(ax,'type','light'),cl);
        for i= 1:length(lg)
            lighting(i) = get(lg(i),'userdata');
        end
        [f,p] = uiputfile('*.light');
        if f ==0
            return
        end
        save([p,f],'lighting');
        
    case 'load'
        t = load(varargin{1},'-mat');
        ax = finddobj('axes');
        for i = 1:length(t.lighting);
            light('parent',ax,'userdata',t.lighting(i),'style','local');
        end
        lightman('refresh');
end