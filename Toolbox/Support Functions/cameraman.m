function varargout = cameraman(action,varargin)

switch action
    case 'save'
        ax = finddobj('axes');
        mark = get(ax,'userdata');
        if isempty(mark)
            return
        end
        [f,p] = uiputfile('*.cam','save camerasequence');
        f = extension(f,'.cam');
        mark = mark.mark;
        save([p,f],'mark');

  
    case 'buttondown'
        if strcmp(get(gcf,'selectiontype'),'open')
            if strcmp(get(gco,'type'),'patch')
                vr = get(gco,'vertices');
                move_rotatecam('center',mean(vr));
                varargout{1} = 1;
                return
            end
        end
        global daxesvar
        global ismoved
        ismoved = 0;
        state = uisuspend(gcf);
        daxesvar.curpt = get(gcf,'currentpoint');
        set(gcf,'windowbuttonmotionfcn','cameraman(''motion'')');
        set(gcf,'windowbuttonupfcn','cameraman(''up'')');
        uiwait
        uirestore(state);
        varargout{1} = ismoved;
        clear global daxesvar;
        clear global ismoved;

    case 'motion' %motion
        global daxesvar
        global ismoved        
        ismoved = 1;
        curpt = get(gcf,'currentpoint');
        hdis = curpt(1)-daxesvar.curpt(1);
        vdis = curpt(2)-daxesvar.curpt(2);
        uvec = get(gca,'cameraupvector');
        hdis = -hdis;
        [unt,all] = finddobj('units');
        unt = findobj(all,'tag','angle');
        ang = get(unt,'userdata');
        dis = get(findobj(all,'tag','displacement'),'userdata');
        if isempty(ang)
            ang = 1;
        end
        switch get(gcf,'selectiontype')
            case 'extend'
                if abs(hdis)> abs(vdis)
                    if hdis > 0
                        move_rotatecam('right',dis)
                    else
                        move_rotatecam('left',dis)
                    end
                else
                    if vdis > 0
                        move_rotatecam('down',dis)
                    else
                        move_rotatecam('up',dis)
                    end
                end
            case 'normal'
                if abs(hdis)> abs(vdis)
                    if hdis > 0 %rotate about the zaxes
                        move_rotatecam('yaw',ang);
                    else
                        move_rotatecam('yaw',-ang);
                    end
                else
                    if vdis < 0
                        move_rotatecam('pitch',-ang);
                    else
                        move_rotatecam('pitch',ang);
                    end
                end
            case 'alt'
                if vdis > 0
                    move_rotatecam('backward',dis);
                else
                    move_rotatecam('forward',dis);
                end

        end
        daxesvar.curpt = curpt;
        lightman('refresh')


    case 'up' %button up
        uiresume

    case 'new film'
        fig = finddobj('figure');
        ud = get(fig,'userdata');
        ud.film = [];
        set(fig,'userdata',ud);

    case 'record'
        fig = finddobj('figure');
        ax = finddobj('axes');
        uic = findobj(fig,'type','uicontrol','visible','on');
        set(uic,'visible','off');
        pause(0);
        frm = getframe(fig);
        set(uic,'visible','on');
        ud = get(fig,'userdata');
        lflm = length(ud.film);
        lflm = lflm+1;
        ud.film(lflm).cdata = frm.cdata;
        ud.film(lflm).colormap = frm.colormap;
        set(fig,'userdata',ud);
        set(fig,'name',['director: frame ',num2str(lflm)]);

    case 'print film'
        fig = finddobj('figure');
        ud = get(fig,'userdata');
        if isempty(ud.film)
            return
        end
        [f,p]= uiputfile('*.avi','save film');
        if f == 0
            return
        end
        f = extension(f,'.avi');
        info = avimenu;
        mov = ud.film;
        movie2avi(mov,[p,f],'FPS',info.fps,...
            'Compression',info.compression,...
            'Quality',info.quality);
        ud.film = [];
        set(fig,'userdata',ud);

    case 'goto'
        cameramark(varargin{1},varargin{2});
    case 'mark'
        markposition;
                
    case 'make firstposition'
        markposition(1);
    case 'reset mark'
        ax = finddobj('axes');
        aud = get(ax,'userdata');
        aud.mark = [];
        set(ax,'userdata',aud);
        
    case 'save'
        [f,p] = uiputfile('*.cam','save your camerafile');
        if f == 0
            return
        end
        cd(p)
        ax = finddobj('axes');
        ud = get(ax,'userdata');
        cam = ud.mark;
        save([p,f],'cam');
        
    case 'load'
        t = load(varargin{1},'-mat');
        ax = finddobj('axes');
        ud = get(ax,'userdata');
        ud.mark = t.mark;
        set(ax,'userdata',ud);
        
    case 'keypress'
        if nargin == 1
            varargout{1} = keypress;
        else
            varargout{1} = keypress(varargin{1});
        end

end

function varargout = cameramark(index,direction)
ax = finddobj('axes');
ud = get(ax,'userdata');

p = getcurrentprop(ud,index,direction);
if isempty(p)
    return
end

% getting the target;
if isnumeric(p.target)
    targ = p.target;
elseif iscell(p.target) %the target is a bodypart;
    ac = getcurrentactor;
    bp = p.target{1};
    hd = findpart(ac,'head');
    hud = get(hd,'userdata');
    targ = getfield(hud.currentposition,bp);
else
    hnd = findobj(ax,'tag',p.target);
    if isempty(hnd)
        return
    end
    switch get(hnd(1),'type');
        case 'patch'
            targ = mean(get(hnd(1),'vertices'));
        case 'surface'
            targ = [mean(mean(get(hnd(1),'xdata'))),mean(mean(get(hnd(1),'ydata'))),mean(mean(get(hnd(1),'zdata')))];
    end
end
if ~isempty(find(isnan(targ)))
    return
end
targ = targ+p.rtarget;

%zoom and displace
if index == 1
    cpos = targ+p.camvec;
    set(ax,'cameratarget',targ,'cameraposition',cpos,'cameraupvector',p.camupvec);
    return
else
    cvec = get(ax,'cameraposition')-get(ax,'cameratarget');
    mg = sqrt(cvec*cvec');
    nmg = mg*p.zoom;
    cvec = cvec*nmg/mg;
    cpos = targ+cvec;
end
set(ax,'cameraposition',cpos,'cameratarget',targ);
move_rotatecam('pitch',p.pitch);
move_rotatecam('yaw',p.yaw);


function p = getcurrentprop(ud,index,direction);
if isempty(ud.mark)
    p = [];
end
index = min(index,length(ud.mark));
cindex = [];
for i = index:-1:1
    if ~isempty(ud.mark(i).target);
        cindex = i;
        break
    end
end
p = ud.mark(cindex);
if ~isempty(p)
    switch direction
        case 'still'
            p.zoom = 1;
            p.yaw = 0;
            p.pitch = 0;
            p.roll = 0;
        case 'backward'
            p.zoom = 1+(1-p.zoom);
            p.yaw = -p.yaw;
            p.pitch = -p.pitch;
            p.roll = -p.roll;
    end
end





function unt = getunit(vec);

%this function will get the ijk unit vectors where i = vec j perpendicular to z axes and i

i = vec;
j = cross(vec,[0 0 1]);
k = cross(i,j);

i = i/sqrt(i*i');
j = j/sqrt(j*j');
k = k/sqrt(k*k');

unt = [i;j;k];





function r = keypress(cky)
dval = finddobj('units','displacement','number');
rval = finddobj('units','rotation','number');
vval = finddobj('units','volume','number');
if nargin == 0
    cky = get(gcf,'currentkey');
end
r = 1;
switch cky
    case 'insert'
        move_rotatecam('forward',dval);
    case 'delete'
        move_rotatecam('backward',dval);
    case 'leftarrow'
        move_rotatecam('left',dval);
    case 'rightarrow'
        move_rotatecam('right',dval);
    case 'uparrow'
        move_rotatecam('up',dval);
    case 'downarrow'
        move_rotatecam('down',dval);
    case 'home'
        move_rotatecam('pitch',dval);
    case 'end'
        move_rotatecam('pitch',-dval);
     case 'pageup'
        move_rotatecam('yaw',dval);
    case 'pagedown'
        move_rotatecam('yaw',-dval);       
    case 'r'
        cameraman('track');
    case 'numpad4'
        nextview('leftarrow');
    case 'numpad6'
        nextview('rightarrow');
    case 'numpad8'
        nextview('uparrow');
    case 'numpad2'
        nextview('downarrow');
    case 'numpad5'
        nextview('refresh');
    otherwise
        r = 0;
end
        
        


function markposition(varargin);

ax = finddobj('axes');

if nargin ==0
    frm = finddobj('frame','number');
else
    frm = varargin{1};
end

plate = getcamproperties;
aud = get(ax,'userdata');

if isempty(aud.mark)
    aud.mark= plate;
    aud.mark(frm) = plate;
else
    aud.mark(frm) = plate;
end


set(ax,'userdata',aud);

function r = getcamproperties;


hi = finddobj('highlight');
htag = get(hi,'tag');
ax = finddobj('axes');




ctarg = get(ax,'cameratarget');
cpos = get(ax,'cameraposition');
cup = get(ax,'cameraupvector');

if ~isempty(hi)
    htype = objecttype(hi);
    if strcmp(htype,'actor');
        bp = get(hi,'userdata');
        if isstruct(bp);
            bp = 'head';
        end
        hd = findpart(htag,'head');
        hud = get(hd,'userdata');
        pos = getfield(hud,'currentposition',bp);
        targ = {bp};
    else
        targ = htag;
        switch get(hi,'type');
            case 'patch'
                pos = mean(get(hi,'vertices'));
            case 'surface'
                pos = [mean(mean(get(hi,'xdata'))),mean(mean(get(hi,'ydata'))),mean(mean(get(hi,'zdata')))];
        end
    end
    r.target = targ;
    r.rtarget = ctarg-pos;
else
    r.target = ctarg;
    r.rtarget = [0 0 0];
end

ct = finddobj('controls');
zm = str2num(get(findobj(ct,'tag','zoom'),'string'));
pt = str2num(get(findobj(ct,'tag','pitch'),'string'));
yw = str2num(get(findobj(ct,'tag','yaw'),'string'));
rl = str2num(get(findobj(ct,'tag','roll'),'string'));

r.camvec = cpos-ctarg;
r.camupvec = get(ax,'cameraupvector');
r.zoom = zm;
r.pitch = pt;
r.yaw = yw;
r.roll = rl;


function move_rotatecam(action,val)
if isempty(val)
    return
elseif length(val)==1
    if val ==0
        return
    end
end
ax = finddobj('axes');
cpos = get(ax,'cameraposition');
ctarg = get(ax,'cameratarget');
cup = get(ax,'cameraupvector');
cvec = ctarg-cpos;
switch action 
    case 'forward'        
        cvec = makeunit(cvec)*val;
        cpos = cpos+cvec;
        set(ax,'cameraposition',cpos);
    case 'backward'
        cvec = -makeunit(cvec)*val;
        cpos = cpos+cvec;
        set(ax,'cameraposition',cpos);
    case 'right'
        crs = makeunit(cross(cvec,cup))*val;
        ctarg = ctarg+crs;
        cpos = cpos+crs;
        set(ax,'cameraposition',cpos,'cameratarget',ctarg);
    case 'left'
        crs = -makeunit(cross(cvec,cup))*val;
        ctarg = ctarg+crs;
        cpos = cpos+crs;
        set(ax,'cameraposition',cpos,'cameratarget',ctarg);
    case 'up'
        crs = makeunit(cross((cross(cvec,cup)),cvec))*val;
        ctarg = ctarg+crs;
        cpos = cpos+crs;
        set(ax,'cameraposition',cpos,'cameratarget',ctarg);
    case 'down'
        crs = -makeunit(cross((cross(cvec,cup)),cvec))*val;
        ctarg = ctarg+crs;
        cpos = cpos+crs;
        set(ax,'cameraposition',cpos,'cameratarget',ctarg);
        
    case 'pitch'
        i = cvec;
        j = cross(cup,cvec);
        k = cross(i,j);
        gunit = [1 0 0;0 1 0;0 0 1];
        unt = makeunit([i;j;k]);
        mcvec = vecrotate([sqrt(cvec*cvec') 0 0],val,'y');        
        ncvec = ctransform(unt,gunit,mcvec);
        cpos = ctarg-ncvec;
        nupvec = makeunit(cross(ncvec,j));
        set(ax,'cameraposition',cpos,'cameraupvector',nupvec);
        refreshorientation;        
    case 'yaw'
        i = cvec;
        j = cross([0 0 1],cvec);
        k = cross(i,j);
        gunit = [1 0 0;0 1 0;0 0 1];
        unt = makeunit([i;j;k]);
        mcvec = vecrotate([-sqrt(cvec*cvec') 0 0],val,'z');
        cpos = ctarg+ctransform(unt,gunit,mcvec);
        nupvec = ctransform(unt,gunit,[0 0 1]);
        if max(isnan(cpos)) || max(isnan(nupvec))
            return
        end
        set(ax,'cameraposition',cpos,'cameraupvector',nupvec);
        refreshorientation;
    case 'center'
        cpos = val-cvec;
        set(ax,'cameratarget',val,'cameraposition',cpos);
        refreshorientation;
end

if cpos(3) >=0
    set(finddobj('camera grid'),'color',[.2 .2 .2])
else
    set(finddobj('camera grid'),'color',[1 0 0])
end

function refreshorientation
ax = finddobj('axes');
oax = finddobj('orientation window');
cpos = get(ax,'cameraposition');
ctarg = get(ax,'cameratarget');
cup = get(ax,'cameraupvector');
cvec = cpos-ctarg;
cvec = makeunit(cvec)*3;
set(oax,'cameraposition',cvec,'cameraupvector',cup);
set(findobj(oax,'type','light'),'position',cvec);

function orthogonalview(action)
ax = finddobj('axes');

cpos = get(ax,'cameraposition');
ctarg = get(ax,'cameratarget');
cvec = cpos-ctarg;
mg = sqrt(cvec*cvec');
switch action
    case 'back'
        cvec = [0 -mg 0];
        cup = [0 0 1];
    case 'front'
        cvec = [0 mg 0];
        cup = [0 0 1];
    case 'left'
        cvec = [-mg 0 0];
        cup = [0 0 1];
    case 'right'
        cvec = [mg 0 0];
        cup = [0 0 1];
    case 'top'
        cvec = [0 0 mg];
        cup = [1 0 0];
    case 'bottom'
        cvec = [0 0 -mg];
        cup = [1 0 0];        
end
set(ax,'cameraposition',ctarg+cvec,'cameraupvector',cup);
refreshorientation;

function r = getcurrentview

ax = finddobj('axes');
cpos = get(ax,'cameraposition');
ctarg = get(ax,'cameratarget');
cvec = cpos-ctarg;

vang = angle(cvec,[cvec(1:2),0]);
hang = angle([cvec(1:2),0],[1 0 0]);
dh = dot(cvec,[0 1 0]);
if cvec(2) <0 
    hang = 360-hang;
end
if isnan(vang)
    vang = 90;
end
if vang > 70 && cvec(3) >0
    r = 'top';
elseif vang >70 && cvec(3) <0
    r = 'bottom';
elseif hang <=45 || hang > 315
    r = 'right';
elseif hang > 45 && hang <=135
    r = 'front';
elseif hang >135 && hang <=225
    r = 'left';
elseif hang >225 && hang <= 315
    r = 'back';
end
    

function nextview(cky)
if strcmp(cky,'refresh');
    v = getcurrentview;
else    
    switch getcurrentview
        case 'back'
            switch cky
                case 'leftarrow'
                    v = 'left';
                case 'rightarrow'
                    v = 'right';
                case 'uparrow'
                    v = 'top';
                case 'downarrow'
                    v = 'bottom';
            end
        case 'front'
            switch cky
                case 'leftarrow'
                    v = 'right';
                case 'rightarrow'
                    v = 'left';
                case 'uparrow'
                    v = 'top';
                case 'downarrow'
                    v = 'bottom';
            end
        case 'right'
            switch cky
                case 'leftarrow'
                    v = 'back';
                case 'rightarrow'
                    v = 'front';
                case 'uparrow'
                    v = 'top';
                case 'downarrow'
                    v = 'bottom';
            end
        case 'left'
            switch cky
                case 'leftarrow'
                    v = 'front';
                case 'rightarrow'
                    v = 'back';
                case 'uparrow'
                    v = 'top';
                case 'downarrow'
                    v = 'bottom';
            end
        case 'top'
            switch cky
                case 'uparrow'
                    v = 'front';
                case 'downarrow'
                    v = 'back';
                otherwise
                    return
            end
        case 'bottom'
            switch cky
                case 'uparrow'
                    v = 'front';
                case 'downarrow'
                    v = 'back';
                otherwise
                    return
            end
    end
end
orthogonalview(v);


function r = angle(m1,m2)

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));

r = r*180;
r = r/pi;

