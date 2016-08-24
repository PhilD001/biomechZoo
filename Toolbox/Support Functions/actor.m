function varargout = actor(action,varargin)

switch action

    case 'create'
        fl = varargin{1};
        if nargin <= 2
            answer = inputdlg('enter name','name');
            if isempty(answer)
                return
            elseif isempty(answer{1});
                return
            end
            nm = answer{1};
        else
            nm = varargin{2};
        end
            
        ax = finddobj('axes');
        pos = [mean(get(ax,'xlim')),mean(get(ax,'ylim')),mean(get(ax,'zlim'))];
        hnd = bodyfxn('create',fl,ax,nm,pos);
        set(hnd,'buttondownfcn','actor(''buttondown'')','linewidth',.1);
        set(finddobj('current object'),'string',nm);
        varargout{1} = hnd;
        varargout{2} = nm;
        mark(nm,1);

    case 'buttondown'
        ismov = cameraman('buttondown');
        ac = get(gcbo,'tag');
        bp = get(gcbo,'userdata');
        if isstruct(bp)
            bp = 'head';
        end        
        ahnd = finddobj('highlight');
        set(ahnd,'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        
        if strcmp(currentperson,'actor')
            set(gcbo,'facecolor',[.8 .8 .8],'edgecolor',[0 0 1],'facealpha',.5);
            actor('refresh controls');
            r = [];
            if ~ismov
                cpos = get(gca,'cameraposition');
                ctarg = get(gca,'cameratarget');
                hd = get(gca,'currentpoint');
                tl = hd(2,:);
                hd = tl+(cpos-ctarg);

                pt = get(gcbo,'vertices');
                r = point2line(pt,[tl;hd]);                
                newbomb(ac,bp,r);
            end
        end
        
        if strcmp(get(gcf,'selectiontype'),'alt');
            hd = get(gca,'currentpoint');
            hd = mean(hd);
            tl = get(gca,'cameraposition');

            pt = get(gcbo,'vertices');
            vrindx = point2line(pt,[tl;hd]);
            hd = findpart(get(gcbo,'tag'),'head');
            hud = get(hd,'userdata');
            fld = fieldnames(hud.cdata);
            for i = 1:length(fld);
                vl = getfield(hud.cdata,fld{i});
                if strcmp(vl.bodypart,bp);
                    if ~isempty(intersect(vrindx,vl.vertices))
                        cdata = get(gcbo,'facevertexcdata');
                        cdata = cdata(vrindx,:);
                        grips('data graph',vl.cdata,fld{i},cdata);
                    end
                end
            end
        else
            set(finddobj('current object'),'string',get(gcbo,'tag'));
        end
        
    case 'displace'
        displaceactor(varargin{1},varargin{2});
        
    case 'goto'
        if nargin == 3
            ac = varargin{2};
        else
            ac = finddobj('actor');
            if isempty(ac)
                return
            end
            ac = unique(get(ac,'tag'));
        end
        for i = 1:length(ac)
            mark(ac{i},varargin{1});
        end
        
        specialobject('stick');
        costume('stick');
        accessoryfxn('stick');
        gravity;

    case 'verify'
        hnd = varargin{1};
        if isnumeric(hnd);
            tg = get(hnd,'tag');
        else
            tg = hnd;
        end
        hnd = findpart(tg,'head');
        if isempty(hnd)
            varargout{1} = 0;
        else
            varargout{1} = 1;
        end

    case 'body part'
        in = varargin{1};
        varargout{1} = [];
        varargout{2} = [];

        tg = get(in,'tag');
        ud = get(in,'userdata');
        if ischar(tg) & ischar(ud)
            if ~isempty(findpart(tg,ud))
                varargout{1} = ud;
                varargout{2} = tg;
            end
        elseif ischar(tg)
            if ~isempty(findpart(tg,'head'));
                varargout{1} = 'head';
                varargout{2} = tg;
            end
        end

    case 'find part'
        nm = varargin{1};
        part = varargin{2};

        varargout{1} = findpart(nm,part);

    case 'load orientation'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        fl = varargin{1};
        t = load(fl,'-mat');

        hd = findpart(get(hnd(1),'tag'),'head');
        hud = get(hd,'userdata');
        fld = fieldnames(t.maxes);
        for i = 1:length(fld)
            vl = getfield(t.maxes,fld{i});
            hud.orientation = setfield(hud.orientation,fld{i},vl);
        end
        if ~isfield(hud,'index')
            hud.index = 1;
        end
        set(hd,'userdata',hud);

    case 'load displacement'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        fl = varargin{1};
        t = load(fl,'-mat');

        hd = findpart(get(hnd(1),'tag'),'head');
        hud = get(hd,'userdata');
        hud.displacement = t.displacement;
        set(hd,'userdata',hud);
        
    case 'load cdata'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        fl = varargin{1};
        t = load(fl,'-mat');

        hd = findpart(get(hnd(1),'tag'),'head');
        hud = get(hd,'userdata');
        hud.cdata = t.cdata.cdata;
        hud.color = t.cdata.color;
        hud.colormap = t.cdata.colormap;
        set(hd,'userdata',hud);

    case 'save displacement'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        hd = findpart(get(hnd(1),'tag'),'head');
        ud = get(hd,'userdata');
        displacement =ud.displacement;
        [f,p] = uiputfile('*.dis','save displacement');
        if f == 0
            return
        end
        cd(p)
        f = extension(f,'.dis');
        save([p,f],'displacement');

    case 'save orientation'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        hd = findpart(get(hnd(1),'tag'),'head');
        ud = get(hd,'userdata');
        maxes =ud.orientation;
        [f,p] = uiputfile('*.ort','orientation');
        if f == 0
            return
        end
        cd(p)
        f = extension(f,'.ort');
        save([p,f],'maxes');

    case 'save cdata'
        [obj,hnd] = currentobject;
        if ~strcmp(obj,'actor');
            return
        end
        hd = findpart(get(hnd(1),'tag'),'head');
        ud = get(hd,'userdata');
        cdata.cdata = ud.cdata;
        cdata.color = ud.color;
        cdata.colormap = ud.colormap;        
        
        [f,p] = uiputfile('*.cdata','save cdata');
        if f == 0
            return
        end
        cd(p)
        f = extension(f,'.cdata');
        save([p,f],'cdata');
        
            
        
    case 'filter orientation'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'actor');
            return
        end
        hd = findpart(get(hnd(1),'tag'),'head');
        ud = get(hd,'userdata');
        if ~isfield(ud,'orientation')
            return
        end
        fld = fieldnames(ud.orientation);
        for i = 1:length(fld)
            vl = getfield(ud.orientation,fld{i});
            vl = ortfilter(vl);
            ud.orientation = setfield(ud.orientation,fld{i},vl);
        end
        set(hd,'userdata',ud);
        director('cleanup');
   
    case 'rotate body'
        deg = varargin{1};
        [tp,ac] = currentobject;
        if ~strcmp(tp,'actor')
            return
        end
        ac = get(ac(1),'tag');
        hd = findpart(ac,'head');
        hud = get(hd,'userdata');
        hud.base = rotatebody(hud.base,deg);
        set(hd,'userdata',hud);
        mark(ac,finddobj('frame','number'));
        
    case 'rotate ort'
        deg = varargin{1};
        [tp,ac] = currentobject;
        if ~strcmp(tp,'actor')
            return
        end
        ac = get(ac(1),'tag');
        hd = findpart(ac,'head');
        hud = get(hd,'userdata');
        hud.orientation = rotateort(hud.orientation,deg);
        set(hd,'userdata',hud);
        mark(ac,finddobj('frame','number'));
        
    case 'flip ort'
        ax = varargin{1};
        [tp,ac] = currentobject;
        if ~strcmp(tp,'actor')
            return
        end
        ac = get(ac(1),'tag');
        hd = findpart(ac,'head');
        hud = get(hd,'userdata');
        global ort1 ort2
        ort1 = hud.orientation;
        hud.orientation = fliport(hud.orientation,ax);
        ort2 = hud.orientation;
        set(hd,'userdata',hud);
        mark(ac,finddobj('frame','number'));
           
    case 'refresh'
        ac = varargin{1};
        frm = finddobj('frame','number');
        mark(ac,frm);
        
    case 'reset controls'
        hi = finddobj('highlight');
        nm = get(hi,'tag');
        bp = get(hi,'userdata');
        if isstruct(bp);
            bp = 'head';
        end
        hd = findpart(nm,'head');
        hud = get(hd,'userdata');
        c = finddobj('controls');
        set(findobj(c,'tag','actor'),'string',nm);
        set(findobj(c,'tag','bodypart'),'string',bp);
        set(findobj(c,'tag','visible'),'userdata',[]);
        set(findobj(c,'tag','color'),'backgroundcolor',hud.color);
        set(findobj(c,'tag','cvertices'),'userdata',[]);
        set(findobj(c,'tag','cdata'),'userdata',[]);
        
    case 'refresh controls'
        hi = finddobj('highlight');
        nm = get(hi,'tag');
        bp = get(hi,'userdata');
        if isstruct(bp);
            bp = 'head';
        end
        hd = findpart(nm,'head');
        hud = get(hd,'userdata');
        c = finddobj('controls');
        set(findobj(c,'tag','actor'),'string',nm);
        set(findobj(c,'tag','bodypart'),'string',bp);        
        set(findobj(c,'tag','color'),'backgroundcolor',hud.color);        
    case 'color button'
        clr = colorpallete(get(gcbo,'backgroundcolor'));
        set(gcbo,'backgroundcolor',clr);
        ac = get(findobj(finddobj('controls'),'tag','actor'),'string');
        if isempty(ac)
            return
        end
        hd = findpart(ac,'head');
        hud = get(hd,'userdata');
        hud.color = clr;
        set(hd,'userdata',hud);
        mark(ac,finddobj('frame','number'));
        
    case 'bomb buttondown'
        ismov = cameraman('buttondown');
     
        switch get(gcf,'selectiontype');
            case 'alt'
                delete(gcbo);
            case 'open'
                hnd = findobj(finddobj('controls'),'tag','cvertices');
                bm = finddobj('bomb');
                vindex = [];
                for i = 1:length(bm);
                    ud = get(bm(i),'userdata');
                    vindex = [vindex;{num2str(ud.vindex)}];
                end
                set(hnd,'string',unique(vindex),'value',1);
        end


    case 'import cdata'
        [vec,nm] = uigetstruct;
        if isempty(vec)
            return
        elseif iscell(vec);
            vec = vec{1};
        elseif isstruct(vec)
            vec = findfield(vec,'line');
        end
        if isempty(vec)
            return
        end
        vec = mynormalize(vec,(0:1:100));
        set(gcbo,'userdata',vec,'foregroundcolor',[0 1 0],'string',nm{1});
        
    case 'import cmap'
        r = cdata2cmap;
        set(gcbo,'userdata',r,'foregroundcolor',[0 1 0]);
        
    case 'enter controls'
        c = finddobj('controls');
        ac = get(findobj(c,'tag','actor'),'string');
        bp = get(findobj(c,'tag','bodypart'),'string');
        vhnd = findobj(c,'tag','visible');
        vis = get(vhnd,'userdata');
        clr = get(findobj(c,'tag','color'),'backgroundcolor');
        cvhnd = findobj(c,'tag','cvertices');
        ccell = get(cvhnd,'string');
        cvr = [];
        for i = 1:length(ccell)
            cvr = [cvr;str2num(ccell{i})];
        end
        coeff = str2num(get(findobj(c,'tag','coeff'),'string'));
        chnd = findobj(c,'tag','cdata');
        cdata = get(chnd,'userdata');
        cmhnd = findobj(c,'tag','cmap');
        cmap = get(cmhnd,'userdata');
        
        hd = findpart(ac,'head');
        if isempty(hd)
            return
        end
        hud = get(hd,'userdata');
        if ~isempty(cdata) & ~isempty(cvr) & ~isempty(coeff) & ~isempty(bp)
            lc = length(hud.cdata)+1;
            nm = get(chnd,'string');
            pl.bodypart = bp;
            pl.vertices = cvr;
            pl.coeff = coeff;
            pl.cdata = cdata;
            hud.cdata = setfield(hud.cdata,nm,pl);
            set(chnd,'userdata',[],'foregroundcolor',[1 1 1],'string','import');
            set(cvhnd,'string',{});
        end
        
        if ~isempty(cmap)
            hud.colormap = cmap;
            set(cmhnd,'foregroundcolor',[1 1 1]);
        end
        set(hd,'userdata',hud);
        
    case 'ramp speed'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'actor')
            return
        end
        r = inputdlg({'speed (km/hr)';'stride rate (strides/min)';'sample rate (samples/stride)'});
        spd = str2num(r{1});
        strt = str2num(r{2});
        smp = str2num(r{3});
      
        %we need distance per sample
        dps = (100000*spd/3600); %cm/second  
        dps = dps/(strt*smp/60); %cm/sample
        ac = get(hnd(1),'tag');
        hd = findpart(ac,'head');
        hud = get(hd,'userdata');
        dis = zeros(smp+1,3);
        dis(:,2) = (-(0:length(dis(:,1))-1)*dps)';
        hud.displacement = dis;
        set(hd,'userdata',hud);
end




function mark(ac,frm)
hd = findpart(ac,'head');
hud = get(hd,'userdata');
hnd = findobj(finddobj('actor'),'tag',get(hd,'tag'));
ort = [];
dis = [0 0 0];
if isfield(hud,'orientation');
    fld = fieldnames(hud.orientation);
    for i = 1:length(fld)
        vl = getfield(hud.orientation,fld{i});
        indx = min(max(frm,1),length(vl));
        if ~max(max(isnan(vl{indx})));
            ort = setfield(ort,fld{i},vl{indx});
        end
    end
end
if isfield(hud,'displacement');
    if ~isempty(hud.displacement);
        indx = min(max(frm,1),length(hud.displacement(:,1)));
        dis = hud.displacement(indx,:);
    end
end
[jpos,jort] = bodyfxn('rebuild',hnd,hud.base,ort,dis,hud.color);
fld = fieldnames(hud.cdata);
for i = 1:length(fld);
    vl = getfield(hud.cdata,fld{i});
    hnd = findpart(ac,vl.bodypart);
    cdata = vl.cdata;
    coeff = vl.coeff;
    f = min(max(frm,1),length(cdata));
    num = (cdata(f)/coeff(1))+coeff(2);
    clr = getcolor(num,hud.colormap);
    fvcdata =get(hnd,'facevertexcdata');
    fvcdata(vl.vertices,1) = clr(1);
    fvcdata(vl.vertices,2) = clr(2);
    fvcdata(vl.vertices,3) = clr(3);
    set(hnd,'facevertexcdata',fvcdata);
    ln = findobj(gcf,'type','line','tag',fld{i});
    set(ln,'color',clr);
end


hud.currentposition = jpos;
hud.currentorientation = jort;
set(hd,'userdata',hud);




function r = ktransform(ort1,ort2,m)

mg = diag(sqrt(m*m'));
newm = ctransform(ort1,ort2,m);
nmg = diag(sqrt(newm*newm'));
r = (newm./[nmg,nmg,nmg]).*[mg,mg,mg];



function r = ortfilter(vl)

eu = [];
for i = 1:length(vl);
    unt = vl{i};
    eplate = unit2euler(unt);
    eu = [eu;eplate];
end
filt = filtermenu('get filter');
efilt = [];
for i = 1:3
    fplate = filtermenu('filter',eu(:,i),filt);
    efilt = [efilt,fplate];
end
r = [];
for i = 1:length(efilt(:,1))
    r = [r;{euler2unit(efilt(i,:))}];
end
    
function r = rinterpolate(ud)

r = ud;
ort = r.orientation;
xd = r.mark;

fld = fieldnames(ort);

for i = 1:length(fld);    
    vl = getfield(ort,fld{i});
    nxd = min(max(xd,1),length(vl));
    if nxd(1)==nxd(2)
        continue
    end
    yd = vl(nxd);
    ixd = (nxd(1):nxd(2));
    vl(ixd) = rinterp(nxd,yd,ixd);
    ort = setfield(ort,fld{i},vl);
end

r.orientation = ort;


function r = rotateort(s,deg)
r = s;
if ~isstruct(r)
    return
end
fld = fieldnames(r)
for i = 1:length(fld)
    vl = getfield(r,fld{i});
    if length(vl) == 1
        continue
        %the field is a default field
    end
    for j = 1:length(vl)
        vl{j} = vecrotate(vl{j},deg,'z');
    end
    r = setfield(r,fld{i},vl);
end
        
function r = fliport(s,ax)
r = s;
if ~isstruct(r)
    return
end
fld = fieldnames(r);
for i = 1:length(fld)
    vl = getfield(r,fld{i});
    if length(vl) == 1
        continue
        %the field is a default field
    end    
    for j = 1:length(vl)
        unt = vl{j};
        switch ax
            case 'x'
                unt(1,:) = -unt(1,:);
            case 'y'
                unt(2,:) = -unt(2,:);
            case 'z'
                unt(3,:) = -unt(3,:);            
        end
        vl{j} = unt;
    end
    r = setfield(r,fld{i},vl);
end

        
        

function bm = newbomb(ac,bp,indx)

[x,y,z] = sphere(20);
bud.actor = ac;
bud.bodypart = bp;
bud.vindex = indx;
bud.xdata = x/3;
bud.ydata = y/3;
bud.zdata = z/3;

bm = surface('parent',finddobj('axes'),'xdata',x,'ydata',y,'zdata',z,'tag','bomb',...
    'facecolor',[1 0 0],'edgecolor','none','userdata',bud,'clipping','off','createfcn','costume(''bomb createfcn'')','buttondownfcn','actor(''bomb buttondown'')');
refreshbomb;

function refreshbomb
bm = finddobj('bomb');
for i = 1:length(bm);
    ud = get(bm(i),'userdata');
    bp = findpart(ud.actor,ud.bodypart);
    vr = get(bp,'vertices');
    dis = vr(ud.vindex,:);
    xd = ud.xdata+dis(1);
    yd = ud.ydata+dis(2);
    zd = ud.zdata+dis(3);
    set(bm(i),'xdata',xd,'ydata',yd,'zdata',zd);
end

function r = cdata2cmap
[f,p] = uigetfile('*.bmp');
cdata = imread([p,f]);
[rw,cl,dim] = size(cdata);
if dim ~= 3
    errordlg('image must be RGB format');
    return
end
cl = ceil(cl/2);
cmap = [];
for i = 1:rw;
    clr = [cdata(i,cl,1),cdata(i,cl,2),cdata(i,cl,3)];
    if clr == [0 0 0]
        continue;
    elseif isempty(cmap);
        cmap = clr;
        continue
    elseif cmap(end,:)== clr
        continue
    end
    cmap = [cmap;clr];
end
r = double(cmap)/255;
        

function r = getcolor(num,cmap)

num = min(max(num,0),1);

if num <= 0
    r = cmap(end,:);
    return
elseif num >= 1
    r = cmap(1,:);
    return
end

lcm = length(cmap(:,1));
delta = 1/lcm;
vec = (lcm-1:-1:0)/(lcm-1);
indx = abs(vec-num);
indx = find(indx == min(indx));
r = cmap(indx,:);

function displaceactor(ac,dis)
hd = findpart(ac,'head');
hnd = findobj(finddobj('axes'),'tag',ac);
for i = 1:length(hnd)
    vr = displacemat(get(hnd(i),'vertices'),dis);
    set(hnd(i),'vertices',vr);
end
hud = get(hd,'userdata');
hud.displacement = displacemat(hud.displacement,dis);
fld = fieldnames(hud.currentposition);
for i = 1:length(fld)
    hud.currentposition = setfield(hud.currentposition,fld{i},getfield(hud.currentposition,fld{i})+dis);
end
set(hd,'userdata',hud);

hnd = hud.associateobj;
for i = 1:length(hnd)
    vr = get(hnd(i),'vertices');
    vr = displacemat(vr,dis);
    set(hnd(i),'vertices',vr);
end

function gravity
global producer
ac = finddobj('actor');
tg = get(ac,'tag');
tg = unique(tg);
ax = finddobj('axes');
if isfield(producer.grips,'invisible');
    ihnd = producer.grips.invisible;
else
    ihnd = [];
end

for i = 1:length(tg)     
    hd = findpart(tg{i},'head');
    hud = get(hd,'userdata');
    hnd = findobj(ax,'tag',tg{i});
    hnd = setdiff(union(hnd,hud.associateobj),ihnd);
    vr = get(hnd,'vertices');
    vr = cell2mat(vr);
    mz = -min(vr(:,3));
    actor('displace',tg{i},[0 0 mz]);    
end
