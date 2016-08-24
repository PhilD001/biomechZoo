function ismov = cameracontrol(action,varargin)
if nargin == 0
    action = 'buttondown';
    ax = gca;
end
if isnumeric(action)
    ax = action;
    action = 'buttondown';
else 
    ax = gca;
end

switch action
    case 'buttondown'
        global daxesvar
        global ismoved
        ismoved = 0;
        state = uisuspend(gcf);
        daxesvar.axes = ax;
        curpt = get(daxesvar.axes(1),'currentpoint');
        cpos = get(daxesvar.axes(1),'cameraposition');
        ctarg = get(daxesvar.axes(1),'cameratarget');
        cvec = cpos-ctarg;
        cvec = sqrt(cvec*cvec')*.002;
        norm = curpt(2,:)-curpt(1,:);                
        daxesvar.pt = line2plane(curpt,[cpos;norm]);
        nm = get(gcf,'name');
        set(gcf,'name','moving...');
        [x,y,z] = sphere(20);
        x = x*cvec;
        y = y*cvec;
        z = z*cvec;
        ud.xdata = x;
        ud.ydata = y;
        ud.zdata = z;
        x = x+ctarg(1);
        y = y+ctarg(2);
        z = z+ctarg(3);
        
        hnd = surface('xdata',x,'ydata',y,'zdata',z,'userdata',ud,'facecolor',[1 0 0],'edgecolor','none','facelighting','gouraud','clipping','off');
        daxesvar.handle = hnd;
        set(gcf,'windowbuttonmotionfcn','cameracontrol(''motion'')');
        set(gcf,'windowbuttonupfcn','cameracontrol(''up'')');
        waitfor(gcf,'name','stop');
        set(gcf,'name',nm);
        uirestore(state);
        ismov = ismoved;
        clear global daxesvar;
        clear global ismoved;
        delete(hnd);

    case 'motion' %motion
        global daxesvar
        global ismoved
        ismoved = 1;
        curpt = get(daxesvar.axes(1),'currentpoint');
        cpos = get(daxesvar.axes(1),'cameraposition');
        ctarg = get(daxesvar.axes(1),'cameratarget');
        cup = get(daxesvar.axes(1),'cameraupvector');

        norm = curpt(2,:)-curpt(1,:);                
        nexpt = line2plane(curpt,[cpos;norm]);        
        cvec = cpos- ctarg;
        delta = nexpt-daxesvar.pt;
        
        switch get(gcf,'selectiontype')
            case 'extend'
                set(daxesvar.axes(1),'cameraposition',cpos-delta,'cameratarget',ctarg-delta)
                daxesvar.pt = nexpt-delta;
            case 'normal'
                i = cvec;
                k = cup;
                j = -cross(i,k);
                j(3) = 0;
                k = cross(i,j);
                
                ort = makeunit([i;j;k]);
                prevpt = ctransform(gunit,ort,daxesvar.pt-cpos);
                nexpt = ctransform(gunit,ort,nexpt-cpos);
                d = nexpt-prevpt;
                if abs(d(3)) > abs(d(2)) %vertical move
                    d = [0 0 d(3)];
                else 
                    %horizontal move
                    d = [0 d(2) 0];                    
                end
                d = ctransform(ort,gunit,d)*10;
                mcvec = sqrt(cvec*cvec');
                ncvec = makeunit(cvec+d)*mcvec;
                ncup = makeunit(cross(ncvec,j));

                set(daxesvar.axes(1),'cameraposition',ncvec+ctarg,'cameraupvector',ncup);
                rotateothercams(daxesvar.axes(2:end),ncvec,ncup);
            case 'alt'
                
                mcvec = sqrt(cvec*cvec');
                i = cvec;
                k = cup;
                j = -cross(i,k);
                k = cross(i,j);
                ort = makeunit([i;j;k]);
                vdis = dot(delta,ort(3,:));
                hdis = dot(delta,ort(2,:));
                delta = 1;
                if abs(vdis) > abs(hdis) %vertical move
                    if vdis >0
                        delta = -delta;
                    end
                    delta = (cvec/mcvec)*vdis*10; %*.02*mcvec;
                    cpos = cpos+delta;
                    
                else
                   % if hdis>0
                   %     delta = -delta;
                    %end
                    %delta = (cvec/mcvec)*delta*.1*mcvec;
                    %ctarg = ctarg +delta;
                end
                
                set(daxesvar.axes(1),'cameraposition',cpos,'cameratarget',ctarg);
        end
        curpt = get(daxesvar.axes(1),'currentpoint');
        cpos = get(daxesvar.axes(1),'cameraposition');
        ctarg = get(daxesvar.axes(1),'cameratarget');
        norm = curpt(2,:)-curpt(1,:);                
        daxesvar.pt = line2plane(curpt,[cpos;norm]); 
        ud =get(daxesvar.handle,'userdata');
        set(daxesvar.handle,'xdata',ud.xdata+ctarg(1),'ydata',ud.ydata+ctarg(2),'zdata',ud.zdata+ctarg(3));
        
        
    case 'up' %button up
        set(gcf,'name','stop');
        
end

function rotateothercams(ax,cvec,cup)
cvec = makeunit(cvec);

for i = 1:length(ax)
    ctarg = get(ax(i),'cameratarget');
    cpos = get(ax(i),'cameraposition');
    vec = cpos-ctarg;
    mg = sqrt(vec*vec');
    vec = cvec*mg;
    set(ax(i),'cameraposition',ctarg+vec,'cameraupvector',cup);
end

