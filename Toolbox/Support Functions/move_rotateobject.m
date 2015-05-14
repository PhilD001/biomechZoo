function varargout = move_rotateobject(action)
if nargin == 0
    action = 'buttondown';
end
switch action
    case 'buttondown'
        global daxesvar
        global ismoved
        ismoved = 0;
        state = uisuspend(gcf);
        daxesvar.curpt = get(gcf,'currentpoint');
        set(gcf,'windowbuttonmotionfcn','move_rotateobject(''motion'')');
        set(gcf,'windowbuttonupfcn','uiresume');
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
        hdis = -hdis;
        ang = 1;
        dis = 1;
        if isempty(ang)
            ang = 1;
        end
        switch get(gcf,'selectiontype')
            case 'extend'
                if abs(hdis)> abs(vdis)
                    if hdis > 0
                        move_rotate('right',dis)
                    else
                        move_rotate('left',dis)
                    end
                else
                    if vdis > 0
                        move_rotate('down',dis)
                    else
                        move_rotate('up',dis)
                    end
                end
            case 'normal'
                if abs(hdis)> abs(vdis)
                    if hdis > 0 %rotate about the zaxes
                        move_rotate('yaw',ang);
                    else
                        move_rotate('yaw',-ang);
                    end
                else
                    if vdis < 0
                        move_rotate('pitch',-ang);
                    else
                        move_rotate('pitch',ang);
                    end
                end
            case 'alt'
                if vdis < 0
                    move_rotate('roll',-dis);
                else
                    move_rotate('roll',dis);
                end

        end
        daxesvar.curpt = curpt;
end


function move_rotate(action,val)
if isempty(val)
    return
elseif length(val)==1
    if val ==0
        return
    end
end
vr = get(gco,'vertices');
ax = gca;
cpos = get(ax,'cameraposition');
ctarg = get(ax,'cameratarget');
cup = get(ax,'cameraupvector');
cvec = ctarg-cpos;
mcvec = sqrt(cvec*cvec');
switch action 
    case 'forward'        
        cvec = makeunit(cvec)*val;
        vr = displace(vr,cvec);
    case 'backward'
        cvec = -makeunit(cvec)*val;
        vr = displace(vr,cvec);        
    case 'right'
        crs = makeunit(cross(cvec,cup))*val;
        vr = displace(vr,crs);
    case 'left'
        crs = -makeunit(cross(cvec,cup))*val;
        vr = displace(vr,crs);
    case 'up'
        crs = makeunit(cross((cross(cvec,cup)),cvec))*val;
        vr = displace(vr,crs);
    case 'down'
        crs = -makeunit(cross((cross(cvec,cup)),cvec))*val;
        vr = displace(vr,crs);        
    case 'pitch'
        i = cvec;
        j = cross(cup,cvec);
        k = cross(i,j);
        gunit = [1 0 0;0 1 0;0 0 1];
        unt = makeunit([i;j;k]);
        nvr = ctransform(gunit,unt,vr);
        nunt = vecrotate(gunit,val,'y');
        nunt = ctransform(unt,gunit,nunt);
        vr = ctransform(nunt,gunit,nvr);
        
    case 'yaw'
        i = cvec;
        j = cross([0 0 1],cvec);
        k = cross(i,j);
        gunit = [1 0 0;0 1 0;0 0 1];
        unt = makeunit([i;j;k]);
        nvr = ctransform(gunit,unt,vr);
        nunt = vecrotate(gunit,val,'z');
        nunt = ctransform(unt,gunit,nunt);
        vr = ctransform(nunt,gunit,nvr);
    case 'roll'
        i = cvec;
        j = cross([0 0 1],cvec);
        k = cross(i,j);
        gunit = [1 0 0;0 1 0;0 0 1];
        unt = makeunit([i;j;k]);
        nvr = ctransform(gunit,unt,vr);
        nunt = vecrotate(gunit,val,'x');
        nunt = ctransform(unt,gunit,nunt);
        vr = ctransform(nunt,gunit,nvr);
end
set(gco,'vertices',vr);

function r = displace(m,v)
r(:,1) = m(:,1)+v(1);
r(:,2) = m(:,2)+v(2);
r(:,3) = m(:,3)+v(3);