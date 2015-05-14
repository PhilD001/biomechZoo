function varargout = costume(action,varargin)
switch action
    case 'keypress'        
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'costume');
            return
        end
        cky = get(gcf,'currentkey');
        if isglobalkey(cky)
            return
        end
        
    case 'createfcn'
        ud = get(gcbo,'userdata');
        hd = findpart(ud.actor,'head');
        if isempty(hd)
            return
        end
        hud = get(hd,'userdata');
        hud.associateobj = [hud.associateobj;gcbo];
        set(hd,'userdata',hud);  
        ud.parent = hd;
        set(gcbo,'userdata',ud);
        
    case 'deletefcn'
        ud = get(gcbo,'userdata');        
        hud = get(ud.parent,'userdata');
        hud.associateobj = setdiff(hud.associateobj,gcbo);
        set(ud.parent,'userdata',hud);  
    case 'stick'
        if nargin >= 2
            hnd = varargin{1};
        else
            hnd = finddobj('costume');
        end
        for i = 1:length(hnd)
            stick(hnd(i));
        end
        
    case 'camera rotated'
        cpos = get(gca,'cameraposition');
        cp = finddobj('costume pointer');
        ud = get(cp,'userdata');
        if isempty(ud.costume)
            return
        end
        vr = get(ud.costume,'vertices');
        indx = closest(cpos,vr);
        if isempty(ud.vindex)
           ud.vindex = indx;
        else
            if ud.vindex ~= indx
                ud.vindex = indx;
            else
                return
            end
        end
        set(cp,'userdata',ud);
        refreshpointer;
        
    case 'buttondown'
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        set(finddobj('highlight'),'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);        
        if ~strcmp(currentperson,'costume')
            cameraman('buttondown');
            return
        end
        ptr = finddobj('costume pointer');
        if isempty(ptr)
           ptr = create(gcbo);
        end
        pud = get(ptr,'userdata');
        pud.costume = gcbo;        
        set(ptr,'userdata',pud);
        set(gcbo,'edgecolor',[0 0 1]);
                        
        
        colordobj(gcbo);
        ismov = cameraman('buttondown');
        if ~strcmp(currentperson,'costume');
            delete(finddobj('costume pointer'));
            delete(finddobj('bomb',1));
            if strcmp(get(gcf,'selectiontype'),'alt');
                set(gcbo,'edgecolor',get(gcbo,'facecolor'),'facealpha',.5);
            else
                set(gcbo,'edgecolor','none','facealpha',1);
            end
            return
        end
        if ~ismov
            cpos = get(gca,'cameraposition');
            ctarg = get(gca,'cameratarget');
            hd = get(gca,'currentpoint');
            tl = hd(2,:);
            hd = tl+(cpos-ctarg);

            pt = get(gcbo,'vertices');
            r = point2line(pt,[tl;hd]);
            ptr = finddobj('costume pointer');
            pud = get(ptr,'userdata');
            set(ptr,'userdata',pud);
            pud.vindex(1) = r;
            set(ptr,'userdata',pud);
           
            if strcmp(get(gcf,'selectiontype'),'alt');
                bomb(r);                
            else
                deletebombs(2);
            end
            refreshpointer;
            caliper;
        end
        
        ahnd = finddobj('highlight');
        set(ahnd,'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        
    case 'save'
        if ~strcmp(get(gco,'type'),'patch')
            return
        end
        hi = finddobj('highlight');
        [tp,hnd] = currentobject;
        switch tp
            case 'actor'                
                ac = get(hi,'tag');
                part = get(hi,'userdata');
                if isstruct(part)
                    part = 'head';
                end
                hd = findpart(ac,'head');
                hud = get(hd,'userdata');
                ort = getfield(hud.currentorientation,part);
                dis = getfield(hud.currentposition,part);
                vr = get(hi,'vertices');
                vr(:,1) = vr(:,1)-dis(1);
                vr(:,2) = vr(:,2)-dis(2);
                vr(:,3) = vr(:,3)-dis(3);
                vr = ctransform([1 0 0;0 1 0;0 0 1],ort,vr);
                costume.vertices = vr;
                costume.faces = get(hi,'faces');
                costume.bodypart = part;
                str = ['save the ',part];
            case 'costume'                
                ud = get(hi,'userdata');
                hd = findpart(ud.actor,'head');
                hud = get(hd,'userdata');
                ort = getfield(hud.currentorientation,ud.bodypart);
                dis = getfield(hud.currentposition,ud.bodypart);
                vr = get(hi,'vertices');
                vr(:,1) = vr(:,1)-dis(1);
                vr(:,2) = vr(:,2)-dis(2);
                vr(:,3) = vr(:,3)-dis(3);
                vr = ctransform([1 0 0;0 1 0;0 0 1],ort,vr);
                costume.vertices = vr;
                costume.faces = get(hi,'faces');
                costume.bodypart = ud.bodypart;
                costume.color = get(hi,'facecolor');
                str = ['save the ', get(gco,'tag')];
            case 'tool'
                sculpttool('save');
                return
            otherwise
                return
        end
        [f,p] = uiputfile('*.cos',str);
        if f == 0
            return
        end
        cd(p)
        f = extension(f,'.cos');
        save([p,f],'costume');
        
    case 'quick load'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'actor')
            ac =[];
        else
            ac = get(hnd(1),'tag');
        end
        fld = uigetfolder;
        if isempty(fld)
            return
        end
        if ~strcmp(fld(end),'/');
            fld = [fld,'\'];
        end
        [f,p] = directory(fld);
        for i = 1:length(f)
            [ext,nm] = extension(f{i});
            if strcmp(ext,'.cos');
                t = load([fld,f{i}],'-mat');
                costume = t.costume;
                costume.actor = ac;
                if ~isfield(costume,'color');
                    costume.color = [.8 .8 .8];
                end                    
                createcostume(costume,nm);
            end
        end
        
    case 'load'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'actor')
            return
        else           
            ac = get(hnd(1),'tag');
        end
        flname = varargin{1};
        t = load(flname,'-mat');
        if nargin <=2
            tg = inputdlg('enter name','name');
            if isempty(tg)
                return
            end
            tg = tg{1};
        else
            tg = varargin{2};
        end
        ud = t.costume;
        ud.vertices = t.costume.vertices;
        ud.faces = t.costume.faces;
        ud.bodypart = t.costume.bodypart;
        ud.actor = ac;
        if isfield(t.costume,'color')
            ud.color = t.costume.color;
        else
            ud.color = [.8 .8 .8];
        end
        createcostume(ud,tg);
        if nargin <= 2
            set(findpart(ud.actor,ud.bodypart),'visible','off');
        end
        
    case 'load special'
        loadspecial(varargin{1})
    case 'clean'
        hnd = varargin{1};
        vhnd = finddobj('units','volume');
        ud = get(hnd,'userdata');
        if ~isfield(ud,'vertices')
            vr = get(hnd,'vertices');
            fc = get(hnd,'faces');
        else
            vr = ud.vertices;
            fc = ud.faces;
        end
        [vr,fc] = cleanpatch(vr,fc,get(vhnd,'userdata'));
        fc = rotatefaces(vr,fc,get(finddobj('axes'),'cameraposition'));
        if ~isfield(ud,'vertices')
            set(hnd,'vertices',vr,'faces',fc);
        else
            ud.vertices = vr;
            ud.faces = fc;
            set(hnd,'userdata',ud);
            stick(hnd);
        end
        
    case 'save changes'
        saveobject(varargin{1});
    case 'fabric'
        hi = finddobj('highlight');
        if ~actor('verify',hi);
            return
        end
        answer = inputdlg({'length (cm)';'width (cm)';'resolution (cm)';'name'},'fabric',1,{'30','20','1','fabric'});        
        if isempty(answer);
            return
        end        
        createfabric(str2num(answer{1}),str2num(answer{2}),str2num(answer{3}),answer{4},hi);
        
    case 'delete'
        [tp,hnd] = currentobject;
        switch tp
            case 'costume'
                ud = get(hnd,'userdata');
                set(finddobj('current object'),'string',ud.actor);
                delete(hnd);
            case 'tool'
                set(finddobj('current object'),'string','');
                delete(hnd);
        end
            
end


function stick(hnd)

ud = get(hnd,'userdata');
hd = findpart(ud.actor,'head');
if ~isempty(hd)   
    hud = get(hd,'userdata');
    ort = getfield(hud.currentorientation,ud.bodypart);
    dis = getfield(hud.currentposition,ud.bodypart);
else
    hd = findobj(finddobj('axes'),'tag',ud.bodypart);
    hud = get(hd,'userdata');
    if isempty(hud)
        return
    elseif isfield(hud,'ort');
        frm = min(finddobj('frame','number'),length(hud.ort));        
        ort = hud.ort{frm};
        dis = hud.dis(frm,:);
    else
        return
    end
end
if isfield(ud,'movevert') %changing the shape of the costume
    frm = finddobj('frame','number');
    yd = ud.ydata(min(max(frm,1),length(ud.ydata)));
    yd = yd*ud.coeff(1)+ud.coeff(2);
    vr = ud.vertices;
    vr(ud.movevert,3) = yd;
else
    vr = ud.vertices;
end

if isfield(ud,'calort');
    vr = ctransform(ud.calort,gunit,vr);
    vr = displace(vr,ud.caldis);
end
if isfield(ud,'rort')
        rort = ctransform(ort,gunit,ud.rort);
        vr = ctransform(rort,ort,vr);
end
if isfield(ud,'rdis')
    rdis = ctransform(ort,gunit,ud.rdis);
    dis = dis+rdis;
end
vr = ctransform(ort,gunit,vr);
vr = displace(vr,dis);

set(hnd,'vertices',vr,'faces',ud.faces);

function s = create(hnd)
ax = finddobj('axes');
[x,y,z] = arrow([0 0 0],[0 0 1],20);
x = x*2.5;
y = y*2.5;
z = z*2.5;
cdata = zeros(size(x));
cdata(:,:,2) = ones(size(x));
cdata(:,:,3) = cdata(:,:,1);
ud.xdata = x;
ud.ydata = y;
ud.zdata = z;

vr = get(hnd,'vertices');

ud.costume = hnd;
ud.ort = [1 0 0;0 1 0;0 0 1];
ud.vindex = min(closest(get(ax,'cameraposition'),vr));
s = surface('xdata',x,'ydata',y,'zdata',z,'userdata',ud,'tag','costumepointer','cdata',cdata,...
    'facecolor','flat','edgecolor','none','clipping','off','parent',ax,'deletefcn','delete(finddobj(''bomb''))');
refreshpointer;

function refreshpointer
s = finddobj('costume pointer');
if isempty(s)
    return
end
ud = get(s,'userdata');
if isempty(ud.costume)
    return
end
vr = get(ud.costume,'vertices');
dis = vr(ud.vindex(1),:);
gunit = [1 0 0;0 1 0;0 0 1];
[x,y,z] = mtransform(ud.ort,gunit,ud.xdata,ud.ydata,ud.zdata);
x = x+dis(1);
y = y+dis(2);
z = z+dis(3);
set(s,'xdata',x,'ydata',y,'zdata',z);
ax = finddobj('axes');
for i = 1:length(ud.vindex);
    bm = finddobj('bomb',i);
    if isempty(bm)
        [x,y,z] = sphere(20);
        bud.xdata = x/3;
        bud.ydata = y/3;
        bud.zdata = z/3;
        bud.vindex = ud.vindex(i);
        bm = surface('parent',ax,'xdata',x,'ydata',y,'zdata',z,'tag',['bomb',num2str(i)],...
            'facecolor',[1 0 0],'edgecolor','none','userdata',bud,'clipping','off','createfcn','costume(''bomb createfcn'')');
    else
        bud = get(bm,'userdata');
        bud.vindex = ud.vindex(i);
    end    
    dis = vr(ud.vindex(i),:);
    xd = bud.xdata+dis(1);
    yd = bud.ydata+dis(2);
    zd = bud.zdata+dis(3);
    set(bm,'xdata',xd,'ydata',yd,'zdata',zd,'userdata',bud);
end

deletebombs(i+1);
        



function r = isglobalkey(cky)
r = 1;
dval = finddobj('units','displacement','number');
rval = finddobj('units','rotation','number');

ptr = finddobj('costume pointer');
pud = get(ptr,'userdata');
co = pud.costume;
cud = get(co,'userdata');
vr = get(co,'vertices');
fc = get(co,'faces');

switch cky
     case 'q'
        vindex = pud.vindex;
        if length(vindex)<3
            return
        end
        findx = findface(vindex(1:3),fc);
        if isempty(findx)
            return
        end
        fplate = fc(findx(1),:);
        fplate([2,3]) = fplate([3,2]);
        fc(findx(1),:) = fplate;
        set(co,'faces',fc);
        saveobject(co);
    case 'r'
        unt = pud.ort;
        vec = [0 0 dval];
        vec = ctransform(unt,[1 0 0;0 1 0;0 0 1],vec);
        if ~iswholepatch
            vindex = unique(pud.vindex);
            if length(vindex) <= 1                
                vr(pud.vindex,1) = vr(pud.vindex,1)+vec(1);
                vr(pud.vindex,2) = vr(pud.vindex,2)+vec(2);
                vr(pud.vindex,3) = vr(pud.vindex,3)+vec(3);

                set(co,'vertices',vr);
                saveobject(co);
            elseif length(vindex) == 2
                duplicateindex(co,pud.vindex(1),pud.vindex);                
            else
                addface(co,vindex(1:3));
                saveobject(co);
            end
        else            
            cud.vertices(:,1) = cud.vertices(:,1)+vec(1);
            cud.vertices(:,2) = cud.vertices(:,2)+vec(2);
            cud.vertices(:,3) = cud.vertices(:,3)+vec(3);
            set(co,'userdata',cud);
            stick(co);
        end
        refreshpointer;
    case 'e'
        pud.ort = -pud.ort;
        set(ptr,'userdata',pud);
        refreshpointer;
    case 'w'
         cdata = get(ptr,'cdata');
         cdata = zeros(size(cdata));
        if iswholepatch           
            cdata(:,:,2) = 1;            
        else
            cdata(:,:,[1,3]) = 1;
        end
        set(ptr,'cdata',cdata);
            
        
    case 'uparrow'  
        if ~iswholepatch
            pud.vindex(1) = nextindex(vr,fc,pud.vindex(1),cky);
            set(ptr,'userdata',pud);
            refreshpointer;
        else
            cud.vertices(:,2) = cud.vertices(:,2)+dval;
            set(co,'userdata',cud);
            stick(co);
            return
        end
            
    case 'downarrow'
        if ~iswholepatch
            pud.vindex(1) = nextindex(vr,fc,pud.vindex(1),cky);
            set(ptr,'userdata',pud);
            refreshpointer;
        else
            cud.vertices(:,2) = cud.vertices(:,2)-dval;
            set(co,'userdata',cud);
            stick(co);
            return
        end
    case 'leftarrow'    
        if ~iswholepatch
            pud.vindex(1) = nextindex(vr,fc,pud.vindex(1),cky);
            set(ptr,'userdata',pud);
            refreshpointer;
        else
            cud.vertices(:,1) = cud.vertices(:,1)-dval;
            set(co,'userdata',cud);
            stick(co);
            return
        end 
    case 'rightarrow'                
        if ~iswholepatch
            pud.vindex(1) = nextindex(vr,fc,pud.vindex(1),cky);
            set(ptr,'userdata',pud);
            refreshpointer;
        else
            cud.vertices(:,1) = cud.vertices(:,1)+dval;
            set(co,'userdata',cud);
            stick(co);
            return
        end 
    case 't'                
        if ~iswholepatch
            pud.vindex(1) = nextindex(vr,fc,pud.vindex(1),cky);
            set(ptr,'userdata',pud);
            refreshpointer;
        else
            cud.vertices(:,3) = cud.vertices(:,3)+dval;
            set(co,'userdata',cud);
            stick(co);
            return
        end 
    case 'u'                
        if ~iswholepatch
            pud.vindex(1) = nextindex(vr,fc,pud.vindex(1),cky);
            set(ptr,'userdata',pud);
            refreshpointer;
        else
            cud.vertices(:,3) = cud.vertices(:,3)-dval;
            set(co,'userdata',cud);
            stick(co);
            return
        end 
    case '6'
        rotationkey(ptr,'x',rval);
    case '4'
        rotationkey(ptr,'x',-rval);
    case '2'
        rotationkey(ptr,'y',rval);
    case '8'
        rotationkey(ptr,'y',-rval);
    case 'a'       
        rotationkey(ptr,'z',rval);
    case 'backspace'
        indx = deletevertex(co,pud.vindex(1));        
        pud.vindex = min(pud.vindex,indx);
        saveobject(co);
        set(ptr,'userdata',pud);
        refreshpointer;
            
    otherwise
        r = 0;
end


function r = nextindex(vr,fc,cindx,action)
pt = vr(cindx,:);
vr(cindx,:) = inf;
ax = finddobj('axes');
cpos = get(ax,'cameraposition');
ctarg = get(ax,'cameratarget');
i = ctarg-cpos;
i(3) = 0;
k = [0 0 1];
j = cross(i,k);

unt = makeunit([i;j;k]);


vr(:,1) = vr(:,1)-pt(1);
vr(:,2) = vr(:,2)-pt(2);
vr(:,3) = vr(:,3)-pt(3);
vr = ctransform([1 0 0;0 1 0;0 0 1],unt,vr);

indx = getclosevertices(fc,cindx);
%closest vertices;
nvr = vr(indx,:);
temp = vr(indx,:);
nvr = makeunit(nvr);
switch action
    case 'uparrow'
        r = find(nvr(:,1)==max(nvr(:,1)));
    case 'downarrow'
        r = find(nvr(:,1)==min(nvr(:,1)));
    case 'rightarrow'
        r = find(nvr(:,2)==max(nvr(:,2)));
    case 'leftarrow'
        r = find(nvr(:,2)==min(nvr(:,2)));
    case 't'
        r = find(nvr(:,3)==max(nvr(:,3)));
    case 'u'
        r = find(nvr(:,3)==min(nvr(:,3)));        
end    

nvr = temp(r(1),:);
r = intersect(intersect(find(vr(:,1)==nvr(1)),find(vr(:,2)==nvr(2))),find(vr(:,3)==nvr(3)));
if length(r)>1
    mg = vr(r,:);
    mg = sqrt(diag(mg*mg'));
    r = r(find(mg==min(mg)));
end



function r = getclosevertices(fc,cindx)
indx = findvertex(cindx,fc);
m = fc(indx,:);
r = setdiff(unique([m(:,1);m(:,2);m(:,3)]),cindx);



function r = findface(fc,allfc)
r = intersect(intersect(findvertex(fc(1),allfc),findvertex(fc(2),allfc)),findvertex(fc(3),allfc));

function indx = findvertex(vr,fc)

xindx = find(fc(:,1)==vr);
yindx = find(fc(:,2)==vr);
zindx = find(fc(:,3)==vr);
indx = union(xindx,yindx);
indx = union(indx,zindx);

function indx = bomb(cindx)
if isempty(cindx)
    indx = [];
    return
end
ptr = finddobj('costume pointer');
pud = get(ptr,'userdata');
bindx = pud.vindex(2:end);
if ~isempty(intersect(bindx,cindx))
    indx = [cindx;setdiff(bindx,cindx)];
else
    indx = [pud.vindex;cindx];
end

if length(indx) > 4
    bindx = indx(2:end);
    fc = get(pud.costume,'faces');
    bindx = cleanbomb(bindx,fc);
    indx = indx(1);
    indx = [indx;bindx];
end
    

if nargout == 0
    pud.vindex = indx;
    set(ptr,'userdata',pud);    
end


function deletebombs(bindx)
ptr = finddobj('costume pointer');
pud = get(ptr,'userdata');
while 1
    bm = finddobj('bomb',bindx);
    if isempty(bm)
        break
    end
    bud = get(bm,'userdata');
    pud.vindex = setdiff(pud.vindex,bud.vindex);
    delete(bm);
    bindx = bindx+1;
end
set(ptr,'userdata',pud);


function r = findvertindex(pt,vr)

r = intersect(intersect(find(vr(:,1)==pt(1)),find(vr(:,2)==pt(2))),find(vr(:,3)==pt(3)));


function addface(hnd,index)
vr = get(hnd,'vertices');
fc = get(hnd,'faces');
if isempty(findface(index,fc))
    fc = [fc;makerow(index)];
    set(hnd,'faces',fc);
    return
end
fplate = [];
nvert = [];
m = vr(index,:);
nvert(1,:) = mean([m(1,:);m(2,:)]);
nvert(2,:) = mean([m(2,:);m(3,:)]);
nvert(3,:) = mean([m(1,:);m(3,:)]);
for i = 1:length(index);
    pt = vr(index(i),:);
    indx = findvertindex(pt,vr);
    fplate = [fplate,indx(1)];
end

%delete face
findx = findface(fplate,fc);
fc(findx,:) = [];


vr = [vr;nvert];
vindex(1) = length(vr(:,1))-2;
vindex(2) = vindex(1)+1;
vindex(3) = vindex(2)+1;
for i = 1:3 
    %adding new face
    switch i
        case 1
            nfc = [index(i),vindex(1),vindex(3)];
        case 2
            nfc = [index(i),vindex(1),vindex(2)];
        case 3
            nfc = [index(i),vindex(2),vindex(3)];
    end
    fc = [fc;nfc];    
end
fc = [fc;makerow(vindex)];
[vr,fc] = cleanpatch(vr,fc,.2);
set(hnd,'vertices',vr,'faces',fc);
    


function cindx = deletevertex(pch,vindx)
fc = get(pch,'faces');
vr = get(pch,'vertices');

findx = findvertex(vindx,fc);
%deleting the faces with this vertex

ovr = setdiff(unique(fc(findx,:)),vindx);
fc(findx,:) = [];

xindx = find(fc(:,1)>vindx);
yindx = find(fc(:,2)>vindx);
zindx = find(fc(:,3)>vindx);
fc(xindx,1) = fc(xindx,1)-1;
fc(yindx,2) = fc(yindx,2)-1;
fc(zindx,3) = fc(zindx,3)-1;
oindx = find(ovr>vindx);
ovr(oindx) = ovr(oindx)-1;
vr(vindx,:) = [];

for i = 1:length(ovr)
    if isempty(findvertex(ovr(i),fc))
        vr(ovr(i),:) = [];
        xindx = find(fc(:,1)>ovr(i));
        yindx = find(fc(:,2)>ovr(i));
        zindx = find(fc(:,3)>ovr(i));
        fc(xindx,1) = fc(xindx,1)-1;
        fc(yindx,2) = fc(yindx,2)-1;
        fc(zindx,3) = fc(zindx,3)-1;
        oindx = find(ovr>ovr(i));
        ovr(oindx) = ovr(oindx)-1;
    end
end


cindx = min(vindx,length(vr(:,1)));
set(pch,'vertices',vr,'faces',fc);

function saveobject(hnd)

ud = get(hnd,'userdata');
if ~isfield(ud,'actor')
    return
end

ac = ud.actor;
bp = ud.bodypart;
vr = get(hnd,'vertices');
fc = get(hnd,'faces');

hd = findpart(ac,'head');
hud = get(hd,'userdata');
dis = getfield(hud.currentposition,bp);
ort = getfield(hud.currentorientation,bp);

vr(:,1) = vr(:,1)-dis(1);
vr(:,2) = vr(:,2)-dis(2);
vr(:,3) = vr(:,3)-dis(3);

vr = ctransform([1 0 0;0 1 0;0 0 1],ort,vr);
ud.vertices = vr;
ud.faces = fc;
set(hnd,'userdata',ud);


function r = cleanbomb(bindx,fc)

%this function will find a face from the last index in bindx

vert = bindx(end);

indx = union(union(find(fc(:,1)==vert),find(fc(:,2)==vert)),find(fc(:,3)==vert));
r = [];
for i = 1:length(indx)
    int = intersect(fc(indx(i),:),bindx);
    if length(int)==3
        r = makecolumn(int);
        break
    end
end

function createfabric(len,wid,res,tg,trg)

bp = get(trg,'userdata');
if isstruct(bp)
    bp = 'head';
end
ac = get(trg,'tag');


[vr,fc] = makefabric(len,wid,res);
ud.vertices = vr;
ud.faces = fc;
ud.bodypart = bp;
ud.actor = ac;
c = patch('parent',finddobj('axes'),'tag',tg,'facecolor',[.8 .8 .8],'edgecolor','none','buttondownfcn',...
    'costume(''buttondown'')','userdata',ud,'FaceLighting','gouraud','createfcn','costume(''createfcn'')');
stick(c);

function [vr,fc] = makefabric(len,wid,res)



ldelta = (0:res:len)';
wdelta = (0:res:wid)';

ldata = (-len/2)+ldelta;
wdata = (-wid/2)+wdelta;

vr = [];
fc = [];
plate = wdata;
lw = length(wdata);
pointer = 0;
for i = 1:length(ldata);
    yd = ldata(i);
    plate(:,2) = yd;
    plate(:,3) = 0;
    vr = [vr;plate];
    if i ~= length(ldata)
        fplate1 = [(1:lw-1)',(2:lw)',(lw+2:2*lw)'];
        fplate2 = [(lw+2:2*lw)',(lw+1:(2*lw)-1)',(1:lw-1)'];
        fplate1 = fplate1+pointer;
        fplate2 = fplate2+pointer;
        fc = [fc;fplate1;fplate2];
        pointer = length(vr(:,1));
    end
end
        
    


function r = iswholepatch

[tp,hnd] = currentobject;

if ~strcmp(tp,'costume')
    r = 0;
    return
end
r = 0;
cp = finddobj('costume pointer');
for i = 1:length(cp)
    ud = get(cp(i),'userdata');
    if ud.costume == hnd
        cdata = get(cp(i),'cdata');       
        if cdata(1,1,1) && cdata(1,1,3)
            r = 1;
        else
            r = 0;
        end
        break
    end
end

function rotationkey(ptr,ax,rval)


pud = get(ptr,'userdata');
co = pud.costume;
cud = get(co,'userdata');
md = currentunits;
if ~strcmp(ax,'z')
    if strcmp(md,'rotation');
        if iswholepatch
            cud.vertices = vecrotate(cud.vertices,rval,ax);
            set(co,'userdata',cud);
            stick(co);
        else
            pud.ort = vecrotate(pud.ort,rval,ax);
        end
    else
        if iswholepatch
            cud.vertices = vecrotate(cud.vertices,90*(rval/abs(rval)),ax);
            set(co,'userdata',cud);
            stick(co);
        else
            if strcmp(ax,'x') && rval >= 0
                pud.ort = [0 1 0;0 0 1;1 0 0];
            elseif strcmp(ax,'x') && rval < 0
                pud.ort = [0 1 0;0 0 1;-1 0 0];
            elseif strcmp(ax,'y') && rval >= 0
                pud.ort = [0 0 1;1 0 0;0 1 0];
            elseif strcmp(ax,'y') && rval < 0
                pud.ort = [0 0 1;1 0 0;0 -1 0];
            end
        end
    end
else
    if iswholepatch
            cud.vertices = vecrotate(cud.vertices,rval,ax);
            set(co,'userdata',cud);
            stick(co);
    else
        if pud.ort(3,3)== 1
            pud.ort = [1 0 0;0 1 0;0 0 -1];
        else

            pud.ort = [1 0 0;0 1 0;0 0 1];
        end
    end
end
set(ptr,'userdata',pud);
refreshpointer;


function duplicateindex(hnd,index,oindex)


vindx = union(index,oindex);

ud = get(hnd,'userdata');
fc = ud.faces;
vr = ud.vertices;

findx = intersect(findvertex(vindx(1),fc),findvertex(vindx(2),fc));
if isempty(findx)
    return
end
vr = [vr;vr(index,:)];
lvr = length(vr(:,1));
for i = 1:length(findx);
   j = find(fc(findx(i),:)==index);
   fc(findx(i),j) = lvr;
end
ud.faces = fc;
ud.vertices = vr;
set(hnd,'userdata',ud);
stick(hnd);


function c = createcostume(ud,tg)

ax = finddobj('axes');

[tp,hnd] = currentobject;
if ~strcmp(tp,'actor')
    return
else
    ud.actor = get(hnd(1),'tag');
end

c = patch('parent',ax,'tag',tg,'facecolor',ud.color,'edgecolor','none','buttondownfcn',...
    'costume(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'userdata',ud,...
    'FaceLighting','gouraud','createfcn','costume(''createfcn'')','clipping','off',...
    'deletefcn','costume(''deletefcn'')');

stick(c);


function caliper
bm = finddobj('bomb');
v = [];
for i = 1:length(bm);
    ud = get(bm(i),'userdata');
    v = union(v,ud.vindex);
end
if length(v)==1
    vr = get(gco,'vertices');
    set(gcf,'name',num2str(vr(v(1),:)));
elseif length(v)==2
    vr = get(gco,'vertices');
    delta = vr(v(1),:)-vr(v(2),:);
    delta = sqrt(delta*delta');
    set(gcf,'name',num2str(delta));
end

function loadspecial(filename)

t = load(filename,'-mat');
special = t.special;
global producer
if ~isfield(producer.grips,'invisible');
    producer.grips.invisible = [];
end
for i = 1:length(special)
    ud = special(i).userdata;
    ud.color = special(i).facecolor;
    ud.edgecolor = special(i).edgecolor;
    if strcmp(ud.fxn,'bargraph')
        ud.bodypart = ud.data.segment;
    else
        continue
    end
    hnd = createcostume(ud,special(i).name);
    producer.grips.invisible = union(producer.grips.invisible,hnd);
end