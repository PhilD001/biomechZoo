function varargout = specialobject(action,varargin)
switch action
    case 'setup'
        str = {'angle','angle minus 90','global angle','bargraph','groot suntay (global)','groot suntay (local)','skeleton','orientation'};
        answer = listdlg('liststring',str,'selectionmode','single');
        if isempty(answer)
            return
        end

        tp = str{answer};
        ac = finddobj('actor');
        set(gcf,'windowbuttondownfcn','specialobject(''setup buttondown'')');
        cm = uicontextmenu;
        uimenu(cm,'label','create','callback','specialobject(''create'')','userdata',tp);
        set(ac,'uicontextmenu',cm,'buttondownfcn','');
    case 'createfcn'
        ud = get(gcbo,'userdata');
        hd = findpart(ud.data.actor,'head');
        hud = get(hd,'userdata');
        hud.associateobj = [hud.associateobj;gcbo];
        set(hd,'userdata',hud);  
        ud.parent = hd;
        set(gcbo,'userdata',ud);
        
    case 'load soo or zoo'
        t = load(varargin{1},'-mat');
        spo = finddobj('special object');
        for i = 1:length(spo);
            ud = get(spo(i),'userdata');
            yd = [];
            if isfield(ud,'keywords');
                s = searchstruct(t,ud.keywords);
                if iscell(s)
                    s = s{1};
                end
                if ~isempty(s) & isstruct(s)
                    if isfield(s,'line');
                        yd = s.line;
                    elseif isfield(s,'mean')
                        yd = s.mean;
                    else
                        yd = [];
                    end
                    if isstruct(yd);
                        if isfield(yd,'mean');
                            yd = yd.mean;
                        end
                    end
                elseif isnumeric(s)
                    yd = s;
                end
            end
            if ~isempty(yd) & isnumeric(yd)
                ud.ydata = yd;
                set(spo(i),'userdata',ud);
            end
        end
        
    case 'setup buttondown'
        if isempty(intersect(gco,finddobj('actor')))
            return
        end
        part = get(gco,'userdata');
        if isstruct(part)
            part = 'head';
        end
        nm = get(gco,'tag');
        if isempty(findobj(objectlist,'string',part,'userdata',nm));
            newlist(nm,part);
        end

    case 'delete pushbutton'
        delete(gcbo)

    case 'buttondown'       
        ud = get(gcbo,'userdata');
        cp = finddobj('colorpallete');
        if ~isempty(cp) 
            clr = get(cp,'backgroundcolor');
        else
            clr = [];
        end
        
        switch get(gcf,'selectiontype');
            case 'normal'
                if ~isempty(clr)
                    set(gcbo,'facecolor',clr);
                end
                
                cameraman('buttondown');
                set(finddobj('current object'),'string',get(gcbo,'tag'));                                
                set(finddobj('highlight'),'ambientstrength',.3);
                set(gcbo,'ambientstrength',.6);
                
                
            case 'open'
                switch ud.fxn
                    case 'bargraph'
                        ud = get(gcbo,'userdata');
                        tg = get(gcbo,'tag');
                        kw = ud.keywords;
                        [tg,kw] = bardlg(tg,kw);
                        ud.keywords = kw;
                        set(gcbo,'tag',tg,'userdata',ud);
                        set(finddobj('current object'),'string',tg);
                end
            case 'alt'
                if ~isempty(clr)
                    if isnumeric(get(gcbo,'edgecolor'));
                        set(gcbo,'edgecolor',clr);
                    end
                end
                ud = get(gcbo,'userdata');
                switch ud.fxn
                    case 'bargraph'                        
                        tg = [get(gcbo,'tag'),' data'];
                        grips('data graph',ud.ydata,tg,get(gcbo,'facecolor'));
                    case 'angle'
                        tg = 'angle';
                        yd = zeros(100,1)*NaN;
                        grips('data graph',yd,tg,[1 0 0]);
                end
                        
        end
    case 'save'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'special object');
            return
        end
        [f,p] = uiputfile('*.spo','save file');
        if f == 0
            return
        end
        cd(p);
        f = extension(f,'.spo');
        ud = get(hnd,'userdata');
        d = ud.data;
        ac = {};
        for i = 1:length(d)
            ac = union(ac,{d(i).actor});
        end
        hnd = finddobj('special object',ac);
        for i = 1:length(hnd)
            cleardata(hnd(i));
            special(i).userdata = get(hnd(i),'userdata');
            special(i).name = get(hnd(i),'tag');
            special(i).facecolor = get(hnd(i),'facecolor');
            special(i).edgecolor = get(hnd(i),'edgecolor');
        end
        save([p,f],'special');

    case 'load'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'actor')
            return
        end
        delete(finddobj('special object'));

        t = load(varargin{1},'-mat');
        acnm = get(hnd(1),'tag');
        for i = 1:length(t.special)
            ud = t.special(i).userdata;
            for j = 1:length(ud.data)
                ud.data(j).actor = acnm;
            end
            p = defaultobj(ud,t.special(i).name,t.special(i));
        end
        stick;

    case 'create'
        if nargin == 1
            answer = inputdlg('enter name','name');
            if isempty(answer)
                return
            end
            hnd = flipud(objectlist);
            ud.fxn = get(gcbo,'userdata');
            for i = 1:length(hnd)
                ud.data(i).actor = get(hnd(i),'userdata');
                ud.data(i).segment = get(hnd(i),'string');
                ud.data(i).dis = [];
                ud.data(i).ort = [];
            end            
            ud.rdis = [0 0 0];
            ud.coeff = 1;
            tg = answer{1};
            delete(hnd);
        else
            ud = varargin{1};
            tg = varargin{2};
        end                
        defaultobj(ud,tg);
 
        

    case 'clear'
        hnd = finddobj('special object');
        cleardata(hnd);

    case 'resize'
        [tp,hnd] = currentobject;
        [utp,val] = currentunits;
        if ~strcmp(tp,'special object')
            return
        end
        ud = get(hnd,'userdata');
        switch ud.fxn
            case 'groot suntay'
            otherwise
                switch varargin{1}
                    case 'leftarrow'
                        ud.vertices(:,1) = ud.vertices(:,1)/val;
                    case 'rightarrow'
                        ud.vertices(:,1) = ud.vertices(:,1)*val;
                    case 'downarrow'
                        ud.vertices(:,2) = ud.vertices(:,2)/val;
                    case 'uparrow'
                        ud.vertices(:,2) = ud.vertices(:,2)*val;
                    case 'pageup'
                        ud.vertices(:,3) = ud.vertices(:,3)*val;
                    case 'pagedown'
                        ud.vertices(:,3) = ud.vertices(:,3)/val;

                end
        end
        set(hnd,'userdata',ud);
        stick;



    case 'stick'
        stick;
        
    case 'keypress'
        keypress(varargin{1},varargin{2});
        
    case 'copy'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'special object')
            return
        end
        copyobj(hnd);
        
    case 'copy all'
        hnd = finddobj('special object');
        for i = 1:length(hnd)
            copyobj(hnd(i));
        end
    case 'edit bargraph'
        bardlg('all');
end

function r = unitrotate(unt,indx,val);

eu = unit2euler(unt);
eu(indx) = eu(indx)+val;
r = euler2unit(eu);


function cleardata(hnd);
for i = 1:length(hnd)
    ud = get(hnd(i),'userdata');
    for d = 1:length(ud.data)
        ud.data(d).ort = [];
        ud.data(d).dis = [];
    end
    set(hnd(i),'userdata',ud);
end

function stick(varargin);
if nargin == 0
    hnd = finddobj('special object');
else
    hnd = varargin{1};
end

for i = 1:length(hnd);
    sud = get(hnd(i),'userdata');
    for d = 1:length(sud.data)
        ac = sud.data(d).actor;
        part = sud.data(d).segment;
        hd = findpart(ac,'head');
        hud = get(hd,'userdata');
        sud.data(d).ort = getfield(hud.currentorientation,part);
        sud.data(d).dis = getfield(hud.currentposition,part);
    end
    set(hnd(i),'userdata',sud);
    calculateobject(hnd(i));
end


function calculateobject(hnd)
gunit = [1 0 0;0 1 0;0 0 1];
ud = get(hnd,'userdata');
switch ud.fxn
    case 'angle'
        vert = ud.data(1).dis;
        o1 = ud.data(2).dis;
        o2 = ud.data(3).dis;
        a = angle(o1-vert,o2-vert);
        
        dis = vert;
        vec1 = o1-vert;
        vec2 = o2-vert;

        m1 = sqrt(vec1*vec1');
        m2 = sqrt(vec2*vec2');
        vec3 = (vec2/m2)*m1;
        i = vec1;
        k = cross(i,vec2);
        j = cross(i,k);
        unt = makeunit([i;j;k]);
        vr = ctransform(gunit,unt,[vec1;vec3]);
        vr = [0 0 0;vr];
        tpvr = vr;
        btvr = vr;
        tpvr(:,3) = 7;
        btvr(:,3) = -7;
        vr = [tpvr;btvr];
        vr = ctransform(unt,gunit,vr);
        vr(:,1) = vr(:,1)+dis(1);
        vr(:,2) = vr(:,2)+dis(2);
        vr(:,3) = vr(:,3)+dis(3);
        fc = [1 2 3 1;1 4 5 2;1 4 6 3;1 2 2 2;2 3 6 5;5 6 4 4];
        set(hnd,'vertices',vr,'faces',fc);
        lhnd = findobj(finddobj('graph'),'tag','angle','type','line');
        if ~isempty(lhnd);
            frm = finddobj('frame','number');
            yd = get(lhnd,'ydata');
            if frm < length(yd) & frm > 1
                yd(frm) = a;
                set(lhnd,'ydata',yd);
            end
        end

    case 'angle minus 90'
        vert = ud.data(1).dis;
        o1 = ud.data(2).dis;
        o2 = ud.data(3).dis;

        dis = vert;
        vec1 = o1-vert;
        vec2 = o2-vert;

        m1 = sqrt(vec1*vec1');
        m2 = sqrt(vec2*vec2');
        vec3 = (-vec2/m2)*m1;
        i = vec1;
        k = cross(i,vec2);
        j = cross(i,k);
        unt = makeunit([i;j;k]);
        vr = ctransform(gunit,unt,[vec1;vec3]);
        vr(2,:) = vecrotate(vr(2,:),-90,'z');
        vr = [0 0 0;vr];
        tpvr = vr;
        btvr = vr;
        tpvr(:,3) = 8;
        btvr(:,3) = -8;
        vr = [tpvr;btvr];
        vr = ctransform(unt,gunit,vr);
        vr(:,1) = vr(:,1)+dis(1);
        vr(:,2) = vr(:,2)+dis(2);
        vr(:,3) = vr(:,3)+dis(3);
        fc = [1 2 3 1;1 4 5 2;1 4 6 3;1 2 2 2;2 3 6 5;5 6 4 4];
        set(hnd,'vertices',vr,'faces',fc);

    case 'global angle'
        vert = ud.data(1).dis;
        o1 = ud.data(2).dis;

        dis = vert;
        vec1 = o1-vert;
        vec2 = -vec1;
        vec2(2:3) = 0;

        m1 = sqrt(vec1*vec1');
        m2 = sqrt(vec2*vec2');
        vec3 = (-vec2/m2)*m1;
        i = vec1;
        k = cross(i,vec2);
        j = cross(i,k);
        unt = makeunit([i;j;k]);
        vr = ctransform(gunit,unt,[vec1;vec3]);
        vr(2,:) = vecrotate(vr(2,:),-90,'z');
        vr = [0 0 0;vr];
        tpvr = vr;
        btvr = vr;
        tpvr(:,3) = 8;
        btvr(:,3) = -8;
        vr = [tpvr;btvr];
        vr = ctransform(unt,gunit,vr);
        vr(:,1) = vr(:,1)+dis(1);
        vr(:,2) = vr(:,2)+dis(2);
        vr(:,3) = vr(:,3)+dis(3);
        fc = [1 2 3 1;1 4 5 2;1 4 6 3;1 2 2 2;2 3 6 5;5 6 4 4];
        set(hnd,'vertices',vr,'faces',fc);

    case 'bargraph'
        gunit = [1 0 0;0 1 0;0 0 1];
        dis = ud.data.dis;
        ort = ud.data.ort;
        rdis = ud.rdis;
        rort = ud.rort;
        coeff = ud.coeff;
        movevert = ud.movevert;
        ydata = ud.ydata;
        indx = finddobj('frame','number');
        indx = min(max(1,indx),length(ydata));
        yd = ydata(indx)*coeff(1) + coeff(2);
        vr = ud.vertices;
        vr(movevert,3) = yd;
        %rort is the relative transformation from ort
        %therfore we must convert rort into the global domain

        rort = ctransform(ort,gunit,rort);
        vr = ctransform(ort,gunit,ctransform(rort,ort,vr));
        rdis = ctransform(ort,gunit,rdis);
        dis = dis+rdis;
        vr(:,1) = vr(:,1)+dis(1);
        vr(:,2) = vr(:,2)+dis(2);
        vr(:,3) = vr(:,3)+dis(3);
        set(hnd,'vertices',vr,'faces',ud.faces);
   
        
    case 'trace'
        tvr = get(hnd,'vertices');
        tfc = get(hnd,'faces');
        
        ac = ud.data(1).actor;
        bp = ud.data(1).segment;
        bp = findpart(ac,bp);
        vr = get(bp,'vertices');
        fc = get(bp,'faces');
        if isempty(tvr)
            lvr = 0;
        else
            lvr = length(tvr(:,1));
        end
        fc = fc+lvr;        
        tvr = [tvr;vr];
        tfc = [tfc;fc];
        fclr = get(bp,'facecolor');
        eclr = get(bp,'edgecolor');
        flgth = get(bp,'facelighting');
        set(hnd,'vertices',tvr,'faces',tfc,'facecolor',fclr,'edgecolor',eclr,'facelighting',flgth);
        
    case 'groot suntay (global)'
        ort = ud.data(1).ort;
        dis = ud.data(1).dis;
        rdis = ud.rdis;
        coeff = ud.coeff;
        [vr,fc] = grootsuntay(ort,dis,rdis,coeff);
        set(hnd,'vertices',vr,'faces',fc);
        
    case 'groot suntay (local)'
        dort = ud.data(1).ort;
        ddis = ud.data(1).dis;
        rdis = ud.rdis;
        coeff = ud.coeff;
        port = ud.data(2).ort;
        [vr,fc] = grootsuntay(dort,ddis,rdis,coeff,port);
        set(hnd,'vertices',vr,'faces',fc);
    case 'orientation'
        ort = ud.data(1).ort;
        dis = ud.data(1).dis;
        rdis = ud.rdis;
        coeff = ud.coeff;
        [vr,fc,cdata] = orientation(ort,dis,rdis,coeff);
        set(hnd,'vertices',vr,'faces',fc,'cdata',cdata,'facecolor','flat','edgecolor','none','facelighting','gouraud');
        
    case 'skeleton'
        ac = ud.data(1).actor;
        [vr,fc] = skeleton(ac,ud.coeff);
        set(hnd,'vertices',vr,'faces',fc,'facecolor',[.2 .2 .2],'edgecolor','none');
end

function hnd = objectlist

hnd = findobj(finddobj('figure'),'style','pushbutton','tag','specialobject');

function newlist(ac,sg)
if isempty(objectlist)
    pos = [.8 .1 .2 .1];
else
    pos = [.8 length(objectlist)*.1+.1 .2 .1];
end
uicontrol('parent',finddobj('figure'),'units','normalized','position',pos,'backgroundcolor',[0 0 0],'foregroundcolor',[0 1 0],...
    'tag','specialobject','string',sg,'userdata',ac,'buttondownfcn','specialobject(''delete pushbutton'')','enable','inactive');


function keypress(hnd,cky)
ax = finddobj('axes');
[md,val] = currentunits;
dval = finddobj('units','displacement','number');
rval = finddobj('units','rotation','number');
vval = finddobj('units','volume','number');
ud = get(hnd,'userdata');
prt = findpart(ud.data(1).actor,ud.data(1).segment);
hd = findpart(ud.data(1).actor,'head');
hud = get(hd,'userdata');
pdis = getfield(hud.currentposition,ud.data(1).segment);

switch cky
    case 'c'
        switch ud.fxn
            case 'bargraph'
                sp = finddobj('special object');
                for i = 1:length(sp)
                    ud = get(sp(i),'userdata');
                    if strcmp(ud.fxn,'bargraph');
                        ud.coeff(1) = ud.coeff(1)+vval;
                        set(sp(i),'userdata',ud);
                    end
                end
                stick;
                return
        end
    case 'q'
        set(gca,'cameraupvector',-get(gca,'cameraupvector'));
    case 'r'
        if isfield(ud,'coeff');
            ud.coeff = ud.coeff+vval;
        elseif isfield(ud,'movevert')
            volume(hnd,vval,'increase');
        end               
        %button 4
    case 'e'
        if isfield(ud,'coeff');
            ud.coeff = ud.coeff-vval;
        elseif isfield(ud,'movevert')
            volume(hnd,vval,'decrease');
        end
        
        %button 3
    case 'w'
       
    case 'uparrow'
        if isfield(ud,'rdis')
            ud.rdis(1) = ud.rdis(1)+dval;
        end
    case 'downarrow'
        if isfield(ud,'rdis')
            ud.rdis(1) = ud.rdis(1)-dval;
        end        
    case 'leftarrow'
        if isfield(ud,'rdis')
            ud.rdis(2) = ud.rdis(2)-dval;
        end
    case 'rightarrow'
        if isfield(ud,'rdis')
            ud.rdis(2) = ud.rdis(2)+dval;
        end
    case 'home'
        if isfield(ud,'rdis')
            ud.rdis(3) = ud.rdis(3)+dval;
        end
    case 'end'
        if isfield(ud,'rdis')
            ud.rdis(3) = ud.rdis(3)-dval;
        end
    case '6'
        if isfield(ud,'rort')
            if strcmp(md,'rotation');
                ud.rort = vecrotate(ud.rort,rval,'x');
            else
                ud.rort = [0 1 0;0 0 1;-1 0 0];
            end
        end

    case '4'
        if isfield(ud,'rort')        
            if strcmp(md,'rotation');
                ud.rort = vecrotate(ud.rort,-rval,'x');
            else
                ud.rort = [0 1 0;0 0 1;1 0 0];
            end
        end

    case '2'
        if isfield(ud,'rort')
            if strcmp(md,'rotation');
                ud.rort = vecrotate(ud.rort,rval,'y');
            else
                ud.rort = [1 0 0;0 0 1;0 1 0];
            end
        end

    case '8'
        if isfield(ud,'rort')
            if strcmp(md,'rotation');
                ud.rort = vecrotate(ud.rort,-rval,'y');
            else
                ud.rort = [1 0 0;0 0 1;0 -1 0];
            end
        end

    case 'a'
        if isfield(ud,'rort')
            if ud.rort(3,3)== 1
                ud.rort = [1 0 0;0 1 0;0 0 -1];
            else
                ud.rort = [1 0 0;0 1 0;0 0 1];
            end
        end

    case 'backspace'
        delete(hnd);
        set(finddobj('current object'),'string','');
        return
    case 'escape'
        ud = get(hnd,'userdata');
        ac = ud.data(1).actor;
        set(finddobj('current object'),'string',ac);
        delete(finddobj('special object'));
        return
    otherwise
        return
end

set(hnd,'userdata',ud);
stick;


function copyobj(hnd);

ud = get(hnd,'userdata');

if isfield(ud,'rdis');
    %displacing the object so it is visible'
    
    dis = max(ud.vertices(:,1))-min(ud.vertices(:,1));
    dis = [dis 0 0];            
    dis = ctransform(ud.rort,ud.data.ort,dis);
    dis = ctransform(ud.data.ort,[1 0 0;0 1 0;0 0 1],dis);
    ud.rdis = ud.rdis-dis;
end
tg = findnewtag(get(hnd,'tag'));
hnd = defaultobj(ud,tg);


function hnd = defaultobj(ud,tg,varargin);


x = .5;
vr = [-x -x 0;x -x 0;x x 0;-x x 0;...
    -x -x 1;x -x 1;x x 1;-x x 1];

fc = [1 2 3 4;1 2 6 5;1 4 8 5;7 8 4 3;7 6 2 3;5 6 7 8];
if strcmp(ud.fxn,'bargraph');
    ac = ud.data(1).actor;
    part = ud.data(1).segment;
    obj = findpart(ac,part);
    ovr = get(obj,'vertices');
    indx = closest(get(gca,'cameraposition'),ovr)
    hd = findpart(ac,'head');
    hud = get(hd,'userdata');
    jpos = getfield(hud.currentposition,part);
    jort = getfield(hud.currentorientation,part);
    delta = ovr(indx,:)-jpos;
    delta = ctransform([1 0 0;0 1 0;0 0 1],jort,delta);
    ud.rdis = delta;
    ud.rort = [1 0 0;0 1 0;0 0 1];
    ud.coeff = [.1 0];
    ud.ydata = 20;
    ud.vertices = vr;
    ud.movevert = (5:8);
    ud.faces = fc;
    ud.keywords = {};
    fclr = [1 0 0];
    eclr = [0 0 0];
elseif strcmp(ud.fxn,'groot suntay (local)') | strcmp(ud.fxn,'orientation') | strcmp(ud.fxn,'groot suntay (global)')
    ud.coeff = 50;
    ud.rdis = [0 0 0];
    fclr = [0 1 1];
    eclr = [1 1 0];
else
    fclr = [0 1 1];
    eclr = [1 1 0];
end
hnd = patch('parent',finddobj('axes'),'userdata',ud,'facecolor',fclr,'edgecolor',eclr,...
    'buttondownfcn','specialobject(''buttondown'')','tag',findnewtag(tg),'clipping','off','vertices',[],'faces',[],...
    'createfcn','specialobject(''createfcn'')');
if nargin == 3
    prop = varargin{1};
    if isstruct(prop)
        fld = fieldnames(prop);
        if isfield(prop,'facecolor')
            set(hnd,'facecolor',prop.facecolor);
        end
        if isfield(prop,'edgecolor')
            set(hnd,'edgecolor',prop.edgecolor);
        end
    end
end
stick;


function r = findnewtag(tg);
ax = finddobj('axes');
indx = 0;
ntg = tg;
while 1
    if isempty(findobj(ax,'tag',ntg))
        break
    else
        indx = indx+1;
        ntg = [tg,num2str(indx)];
    end
end
        
r = ntg;
           

function volume(hnd,val,d)

ud = get(hnd,'userdata');
vr = ud.vertices;
vec = vr;
vec(:,3) = 0;
vec = makeunit(vec);
vec = vec*val;

switch d
    case 'increase'
        ud.vertices = vr+vec;               
    case 'decrease'
        ud.vertices = vr-vec;
end

set(hnd,'userdata',ud);
stick(hnd);
        

function [vr,fc] = grootsuntay(ort,dis,rdis,coeff,port)

gunit = [1 0 0;0 1 0;0 0 1];
rdis = ctransform(ort,gunit,rdis);
dis = dis+rdis;
if nargin == 4
    mir = makeunit(gunit.*ort)*coeff;
else
    mir = port*coeff;
end

fax = makeunit(cross(ort(3,:),mir(1,:)))*coeff;
ort = ort*coeff;


[flx,ffc] = pie([fax;mir(3,:)],dis,coeff);
[abd,afc] = pie([ort(3,:);mir(1,:)],dis,coeff);
[tw,tfc] = pie([fax;ort(1,:)],dis,coeff);
%vr = [flx;abd;tw];
%lf = length(flx(:,1));
%la = length(abd(:,1));

%fc = [ffc;afc+lf;tfc+lf+la];
vr = tw;
fc = tfc;

function [vr,fc] = pie(vec,dis,coeff);
vec = makeunit(vec)*coeff;

ang = angle(vec(1,:),vec(2,:));
inc = ang/15;
i = vec(1,:);
k = cross(vec(1,:),vec(2,:));
j = cross(i,k);

if dot(vec(2,:),j)<0
    neg = -1;
else
    neg = 1;
end

ang = (0:inc:ang)*neg;

nvec = vecrotate([coeff 0 0],ang,'z');
unt = makeunit([i;j;k]);
nvec = ctransform(unt,[1 0 0;0 1 0;0 0 1],nvec);
nvec = [0 0 0;nvec];
nvec(:,1) = nvec(:,1)+dis(1);
nvec(:,2) = nvec(:,2)+dis(2);
nvec(:,3) = nvec(:,3)+dis(3);

vr = nvec;
[rw,cl] = size(nvec);
fc = ones(rw-2,1);
fc(:,2) = (2:rw-1);
fc(:,3) = fc(:,2)+1;



function r = angle(m1,m2)

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));

r = r*180;
r = r/pi;





function [vr,fc,cdata] = orientation(ort,dis,rdis,coeff);



rdis = ctransform(ort,[1 0 0;0 1 0;0 0 1],rdis);
dis = dis+rdis;
ort = ort*coeff;
[v1,f1] = arrow(dis,ort(1,:),10);
[v2,f2] = arrow(dis,ort(2,:),10);
[v3,f3] = arrow(dis,ort(3,:),10);

lv1 = length(v1(:,1));
lv2 = length(v2(:,1));
f2 = f2+lv1;
f3 = f3+lv1+lv2;


vr = [v1;v2;v3];
fc = [f1;f2;f3];
cdata1(:,:,1) = ones(1,length(f1(:,1)));
cdata1(:,:,2) = zeros(1,length(f1(:,1)));
cdata1(:,:,3) = zeros(1,length(f1(:,1)));

cdata2(:,:,1) = zeros(1,length(f2(:,1)));
cdata2(:,:,2) = ones(1,length(f2(:,1)));
cdata2(:,:,3) = zeros(1,length(f2(:,1)));

cdata3(:,:,1) = zeros(1,length(f3(:,1)));
cdata3(:,:,3) = ones(1,length(f3(:,1)));
cdata3(:,:,2) = zeros(1,length(f3(:,1)));
cdata = [cdata1,cdata2,cdata3];


function r = angle(m1,m2)

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));

r = r*180;
r = r/pi;

function [vr,fc] = skeleton(ac,coeff)

linkseg = {{'Rfoot';'Rshank'},{'Rshank';'Rthigh'},{'Rthigh';'pelvis'},{'Lfoot';'Lshank'},{'Lshank';'Lthigh'},{'Lthigh';'pelvis'},...
    {'pelvis';'trunk'},{'Rhand';'Rforearm'},{'Rforearm';'Rupperarm'},{'Rupperarm','trunk'},...
    {'Lhand';'Lforearm'},{'Lforearm';'Lupperarm'},{'Lupperarm','trunk'},{'trunk','neck'},{'neck','head'}};

hd = findpart(ac,'head');
dis = get(hd,'userdata');
dis = dis.currentposition;
vr = [];
fc = [];
for i = 1:length(linkseg)
    seg = linkseg{i};
    pt = findpart(ac,seg{2});
    if get(pt,'facealpha') > 0
        pos1 = getfield(dis,seg{1});
        pos2 = getfield(dis,seg{2});
        [vr,fc] = addsegment(vr,fc,pos1,pos2,coeff);
    end
end

function [nvr,nfc]= addsegment(vr,fc,pos1,pos2,coeff)

k = pos2-pos1;
mg = sqrt(k*k');
k = k/mg;
if k == [0 0 1]
    i = [1 0 0];
    j = [0 1 0];
else
    i = cross(k,[0 0 1]);
    j = cross(i,k);
end
unt= makeunit([i;j;k]);

if isempty(vr)
    foffset = 0;
else
    foffset = length(vr(:,1));
end
[v,f] = mycylinder(coeff,mg);
v = ctransform(unt,[1 0 0;0 1 0;0 0 1],v);
v(:,1) = v(:,1)+pos1(1);
v(:,2) = v(:,2)+pos1(2);
v(:,3) = v(:,3)+pos1(3);

nvr = [vr;v];
nfc = [fc;f+foffset];

function [v,f] = mycylinder(r,lgth)

[x,y,z] = cylinder(r,10);
x = x(1,:)';
y = y(1,:)';
z = z(1,:)';
b = [x,y,z];
t = [x,y,z+lgth];
lb = length(b(:,1));
f = [(1:lb-1)',(2:lb)',(lb+2:2*lb)',(lb+1:2*lb-1)'];
v = [b;t];



    