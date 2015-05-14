function varargout = stretch(action,varargin);
global stretchvar
if nargin == 0
    action = 'start';
end
switch action
case 'start'
    fig = figure('tag','stretch','color',[0 0 0],'name','stretch','units','normalized',...
        'menubar','none','numbertitle','off','keypressfcn','stretch(''datakeypress'')');
    ax = axes('parent',fig,'units','normalized','position',[.1 .1 .9 .9],'color',[0 0 0],'box','on','xcolor',[1 1 1],'ycolor',[1 1 1],...
        'buttondownfcn','stretch(''buttondown'')','tag','data');
    text('parent',ax,'units','normalized','position',[0 0],'horizontalalignment','left','verticalalignment','bottom','color',[0 1 0],'tag','frame');
    ax = axes('parent',fig,'units','normalized','position',[.1 .1 .9 .9],'color',[0 0 0],'box','on','xcolor',[1 1 1],'ycolor',[1 1 1],...
        'buttondownfcn','stretch(''buttondown'')','tag','phantom','visible','off');
    mn = uimenu(fig,'label','file');
    uimenu(mn,'label','open','callback','stretch(''open'')');    
    uimenu(mn,'label','save','callback','stretch(''save'')');
    uimenu(mn,'label','preview','callback','stretch(''preview'')','separator','on');
    uimenu(mn,'label','exit','callback','delete(gcf)','separator','on');   
    
case 'open'
    [f,p] = uigetfile('*.*','open file');
    if f ==0
        return
    end
    [ext,fl] = extension(f);
    switch lower(ext)
    case '.avi'
        stretch('open avi',[p,f]);
    case '.soo'
        stretch('open soo',[p,f]);
    case '.zoo'
        stretch('open zoo',[p,f]);
    case 'txt'
        stretch('open text',[p,f]);
    end
    cd(p);
    
case 'save'
    stretch('stretch avi');
    avi = findstobj('avi');
    ud = get(avi,'userdata');
    stretchvar.stop = 0;
    aviindex = ud.stretch.aviindex;
    doffset = ud.stretch.dataindex;
    ph = findstobj('phantom');
    ln = line('parent',ph,'xdata',[0 0],'ydata',[0 1],'color',[0 1 1]);
    cmap = get(findstobj('avi figure'),'colormap');
    mov = [];
    for i = 1:length(aviindex);
        setavi('goto',aviindex(i));        
        set(ln,'xdata',doffset+i-1);
        pause(0);
        cdata = get(avi,'cdata');

        mov(i).cdata = cdata;
        mov(i).colormap = cmap;
        if stretchvar.stop
            delete(ln)
            return
        end
    end
    delete(ln);
    [f,p] = uiputfile('*.avi','save avi');
    if f == 0
        return
    end    
    f = extension(f,'.avi');
    info = avimenu;
    
    movie2avi(mov,[p,f],'fps',info.fps,'compression',info.compression,'quality',info.quality);
            
case 'open avi'
    im = findstobj('avi');
    if isempty(im)
        im = avifigure;
    end
    ax = get(im,'parent');
    pt = get(ax,'parent');    
    set([ax;pt],'units','pixels');
    info = aviinfo(varargin{1});
    mov = aviread(varargin{1},1);
    ud.filename = varargin{1};
    ud.maxframe = info.NumFrames;
    ud.curframe = 1;
    cdata = mov(1).cdata;
    cmap = mov(1).colormap;
    set(gcf,'colormap',cmap);
    set(im,'cdata',cdata,'userdata',ud);
    avpos = get(ax,'position');
    [r,c,d] = size(cdata);        
    set(ax,'xlim',[1,c],'ylim',[1,r],'position',[avpos(1:2),c,r]);    
    ppos = get(pt,'position');
    set(pt,'position',[ppos(1:2),c,r]);
    set([ax,pt],'units','normalized');
    as = findstobj('avi slide');
    set(as,'xlim',[1 ud.maxframe]);
    set(findobj(as,'type','line'),'xdata',[1 1]);
case 'open soo'
    t = load(varargin{1},'-mat');    
    ch = fieldnames(t.stats);
    answer = listdlg('liststring',ch,'selectionmode','single','name','select line','listsize',[300 300]);
    if isempty(answer)
        return
    end
    
    vl = getfield(t.stats,ch{answer});
    vl = vl.line;
    vl = rmfield(vl,'filenames');
    [pth,ax] = treefxn('start',vl);
    delete(ax);
    
    yd = getydata(vl,pth);
    ln = findobj(findstobj('data'),'color',[1 1 1],'type','line');
    if isempty(ln)
        ln = line('parent',findstobj('data'),'ydata',yd,'xdata',(1:length(yd)),'color',[1 1 1],'buttondownfcn','stretch(''buttondown'')');
    else
        set(ln,'ydata',yd,'xdata',(1:length(yd)));
    end
    set(get(ln,'parent'),'xlim',[1 length(yd)]);
    set(findstobj('phantom'),'xlim',[1 length(yd)]);
    
case 'open zoo'
    t = load(varargin{1},'-mat');    
    cl = zoocell(t.data);
    ncl = merge(cl(:,1:end-1));
    answer = listdlg('liststring',ncl,'selectionmode','single','name','select line','listsize',[300 300]);
    if isempty(answer)
        return
    end
    yd = cl{answer,end};
    ln = findobj(findstobj('data'),'color',[1 1 1],'type','line');
    if isempty(ln)
        ln = line('parent',findstobj('data'),'ydata',yd,'xdata',(1:length(yd)),'color',[1 1 1],'buttondownfcn','stretch(''buttondown'')');
    else
        set(ln,'ydata',yd,'xdata',(1:length(yd)));
    end
    set(get(ln,'parent'),'xlim',[1 length(yd)]);
    set(findstobj('phantom'),'xlim',[1 length(yd)]);
    
case 'play'
    stretchvar.stop = 0;
    while ~stretchvar.stop
        r = setavi('next');
        if ~r
            stretchvar.stop = 1;
        end
        pause(0);
    end
case 'stop'
    stretchvar.stop = 1;
case 'playback'
    stretchvar.stop = 0;
    while ~stretchvar.stop
        r = setavi('prev');
        if ~r
            stretchvar.stop = 1;
        end
        pause(0);
    end
case 'avislide'
    state = uisuspend(gcf);
    curpt = get(gca,'currentpoint');
    curpt = round(curpt(1,1));
    setavi('goto',curpt);
    set(gcf,'windowbuttonmotionfcn','stretch(''slide motion'')');
    set(gcf,'windowbuttonupfcn','uiresume');
    uiwait
    uirestore(state);
case 'slide motion'
    curpt = get(gca,'currentpoint');
    curpt = round(curpt(1,1));
    setavi('goto',curpt);
    
case 'avikeypress'
    cky = get(gcf,'currentkey');
    switch cky
    case 'rightarrow'
        setavi('next');
    case 'leftarrow'
        setavi('prev');
    end
    
case 'datakeypress'
    cky = get(gcf,'currentkey');
    switch cky
    case 'rightarrow'
        setline('next');
    case 'leftarrow'
        setline('prev');
    case 'delete'
        if ~isempty(intersect(gco,findstobj('phantom line')))
            delete(gco);
        end
    end
case 'mark'
    im = findstobj('avi');
    ud = get(im,'userdata');
    xd = placeline(ud.curframe);
    if isempty(xd)
        errordlg('error in line creation');
        return
    end
    ph = findstobj('phantom');
    line('parent',ph,'color',[1 0 0],'xdata',[xd xd],'ydata',[0 1],'buttondownfcn','stretch(''buttondown'')','clipping','off','userdata',ud.curframe);
    
case 'buttondown'
    if strcmp(get(gcbo,'type'),'line');
        set(findstobj('phantom line'),'linewidth',.5)
        set(gcbo,'linewidth',2);
        setavi('goto',get(gcbo,'userdata'));
        xd = get(gcbo,'xdata');
        set(findstobj('data frame'),'string',num2str(xd(1)));
        state = uisuspend(gcf);
        set(gcf,'windowbuttonmotionfcn','stretch(''line motion'')');
        set(gcf,'windowbuttonupfcn','uiresume');
        uiwait
        uirestore(state);
    end
    
case 'line motion'
    curpt = get(gca,'currentpoint');
    setline('goto',round(curpt(1,1)));
    
case 'stretch avi'
    ln = findstobj('phantom line');
    ln = orderline(ln);
    aviindex = [];
    for i = 2:length(ln)
        xd1 = get(ln(i-1),'xdata');
        xd2 = get(ln(i),'xdata');
        ud1 = get(ln(i-1),'userdata');
        ud2 = get(ln(i),'userdata');
        dlim = [xd1(1),xd2(1)];
        alim = [ud1,ud2];
        pvec = (dlim(1):dlim(2))-dlim(1);
        pvec = pvec/length(pvec);
        deltaa = alim(2)-alim(1);
        
        aindx = (pvec*deltaa)+alim(1);
        if isempty(aviindex)
            aviindex = aindx;
        else
            aviindex = [aviindex,aindx(2:end)];
        end
    end
    aviindex = round(aviindex);
    avi = findstobj('avi');
    ud = get(avi,'userdata');
    ud.stretch.aviindex = aviindex;
    ud.stretch.dataindex = get(ln(1),'xdata');    
    set(avi,'userdata',ud);
    
case 'preview'
    stretch('stretch avi');
    avi = findstobj('avi');
    ud = get(avi,'userdata');
    stretchvar.stop = 0;
    aviindex = ud.stretch.aviindex;
    doffset = ud.stretch.dataindex;
    ph = findstobj('phantom');
    ln = line('parent',ph,'xdata',[0 0],'ydata',[0 1],'color',[0 1 1]);
    for i = 1:length(aviindex);
        setavi('goto',aviindex(i));        
        set(ln,'xdata',doffset+i-1);
        pause(0);
        if stretchvar.stop
            break
        end
    end
    delete(ln);
    
end


function hnd = findstobj(action);
switch action
case 'figure'
    hnd = findobj('type','figure','tag','stretch');
case 'avi figure'
    hnd = findobj('type','figure','tag','stretch avi');    
    
case 'data'
    hnd = findobj(findstobj('figure'),'type','axes','tag','data');
case 'avi axes'
    hnd = findobj(findstobj('avi figure'),'type','axes','tag','avi');    
case 'phantom'
    hnd = findobj(findstobj('figure'),'type','axes','tag','phantom');
case 'avi slide'
    hnd = findobj(findstobj('avi figure'),'tag','avislider','type','axes');
    
case 'phantom line'
    hnd = findobj(findstobj('phantom'),'type','line','color',[1 0 0]);    
case 'avi'    
    hnd = findobj(findstobj('avi axes'),'type','image');    
    
case 'data frame'
    hnd = findobj(findstobj('data'),'tag','frame','type','text');        
case 'avi frame'
    hnd = findobj(findstobj('avi axes'),'tag','frame','type','text');
    
end
    
function im = avifigure
fig = figure('tag','stretch avi','color',[0 0 0],'name','stretch (avi)','units','pixels',...
    'menubar','none','numbertitle','off','doublebuffer','on','keypressfcn','stretch(''avikeypress'')');
uimenu(fig,'label',' >> ','callback','stretch(''play'')');
uimenu(fig,'label',' | | ','callback','stretch(''stop'')');
uimenu(fig,'label',' << ','callback','stretch(''playback'')');
uimenu(fig,'label','  mark','callback','stretch(''mark'')');
ax = axes('parent',fig,'units','normalized','position',[0 0 1 1],'color',[0 0 0],'box','on','xcolor',[1 1 1],'ycolor',[1 1 1],...
    'buttondownfcn','stretch(''buttondown'')','tag','avi','ydir','reverse');
im = image('parent',ax);
text('parent',ax,'units','normalized','position',[0 0],'horizontalalignment','left','verticalalignment','bottom','color',[0 1 0],'tag','frame');

ax =axes('parent',fig','units','centimeters','position',[1 .1 8 .4],'color',[0 0 0],'box','on','xcolor',[0 0 1],'ycolor',[0 0 1],...
    'tag','avislider','xtick',[],'ytick',[],'buttondownfcn','stretch(''avislide'')','xlim',[0 1]);
line('parent',ax,'color',[1 0 0],'xdata',[0 0],'ydata',[0 1],'linewidth',2,'buttondownfcn','stretch(''avislide'')','clipping','off');

function cl = soocell(st)

if ~isstruct(st)
    cl = [];
    return
elseif isfield(st,'line')
    cl = {st.line.mean};
    return
end

fld = fieldnames(st);
cl = [];
for i = 1:length(fld)
    plt = soocell(getfield(st,fld{i}));
    tplt(1:length(plt(:,1)),1) = fld(i);
    plt = [tplt,plt];
    cl = [cl;plt];
end

function cl = zoocell(st)

if ~isstruct(st)
    cl = [];
    return
elseif isfield(st,'line')
    cl = {getfield(st,'line')};
    return
end

fld = fieldnames(st);
cl = [];
for i = 1:length(fld)
    plt = zoocell(getfield(st,fld{i}));
    tplt(1:length(plt(:,1)),1) = fld(i);
    plt = [tplt,plt];
    cl = [cl;plt];
end


function ncl = merge(cl)
[r,c] = size(cl);
ncl = [];
for i = 1:r
    plt = [];
    for j = 1:c
        plt = [plt,cl{i,j},'\'];
    end
    ncl = [ncl;{plt(1:end-1)}];
end

function r = setavi(action,varargin)

av = findstobj('avi');
if isempty(av)
    r = 0;
    return
end
ud = get(av,'userdata');
switch action
case 'next'
    ud.curframe = ud.curframe+1;
case 'prev'
    ud.curframe = ud.curframe-1;
case 'goto'
    ud.curframe = varargin{1};
otherwise
    return
end

if ud.curframe > ud.maxframe | ud.curframe < 1
    r = 0;
    return
end
mov = aviread(ud.filename,ud.curframe);
set(av,'cdata',mov(1).cdata,'userdata',ud);
set(findstobj('avi frame'),'string',num2str(ud.curframe));
set(findobj(findstobj('avi slide'),'type','line'),'xdata',[ud.curframe,ud.curframe]);
r = 1;
    

function r = setline(action,varargin)

ln = findstobj('phantom line');
if isempty(intersect(ln,gco))
   r = 0;
   return
end

ud = get(gco,'userdata');
ln = setdiff(ln,gco);
xlim = [NaN,NaN];

for i = 1:length(ln)
    lud = get(ln(i),'userdata');
    lxd = get(ln(i),'xdata');
    if lud < ud
        xlim(1) = max(xlim(1),lxd(1));
    elseif lud > ud
        xlim(2) = min(xlim(2),lxd(1));
    end
end
if isnan(xlim(1))
    xlim(1) = 0;
end
if isnan(xlim(2))
    xlim(2) = max(get(findstobj('data'),'xlim'))+1;
end

xd = get(gco,'xdata');
switch action
case 'next'
    xd = xd(1)+1;
case 'prev'
    xd = xd(1)-1;
case 'goto'
    xd = varargin{1};
end
if xd<=xlim(1) | xd>=xlim(2)
    r = 0;
    return
end
set(gco,'xdata',[xd xd]);
set(findstobj('data frame'),'string',num2str(xd));

function xd = placeline(frm);

ln = findstobj('phantom line');
xlim = [NaN,NaN];

for i = 1:length(ln)
    lud = get(ln(i),'userdata');
    lxd = get(ln(i),'xdata');
    if lud < frm
        xlim(1) = max(xlim(1),lxd(1));
    elseif lud > frm
        xlim(2) = min(xlim(2),lxd(1));
    else
        xd = [];
        return        
    end
end
if isnan(xlim(1))
    xlim(1) = 1;
end
if isnan(xlim(2))
    xlim(2) = max(get(findstobj('data'),'xlim'));
end
if xlim(2)-xlim(1) <=2
    xd = [];
    return
end
xd = mean(xlim); 
    

function hnd = orderline(ln)

for i = 1:length(ln)-1
    for j = i:length(ln)
        xd1 = get(ln(i),'xdata');
        xd2 = get(ln(j),'xdata');
        if xd1(1)>xd2(1)
            temp = ln(i);
            ln(i) = ln(j);
            ln(j) = temp;
        end
    end
end

hnd = ln;

function yd = getydata(st,pth);
vl = st;
for i = 1:length(pth)
    if isfield(vl,pth{i})
        vl = getfield(vl,pth{i});
    else
        yd = [];
    end
end
if isfield(vl,'mean');
    yd = vl.mean;
else
    yd = [];
end
