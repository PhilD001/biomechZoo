function varargout = bargraphfxn(action,varargin)

switch action
case 'start'
    ac = finddobj('actor');
    cm = uicontextmenu('tag','tempobj');
    uimenu(cm,'callback','bargraphfxn(''create'')','label','create');
    set(ac,'uicontextmenu',cm);
    
case 'create'
    nm = get(gco,'tag');
    pt = get(gco,'userdata');
    if isstruct(pt)
        pt = 'head';
    end
    answer = inputdlg('name of bar','name');
    answer = answer{1};
    ud.actor= nm;
    ud.segment = pt;    
    ud.data = [];
    ud.coeff = [1 0];
    ud.ort = [1 0 0;0 1 0;0 0 1];
    ud.movevert = (5:8);
    vr = [-.5 -.5 0;-.5 .5 0;.5 .5 0;.5 -.5 0];
    vr = [vr;vr];        
    vr(5:8,3) = 3;    
    ud.vertices = vr;
    ud.dis = [0 0 0];       
    dis = vr(1,:);
    face = [1 2 3 4;1 5 6 2;2 6 7 3;3 7 8 4;4 8 5 1;5 6 7 8];
    ud.faces = face;
    ud.color = [1 0 0];
    pch = patch('vertices',ud.vertices,'faces',face,'edgecolor',[0 0 0],'facecolor',ud.color,'facelighting','phong','tag',answer,'userdata',ud,'buttondownfcn','bargraphfxn(''buttondown'')',...
        'clipping','off');
    actor('refresh',nm);
    
case 'buttondown'
    hnd = finddobj('current object');
    set(hnd,'string',get(gcbo,'tag'));
    hnd = finddobj('colorpallete');
    set(hnd,'backgroundcolor',get(gcbo,'facecolor'));
    
case 'increment face'
    [tp,hnd] = currentobject;
    switch varargin{1}
    case 'rightarrow'
        nextface(hnd,'next');
    case 'leftarrow'
        nextface(hnd,'prev');
    end
    
case 'rotate bar'
    [tp,hnd] = currentobject;
    [ut,deg] = currentunits;
    hnd = intersect(hnd,gco);
    if isempty(hnd)
        return
    end    
    ud = get(hnd,'userdata');
    lunt = getbarort(hnd);
    gunit = [1 0 0;0 1 0;0 0 1];
    unt = ctransform(lunt,gunit,ud.localort);
    switch varargin{1}
    case 'rightarrow'
        unt = rotateunit(unt,deg,'x');
    case 'leftarrow'
        unt = rotateunit(unt,-deg,'x');
    case 'uparrow'
        unt = rotateunit(unt,deg,'y');
    case 'downarrow'
        unt = rotateunit(unt,-deg,'y');
    case 'pageup'
        unt = rotateunit(unt,deg,'z');
    case 'pagedown'
        unt = rotateunit(unt,-deg,'z');
    case 'home'
        pch = actor('find part',ud.actor,ud.part);
        vr = get(pch,'vertices');
        fc = get(pch,'faces');
        vr = vr(fc(ud.faceort,:),:);
        unt = getunit(vr);
    case 'end'
        flipgraph(hnd); 
        return
    case 'numpad7'
        unt = [0 1 0;0 0 1;1 0 0];
    case 'numpad4'
        unt = [0 1 0;0 0 1;-1 0 0];
    case 'numpad8'
        unt = [1 0 0;0 0 1;0 1 0];
    case 'numpad5'
        unt = [1 0 0;0 0 1;0 -1 0];
    case 'numpad9'
        unt = [1 0 0 ;0 1 0; 0 0 1];
    case 'numpad6'
        unt = [1 0 0;0 1 0; 0 0 -1];        
    otherwise
        bargraphfxn('common keypress',varargin{1});
        return
    end
    ud.localort = makeunit(ctransform(gunit,lunt,unt));
    set(hnd,'userdata',ud);
    stickbar(hnd); 
    
case 'displace bar'
    [tp,hnd] = currentobject;
    [ut,d] = currentunits;
    hnd = intersect(hnd,gco);
    if isempty(hnd)
        return
    end
    ud = get(hnd,'userdata');
    dis = ud.dis;
    unt = getbarort(hnd);
    gunit = [1 0 0;0 1 0;0 0 1];
    dis = ctransform(unt,gunit,ud.dis);
    switch varargin{1}
    case 'rightarrow'
        dis(1) = dis(1)+d;
    case 'leftarrow'
        dis(1) = dis(1)-d;
    case 'uparrow'
        dis(2) = dis(2)+d;
    case 'downarrow'
        dis(2) = dis(2)-d;
    case 'pageup'
        dis(3) = dis(3)+d;
    case 'pagedown'
        dis(3) = dis(3)-d;
    case 'add'
        nextface(hnd,'next');
        return
    case 'subtract'
        nextface(hnd,'prev');
        return
    case 'home'
        dis = [0 0 0];
    otherwise
        bargraphfxn('common keypress',varargin{1});
        return
    end
    ud.dis = ctransform(gunit,unt,dis);
    set(hnd,'userdata',ud);
    stickbar(hnd); 
    
case 'resize'
    [tp,hnd] = currentobject;
    [ut,d] = currentunits;
    hnd = intersect(hnd,gco);
    if isempty(hnd)
        return
    end    
    ud = get(hnd,'userdata');
    vert = ud.vert;
    cpt = mean(vert);
    nvrt = [vert(:,1)-cpt(1),vert(:,2)-cpt(2),vert(:,3)-cpt(3)];
    mg = diag(sqrt(nvrt*nvrt'));
    nvrt = nvrt./[mg,mg,mg];    
    switch varargin{1}
    case 'rightarrow'
        mg = mg+d;
    case 'leftarrow'
        mg = mg-d;
    case 'uparrow'
        mg = mg+d;
    case 'downarrow'
        mg = mg-d;
    otherwise
        bargraphfxn('common keypress',varargin{1});
        return
    end
    nvrt = nvrt.*[mg,mg,mg];
    nvrt =[nvrt(:,1)+cpt(1),nvrt(:,2)+cpt(2),nvrt(:,3)+cpt(3)];
    nvrt(:,3) = nvrt(:,3)-min(nvrt(:,3));
    ud.vert = nvrt;
    set(hnd,'userdata',ud)
    stickbar(hnd);
    
case 'reset'
    br = finddobj('bargraph');
    for i = 1:length(br)
        ud = get(br(i),'userdata');
        ud.vert(ud.movevert,3) = 1;
        set(br(i),'userdata',ud);
        stickbar(br(i))
    end
case 'common keypress'
    [tp,hnd] = currentobject;
    hnd = intersect(hnd,gco);
    if isempty(hnd)
        return
    end     
    switch varargin{1}
    case 'c'
        copybar(hnd);
    case 'r'
        rename(hnd);
    case 'delete'
        delete(hnd);
        set(finddobj('current object'),'string','');
    case 'p'
        cp = finddobj('colorpallete');
        if ~isempty(cp)
            set(hnd,'facecolor',get(cp,'backgroundcolor'));
        end
    end        
        
case 'save'
    [tp,hnd] = currentobject;
    switch tp
    case 'bargraph'
        ud = get(hnd,'userdata');
        ac = ud.actor;
    case 'actor'
        ac = get(hnd(1),'tag');
    otherwise
        return
    end
    br = finddobj('bargraph');
    bargraph = [];
    for i = 1:length(br)
        bud = get(br(i),'userdata');
        if ~strcmp(bud.actor,ac);
            continue
        end
        tmp = [];
        tmp.data = bud.data;
        tmp.coeff = bud.coeff;
        tmp.part = bud.part;
        tmp.faceort = bud.faceort;
        tmp.movevert = bud.movevert;
        tmp.vert = bud.vert;
        tmp.dis = bud.dis;
        tmp.localort = bud.localort;
        tmp.face = get(br(i),'faces');
        tmp.color = get(br(i),'facecolor');
        bargraph = setfield(bargraph,get(br(i),'tag'),tmp);
    end
    if isempty(bargraph)
        return
    end
    [f,p] = uiputfile('*.bar','save bar');
    if f == 0
        return
    end
    f = extension(f,'.bar');
    save([p,f],'bargraph');
    
case 'load'
    [tp,hnd] = currentobject;
    if ~strcmp(tp,'actor');
        return
    end        
    ac = get(hnd(1),'tag');
    
    bargraph = load(varargin{1},'-mat');
    bargraph = bargraph.bargraph;
    fld = fieldnames(bargraph);
    
    for i = 1:length(fld)
        ud = getfield(bargraph,fld{i});
        ud.actor = ac;
        pch = patch('vertices',ud.vert,'faces',ud.face,'edgecolor',[0 0 0],'facecolor',ud.color,'facelighting','phong','tag',fld{i},'userdata',ud,'buttondownfcn','bargraphfxn(''buttondown'')','clipping','off');
        stickbar(pch);
    end 
    
case 'load so'
    but = questdlg('what would you like','bar graph','bar graph','data graph','bar graph');
    if strcmp(but,'data graph')
        grips('data graph',varargin{1});
        return
    end
    t = load(varargin{1},'-mat');
    answer = inputdlg({'scaling factor'},'enter scaling factor',1,{'1 0'});
    if isempty(answer)
        return
    elseif isempty(answer{1});
        return
    elseif isempty(str2num(answer{1}));
        return
    elseif length(str2num(answer{1}))~=2
        return
    end
    
    loadsoo(t.stats,str2num(answer{1}));
    %if ~isempty(r)
    %    answer = listdlg('liststring',r,'selectionmode','multiple','name','unknown data');
    %end
        
case 'load zoo'
    t = load(varargin{1},'-mat');
    answer = inputdlg({'scaling factor'},'enter scaling factor',1,{'1 0'});
    if isempty(answer)
        return
    elseif isempty(answer{1});
        return
    elseif isempty(str2num(answer{1}));
        return
    elseif length(str2num(answer{1}))~=2
        return
    end
    
    r = loadzoo(t.data,str2num(answer{1}));
    if ~isempty(r)
        answer = listdlg('liststring',r,'selectionmode','multiple','name','unknown data');
    end
case 'refresh'
    br = finddobj('bargraph');
    for i = 1:length(br)
        stickbar(br(i));
    end
    
case 'next mark'
    br = finddobj('bargraph');
    if isempty(br)
        return
    end
    isgood = [];
    for i = 1:length(br)
        plt = setdata(br(i),'next');
        isgood = [isgood;plt];
    end
    indx = find(isgood==0);
    if length(indx)==length(br)
        varargout{1} = 0;
    else
        varargout{1} = 1;
    end

case 'prev mark'
    br = finddobj('bargraph');
    if isempty(br)
        return
    end
    isgood = [];
    for i = 1:length(br)
        plt = setdata(br(i),'prev');
        isgood = [isgood;plt];
    end
    indx = find(isgood==0);
    if length(indx)==length(br)
        varargout{1} = 0;
    else
        varargout{1} = 1;
    end
    
case 'first position'
    br = finddobj('bargraph');
    for i = 1:length(br)
        setdata(br(i),'goto',1);
    end
            
end


function r = setdata(br,varargin)
ud = get(br,'userdata');
if isempty(ud.data)
    return
end
switch varargin{1}
case 'next'
    ud.dataindex = ud.dataindex+1;
case 'prev'
    ud.dataindex = ud.dataindex-1;
case 'goto'
    ud.dataindex = varargin{2};
otherwise
    r = 0;
    return
end
if ud.dataindex > length(ud.data) | ud.dataindex < 1
    r = 0;
    return
end

d = ud.data(ud.dataindex)*ud.coeff(1)+ud.coeff(2);
ud.vert(ud.movevert,3)= d;
ud.vert(1:4,3) = min(ud.vert(:,3));
set(br,'userdata',ud);
stickbar(br);
r = 1;

function copybar(hnd)
ud = get(hnd,'userdata');
answer = inputdlg({'enter new tag'},'new tag',1,{get(hnd,'tag')});
if isempty(answer)
    return
elseif isempty(answer{1})
    return
end
tg = answer{1};
pch = patch('vertices',ud.vert,'faces',ud.face,'edgecolor',[0 0 0],'facecolor',ud.color,'facelighting','phong','tag',tg,'userdata',ud,'buttondownfcn','bargraphfxn(''buttondown'')','clipping','off');
stickbar(pch);

function flipgraph(br)
ud = get(br,'userdata');
ud.localort(3,:) = -ud.localort(3,:);
set(br,'userdata',ud);
stickbar(br);

function nextface(br,action)

ud = get(br,'userdata');
pt = actor('find part',ud.actor,ud.part);
fc = get(pt,'faces');
mxfc = length(fc(:,1));
switch action
case 'next'
    ud.faceort = ud.faceort+1;
case 'prev'
    ud.faceort = ud.faceort-1;
end

if ud.faceort > mxfc
    ud.faceort = 1;
elseif ud.faceort < 1
    ud.faceort = mxfc;    
end

set(br,'userdata',ud);
stickbar(br);

function unt = getunit(m)
i = m(2,:)-m(1,:);
j = m(3,:)-m(1,:);
k = cross(i,j);
j = cross(i,k);
m = [i;j;k];
mg = diag(sqrt(m*m'));
unt = m./[mg,mg,mg];

function stickbar(pch)
ud = get(pch,'userdata');
gunit = [1 0 0;0 1 0;0 0 1];
[unt,vr] = getbarort(pch);
dis = vr(1,:)+ctransform(unt,gunit,ud.dis);
lort = makeunit(ctransform(unt,gunit,ud.localort));
vr = ctransform(unt,gunit,ctransform(lort,unt,ud.vert));
vr(:,1)=  vr(:,1)+dis(1);
vr(:,2) = vr(:,2)+dis(2);
vr(:,3) = vr(:,3)+dis(3);
set(pch,'vertices',vr);

function varargout = getbarort(bar)
ud = get(bar,'userdata');
pt = actor('find part',ud.actor,ud.part);
vr = get(pt,'vertices');
fc = get(pt,'faces');
fc = fc(ud.faceort,:);
vr = vr(fc,:);
varargout{1} = getunit(vr);
varargout{2} = vr;

function unt = rotateunit(unt,deg,ax)
gunit = [1 0 0;0 1 0;0 0 1];
nunt = vecrotate(gunit,deg,ax);
unt = ctransform(unt,gunit,nunt);
mg = diag(sqrt(unt*unt'));
unt = unt./[mg,mg,mg];

function rename(hnd)
tg = get(hnd,'tag');
answer = inputdlg({tg},'rename',1,{tg});
if isempty(answer)
    return
elseif isempty(answer{1})
    return
end
set(hnd,'tag',answer{1});
set(finddobj('current object'),'string',answer{1});
    
function unt = makeunit(u)

mg = diag(sqrt(u*u'));
unt = u./[mg,mg,mg];

function r = loadsoo(st,num);

if ~isstruct(st)
    return
end
bg = finddobj('bargraph');
clr = finddobj('colorpallete');
if ~isempty(clr)
    bg = findobj(bg,'facecolor',get(clr,'backgroundcolor'));
end

btg = get(bg,'tag');
if ~iscell(btg)
    btg = {btg};
end
fld = fieldnames(st);

vl = getfield(st,fld{1});
vl = vl.line;
vl = rmfield(vl,'filenames');

[pth,ax] = treefxn('start',vl);
delete(ax);

ubr = setdiff(btg,fld);
ufld = setdiff(fld,ubr);
ifld = intersect(fld,btg)
for i = 1:length(ifld)
    hnd = findobj(bg,'tag',ifld{i});
    vl = getfield(st,ifld{i});
    msg = setbar(hnd,pth,vl.line,num)
end
    
function r = loadzoo(st,num,pth);

if nargin == 2
    pth = [];
end
if ~isstruct(st)
    return
end

fld = fieldnames(st);
if isfield(st,'line');
    %reaching the end of the recursion
    yd = getfield(st,'line');
    r = findbar(yd,num,pth);
else
    r = [];
    for i = 1:length(fld)
        plt = loadzoo(getfield(st,fld{i}),num,[pth;fld(i)]);
        r = [r;plt];
    end
end

function msg = setbar(hnd,pth,st,num);
vl = st;
msg = [];
for i = 1:length(pth)
    if isfield(vl,pth{i})
        vl = getfield(vl,pth{i});
    else
        msg = {'line not found'};
    end
end
if isfield(vl,'mean');
    for i = 1:length(hnd)
        ud = get(hnd(i),'userdata');
        ud.data = vl.mean;
        ud.coeff = num;
        ud.dataindex = 1;
        set(hnd(i),'userdata',ud);
    end
else
    msg = {'line not found'};
end
    

function r = findbar(yd,num,pth)

br = finddobj('bargraph');
pindx = length(pth);
str = pth{pindx};
found = 0;
while 1
    hnd = findobj(br,'tag',str);
    if isempty(hnd)
        pindx = pindx-1;
        if pindx < 1
            break
        end
        str = [str,';',pth{pindx}];
    else
        ud = get(hnd,'userdata');
        ud.data = yd;
        ud.coeff = num;
        ud.dataindex = 1;
        set(hnd,'userdata',ud);
        found = 1;
        break
    end
end
if ~found
    r = pth{1};
    for i = 2:length(pth)
        r = [r,'; ',pth{i}];
    end
    r = {r};
else
    r = [];
end



