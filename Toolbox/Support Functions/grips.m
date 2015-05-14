function varargout = grips(action,varargin)

% edited by Phil Dixon Dec 2010
% - handle to axes output during 'data graph' case

global producer

switch action
    case 'save'
        if isempty(fieldnames(producer.grips))
            return
        end
        grip = producer.grips;
        [f,p] = uiputfile('*.grip','save your file');
        if f == 0
            return
        end
        f = extension(f,'grip');
        save([p,f],'grip');
        
    case 'load'
        t = load(varargin{1},'-mat');
        if isfield(producer.grips,'invisible');
            inv = producer.grips.invisible;
        else
            inv = [];
        end
        producer.grips = t.grip;
        producer.grips.invisible = inv;
    case 'save internal image'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'internal image');
            return
        end
        [f,p] = uiputfile('*.iim','save internal image');
        if f == 0
            return
        end
        f = extension(f,'.iim');
        idata = get(hnd,'userdata');
        idata.cdata = get(hnd,'cdata');
        save([p,f],'idata');

    case 'load internal image';
        answer = inputdlg('enter name','name');
        if isempty(answer)
            return
        end

        idata = load(varargin{1},'-mat');
        idata = idata.idata;
        idata.name = answer{1};
        internalimage(idata);
        set(finddobj('current object'),'string',answer{1});

    case 'internal image'
        fl = varargin{1};
        ort = {[1 0 0;0 1 0;0 0 1]};
        dis = [0 0 0];
        varargout{1} = [];
        answer = inputdlg({'enter name';'x size(cm)'},'image name');
        if isempty(answer)
            return
        end
        set(finddobj('current object'),'string',answer{1});
        xdim = str2num(answer{2});
        internalimage(fl,xdim,ort,dis,answer{1});

    case 'buttondown'
        cameraman('buttondown');
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        set(finddobj('highlight'),'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);   
        vr = get(gcbo,'vertices');
        mn = min(vr);
        mx = max(vr);
        nm = mx-mn;
        nm(3) = max(vr(:,1));
        set(gcf,'name',num2str(nm));
    case 'image buttondown'
        state = uisuspend(gcf);
        unt = get(gcf,'units');
        set(gcf,'units',get(gca,'units'));
        curpt = get(gcf,'currentpoint');
        apos = get(gca,'position');
        apos = [curpt(1)-apos(3)/2,curpt(2)-apos(4)/2,apos(3),apos(4)];
        set(gca,'position',apos);
        set(gcf,'windowbuttonmotionfcn','grips(''image motion'')');
        set(gcf,'windowbuttonupfcn','uiresume');
        uiwait
        set(gcf,'units',unt);
        uirestore(state);

    case 'data buttondown'
        hnd = finddobj('current object');
        set(hnd,'string',get(gca,'tag'));
        grips('image buttondown');

    case 'internal image buttondown'
        cameraman('buttondown');
        set(finddobj('current object'),'string',get(gcbo,'tag'));

    case 'image motion'
        curpt = get(gcf,'currentpoint');
        apos = get(gca,'position');
        apos = [curpt(1)-apos(3)/2,curpt(2)-apos(4)/2,apos(3),apos(4)];
        set(gca,'position',apos);

    case 'image'
        answer = questdlg('what type of image','image','internal','external','internal');
        if strcmp(answer,'internal')
            varargout{1} = grips('internal image',varargin{1});
            return
        end
        [cdata,cmap] = imread(varargin{1});
        [rw,cl,d] = size(cdata);
        set(gcf,'colormap',cmap);
        ax = axes('parent',finddobj('figure'),'units','pixels','position',[0 0 cl rw],'xlim',[1 cl],'ylim',[1 rw],'ydir','reverse',...
            'visible','off','tag','image');
        im = image('parent',ax,'cdata',cdata,'buttondownfcn','grips(''image buttondown'')');
        varargout{1} = [ax;im];
    case 'avi'
        mov = aviread(varargin{1},1);
        ud.aviindex = 1;
        ud.avifile = varargin{1};
        cdata = mov(1).cdata;
        cmap = mov(1).colormap;
        [rw,cl,d] = size(cdata);
        set(gcf,'colormap',cmap);
        ax = axes('parent',finddobj('figure'),'units','pixels','position',[0 0 cl rw],'xlim',[1 cl],'ylim',[1 rw],'ydir','reverse',...
            'visible','off','tag','image','userdata',ud);
        im = image('parent',ax,'cdata',cdata,'buttondownfcn','grips(''image buttondown'')');
        varargout{1} = [ax;im];
    case 'data graph'
        clr = [1 1 1];
        if isstr(varargin{1})
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
            tg = ch{answer};
            yd = getydata(vl,pth);
        else
            tg = varargin{2};
            yd = varargin{1};
            clr = varargin{3};
        end
        if length(yd)<2
            return
        end
        [tp,ax] = currentobject;
        plt = finddobj('colorpallete');
        if ~isempty(plt)            
            clr = get(plt,'backgroundcolor');
        end
        if strcmp(tp,'graph');
            line('parent',ax,'color',clr,'ydata',yd,'xdata',(1:length(yd)),'tag',tg,'buttondownfcn','grips(''data buttondown'')');
            ylim = get(ax,'ylim');
            set(findobj(ax,'tag','slider'),'ydata',ylim);
        else
            ax = axes('parent',finddobj('figure'),'units','centimeters','position',[0 0 10 7.5],'xlim',[1 length(yd)],'tag',tg,'color',[0 0 0],'buttondownfcn','grips(''data buttondown'')',...
                'xcolor',[1 1 1],'ycolor',[1 1 1],'box','on','createfcn','grips(''graph createfcn'')');
            line('parent',ax,'color',clr,'ydata',yd,'xdata',(1:length(yd)),'tag',tg,'buttondownfcn','grips(''data buttondown'')');
            line('parent',ax,'color',[0 1 0],'ydata',get(ax,'ylim'),'xdata',[0 0],'tag','slider','buttondownfcn','grips(''data buttondown'')','clipping','on','linewidth',1);
            text('units','normalize','position',[.5 1],'horizontalalignment','center','verticalalignment','bottom','string',tg,'color',clr);
        end
        
        varargout{1} = ax;

    case 'resize graph'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'graph')
            return
        end
        [utp,val] = currentunits;
        unt = get(hnd,'units');
        set(hnd,'units','centimeters');
        apos = get(hnd,'position');
        switch varargin{1}
            case 'uparrow'
                apos(4) = apos(4)+val;
            case 'downarrow'
                apos(4) = apos(4)-val;
            case 'rightarrow'
                apos(3) = apos(3)+val;
            case 'leftarrow'
                apos(3) = apos(3)-val;
            otherwise
                return
        end
        set(hnd,'position',apos);
        set(hnd,'units',unt);

    case 'move iimage'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'internal image');
            return
        end
        [utp,val] = currentunits;
        frm = finddobj('frame','number');
        ud = get(hnd,'userdata');
        frm = min(max(frm,1),length(ud.ort));
        dis = ud.dis(frm,:);
        switch varargin{1}
            case 'uparrow'
                dis(2) = dis(2)-val;
            case 'downarrow'
                dis(2) = dis(2)+val;
            case 'rightarrow'
                dis(1) = dis(1)-val;
            case 'leftarrow'
                dis(1) = dis(1)+val;
            case 'pageup'
                dis(3) = dis(3)+val;
            case 'pagedown'
                dis(3) = dis(3)-val;
        end
        ud.dis(frm,:) = dis;
        set(hnd,'userdata',ud);
        setiimage(hnd,frm);

    case 'goto image'
        setimage(varargin{1});
    case 'goto data'
        setdata(varargin{1});
    case 'goto iimage'
        hnd = finddobj('internal image');
        for i = 1:length(hnd)
            setiimage(hnd(i),varargin{1});
        end
        
    case 'random task'
        fld = fieldnames(producer.grips);
        for i = 1:length(fld);
            randomtask(fld{i},getfield(producer.grips,fld{i}));
        end
        
    case 'mark'
        g = producer.grips;
        c = finddobj('controls');
        fxn = findobj(c,'style','togglebutton','value',1);
        if length(fxn)~=1
            errordlg('function not selected');
            return
        end
        fxn = get(fxn,'string');
        
        data = findobj(c,'tag','data');
        dud = get(data,'userdata');
        if isempty(dud)
            errordlg('no data');
            return
        end
        hi = finddobj('highlight');
        if isempty(hi)
            errordlg('no object selected');
            return
        end
        if ~actor('verify',hi);
            trg = get(hi,'tag');            
        else
            ud = get(hi,'userdata');
            if isstruct(ud)
                ud = 'head';
            end
            trg = {get(hi,'tag'),ud};
        end
        plt.target= trg;
        plt.value = dud;
        if ~isfield(g,fxn) || strcmp(fxn,'floor');
            g = setfield(g,fxn,plt);
        else            
            [g,lvl]= deleteduplicate(g,fxn,plt.target);                        
            g = setfield(g,fxn,{lvl+1},plt);
        end
        producer.grips = g;
        set(data,'foregroundcolor',[1 1 1]);
        
    case 'import data'
        data = uigetstruct('name2','choose your channel');
        if isempty(data)
            return
        end
        set(gcbo,'foregroundcolor',[0 1 0],'userdata',makevec(data));
        
    case 'reset mark'
        producer.grips = struct;
        
    case 'bind'
        ax = finddobj('axes');
        tg = unique(get(get(ax,'children'),'tag'));
        tg = union(tg,bodyparts);
        r = associatedlg(tg,tg,'bind objects (order = actor, bodypart, object) from:to');
        [rw,cl] = size(r);
        vl.from.actor = r{1,1};
        vl.from.bodypart = r{2,1};
        vl.to.actor = r{1,2};
        vl.to.bodypart = r{2,2};            
        if rw == 3
            vl.from.tag = r{3,1};
            vl.to.tag = r{3,2};
        end
        if isfield(producer.grips,'bind');
            indx = length(producer.grips);
            producer.grips.bind(indx+1) = vl;
        else
            producer.grips.bind = vl;
        end
        
    case 'linetrace buttondown'
        ud = get(gcbo,'userdata');        
        switch get(gcf,'selectiontype');
            case  'normal'
                ax = findobj('type','axes','tag','axes1');
            case 'alt'
                ax = findobj('type','axes','tag','axes2');
            otherwise
                return
        end
        if isempty(ax)
            return
        end
        if get(gcbo,'parent')== finddobj('axes');
            phnd = findobj(finddobj('axes'),'tag',ud);
            pud = get(phnd,'userdata');
            ud.puck = ud;
            ud.filename = pud.filename;
            set(gcbo,'parent',ax,'userdata',ud);
        else
            ud = ud.puck;
            set(gcbo,'parent',finddobj('axes'),'userdata',ud);
        end                            
            
end

function [ng,l] = deleteduplicate(g,fld,trg)

vl = getfield(g,fld);
for i = 1:length(vl);
    if min(strcmp(vl(i).target,trg));
        vl(i) = [];
        break
    end
end
ng = g;
ng = setfield(g,fld,vl);
l = length(vl);


function setdata(xd)
gr = finddobj('graph');
xd = [xd,xd];
for i = 1:length(gr)
    ln = findobj(gr(i),'tag','slider');    
    set(ln,'xdata',xd);
end

function setimage(frm)

im = finddobj('image');
for i = 1:length(im)
    ud = get(im(i),'userdata');
    if ~isstruct(ud)
        continue
    elseif ~isfield(ud,'avifile');
        continue
    end
    info = aviinfo(ud.avifile);
    if frm <1 || frm>info.NumFrames
        continue
    end
    mov = aviread(ud.avifile,frm);
    imhnd = findobj(im(i),'type','image');
    set(imhnd,'cdata',mov(1).cdata);
    set(im(i),'userdata',ud);
end

function setiimage(im,frm)
ud = get(im,'userdata');
if (frm>length(ud.ort)) || (frm < 1)
    return
end
gunit = [1 0 0;0 1 0;0 0 1];
[xd,yd,zd] = mtransform(gunit,ud.ort{frm},ud.xdata,ud.ydata,ud.zdata);
dis = ud.dis(frm,:);
xd = xd+dis(1);
yd = yd+dis(2);
zd = zd+dis(3);
set(im,'xdata',xd,'ydata',yd,'zdata',zd,'userdata',ud);



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

function hnd = internalimage(fl,xdim,ort,dis,nm)

if nargin ~= 1
    [cdata,cmap] = imread(fl);

    [r,c,d] = size(cdata);

    xinc = xdim/(c-1);
    xvec = (0:(c-1))*xinc;
    yvec = ((r-1):-1:0)'*xinc;
    yd = [];
    xd = [];
    for i = 1:c;
        yd = [yd,yvec];
    end
    for i = 1:r
        xd = [xd;xvec];
    end

    zd = zeros(size(xd));

    ud.xdata = xd;
    ud.ydata = yd;
    ud.zdata = zd;

    ud.ort = ort;
    ud.dis = dis;
    ud.index = 1;

    cdata = convertcdata(cdata,cmap);
else
    ud = fl;
    cdata = ud.cdata;
    ud = rmfield(ud,'cdata');
    nm = ud.name;
end

ax = finddobj('axes');


hnd = surface('parent',ax,'xdata',ud.xdata,'ydata',ud.ydata,'zdata',ud.zdata,'userdata',ud,'facecolor','flat','buttondownfcn','grips(''internal image buttondown'')',...
    'tag',nm,'edgecolor','none','cdata',cdata,'clipping','off','createfcn','grips(''internal image createfcn'')');
setiimage(hnd,1);


function ncd = convertcdata(cdata,cmap)
[r,c,d] = size(cdata);
if d == 1;
    ncd = cmap(cdata);
else
    ncd = double(cdata)/255;
end


function randomtask(task,data)
ax = finddobj('axes');
frm = finddobj('frame','number');
switch task
    case 'bind'        
        fac = data.from.actor;
        fbp = data.from.bodypart;
        if isfield(data,'frame');
            if frm ~= data.frame;
                return
            end
        end
        if isfield(data.from,'tag');
            fhnd = finddobj('object',fac,fbp,data.from.tag);
        else
            fhnd = finddobj('object',fac,fbp);
        end
                
        tac = data.to.actor;
        tbp = data.to.bodypart;
        if isempty(tac)
            bindall(data.from);
            return
        end
        
        if isfield(data.to,'tag');
            thnd = finddobj('object',tac,tbp,data.to.tag);
        else
            thnd = finddobj('object',tac,tbp);
        end
        if isempty(fhnd) || isempty(thnd)
            return
        end
        dis = getcenter(thnd)-getcenter(fhnd);        
        moveobject(fhnd,dis);
        
    case 'facealpha'                
        for i = 1:length(data);
            if isstr(data(i).target)
                hnd = findobj(ax,'tag',data(i).target);
            elseif iscell(data(i).target);                
                hnd = findpart(data(i).target{1},data(i).target{2});
            else
                continue
            end
            vl = data(i).value;
            vindx = min(max(frm,1),length(vl));
            vl = min(max(vl(vindx),0),1);
            set(hnd,'facealpha',vl);
        end      
%     case 'floor'
%         xlim = get(ax,'xlim');
%         mxlm = mean(xlim);
%         ylim = get(ax,'ylim');
%         mylm = mean(ylim);
%         
%         xlim = ((xlim-mxlm)*2)+mxlm;
%         ylim = ((ylim-mylm)*2)+mylm;
%         
%         vl = data(1).value;
%         vindx = min(max(frm,1),length(vl));
%         vl = min(max(vl(vindx),0),1);
%         hnd = findobj(ax,'tag','floor','type','patch');
%         if isempty(hnd);
%             hnd = patch('parent',ax,'tag','floor','facecolor',[.8 .8 .8],'edgecolor','none','buttondownfcn','grips(''buttondown'')','createfcn','grips(''createfcn'')',...
%                 'clipping','off');
%         end
%         vr = [xlim(1),ylim(1),0;...
%             xlim(2),ylim(1),0;...
%             xlim(2),ylim(2),0;...
%             xlim(1),ylim(2),0];
%         fc = [1 2 3 4];
%         set(hnd,'vertices',vr,'faces',fc,'facealpha',vl);
    case 'trace'
        ax = finddobj('axes');
        hnd = findobj(ax,'tag','trace');
        if isempty(hnd)
            hnd = patch('parent',ax,'tag','trace','vertices',[],'faces',[],'facevertexcdata',[],'edgecolor','none','facecolor','flat','facelighting','gouraud','clipping','off','buttondownfcn','grips(''buttondown'')','vertexnormals',[],'facevertexalphadata',1,'facealpha',.6);
        end
        if finddobj('frame','number')==1
           set(hnd,'vertices',[],'faces',[],'facevertexcdata',[]);
        end
        vr = get(hnd,'vertices');
        fc = get(hnd,'faces');
        cdata = get(hnd,'facevertexcdata');   
        vn = get(hnd,'vertexnormals');
        for i = 1:length(data)
            target = findobj(ax,'tag',data{i});
            if isempty(target)
                continue
            end
            for j = 1:length(target)
                [vr,fc,cdata,vn] = traceobj(target(j),vr,fc,cdata,vn);
            end
        end
        set(hnd,'vertices',vr,'faces',fc,'facevertexcdata',cdata,'vertexnormals',vn);
    case 'freeze'
        prp = finddobj('props');
        for i = 1:length(data)
            hnd = findobj(prp,'tag',data{i});
            if isempty(hnd)
                continue
            end
            hud = get(hnd,'userdata');
            if isfield(hud,'dis');
                if frm == length(hud.dis(:,1))
                    freeze(hnd);
                end
            end
        end
        
    case 'linetrace'
        ax = finddobj('axes');
        
        for i = 1:length(data)
            lhnd = findobj(ax,'type','line','userdata',data(i).target,'tag','linetrace');
            thnd = findobj(ax,'tag',data(i).target,'type','patch');
            tud = get(thnd,'userdata');
            if frm > length(tud.dis(:,1))
                continue
            end
            xd = tud.dis(frm,1);
            yd = tud.dis(frm,2);
            zd = tud.dis(frm,3);
            if isempty(lhnd)
                line('parent',ax,'color',data(i).color,'userdata',data(i).target,'tag','linetrace','buttondownfcn','grips(''linetrace buttondown'')','xdata',xd,'ydata',yd,'zdata',zd);
                return
            end
            nxd = get(lhnd,'xdata');
            nyd = get(lhnd,'ydata');
            nzd = get(lhnd,'zdata');
            nxd(frm) = xd;
            nyd(frm) = yd;
            nzd(frm) = zd;
            
            nxd(frm+1:end) = [];
            nyd(frm+1:end) = [];
            nzd(frm+1:end) = [];
            
            set(lhnd,'xdata',nxd,'ydata',nyd,'zdata',nzd);
        end
        
    case 'GrootSuntay'
        prp = finddobj('props');
        if ~isempty(data)
            nprp = [];
            for i = 1:length(data)
                nprp = union(nprp,findobj(prp,'tag',data{i}));
            end
            prp = nprp;
        end
        vr = [];
        fc = [];
        cdata = [];
        frm = finddobj('frame','number');
        for i = 1:length(prp);
            pud = get(prp(i),'userdata');
            if ~isfield(pud,'GrootSuntay') && ~isfield(pud,'JointCenter')
                continue
            end
            if length(pud.GrootSuntay.vectors) < frm
                continue
            end
            v = pud.GrootSuntay.vectors{frm}*10;
            dis = pud.JointCenter(frm,:);
            [fvr,ffc] = fan(dis,v(1:2,:));
            [avr,afc] = fan(dis,v(3:4,:));
            [tvr,tfc] = fan(dis,v(5:6,:));
            [vr,fc,cdata] = mergepatch(vr,fc,cdata,fvr,ffc,[1 0 0]);
            [vr,fc,cdata] = mergepatch(vr,fc,cdata,avr,afc,[0 1 0]);
            [vr,fc,cdata] = mergepatch(vr,fc,cdata,tvr,tfc,[0 0 1]);
        end
        if isempty(vr)
            return
        end
        ax = finddobj('axes');
        hnd = findobj(ax,'tag','GrootSuntay','type','patch');
        if isempty(hnd)
            patch('parent',ax,'vertices',vr,'faces',fc,'cdata',cdata,'edgecolor',[0 0 0],'facecolor','flat','facelighting','gouraud','clipping','off','tag','GrootSuntay');
        else
            set(hnd,'vertices',vr,'faces',fc,'cdata',cdata);
        end
        
    case 'fan'
        fld = fieldnames(data);
        for i = 1:length(fld)
            createfan(fld{i},data.(fld{i}).marker,data.(fld{i}).size,data.(fld{i}).color);
        end
    case 'AnatomicalAxes'
        prp = finddobj('props');
        if ~isempty(data)
            nprp = [];
            for i = 1:length(data)
                nprp = union(nprp,findobj(prp,'tag',data{i}));
            end
            prp = nprp;
        end
        vr = [];
        fc = [];
        cdata = [];
        [ovr,ofc,ocdata] = k2graphics('orientation',gunit,[0 0 0],10);
        frm = finddobj('frame','number');
        for i = 1:length(prp);            
            [dis,ort] = getanatomical(prp(i),frm);
            if isempty(dis)
                continue
            end
            nvr = ctransform(ort,gunit,ovr);
            nvr = displace(nvr,dis);
            [vr,fc,cdata] = mergepatch(vr,fc,cdata,nvr,ofc,ocdata);
        end
        ax = finddobj('axes');
        hnd = findobj(ax,'tag','Orientation','type','patch');
        if isempty(hnd)
            patch('parent',ax,'vertices',vr,'faces',fc,'cdata',cdata,'edgecolor','none','facecolor','flat','facelighting','gouraud','clipping','off','tag','Orientation');
        else
            set(hnd,'vertices',vr,'faces',fc,'cdata',cdata);
        end
           
    case 'com'
        prp = finddobj('props');
        for i = 1:length(data);
            phnd = findobj(prp,'tag',data{i});
            vr = get(phnd,'vertices');
            cm = vr(end,:);
            hnd = findobj('type','surface','tag',[data{i},'(com)']);
            if isempty(hnd)
                [x,y,z] = sphere(20);
                ud.xdata = x*2.5;
                ud.ydata = y*2.5;
                ud.zdata = z*2.5;
                tg = [data{i},'(com)'];
                surface('xdata',ud.xdata+cm(1),'ydata',ud.ydata+cm(2),'zdata',ud.zdata+cm(3),'tag',tg,'facecolor',[1 0 0],'edgecolor','none','userdata',ud);
            else
                ud = get(hnd,'userdata');
                set(hnd,'xdata',ud.xdata+cm(1),'ydata',ud.ydata+cm(2),'zdata',ud.zdata+cm(3));
            end
        end
            
end

function [dis,ort] = getanatomical(phnd,frm)
ud = get(phnd,'userdata');
tg = get(phnd,'tag');
dis = [];
ort = [];
arm = [-1 0 0;0 -1 0;0 0 1];
Rflip = [1 0 0;0 -1 0;0 0 1];
Lflip = [1 0 0;0 1 0;0 0 1];
Tflip = [1 0 0;0 -1 0;0 0 1];
Pflip = [1 0 0;0 -1 0;0 0 1];
THflip = [1 0 0;0 1 0;0 0 -1];

switch tg
    case 'RightTibia'
        ort = Rflip;
    case'RightFoot'
        ort = Rflip;
    case 'RightFemur'
        ort = Rflip;
    case 'Pelvis'
        ort = gunit;
    case 'LeftTibia'
        ort = Lflip;
    case 'LeftFoot'
        ort = Lflip;
    case 'LeftFemur'
        ort = Lflip;
    case 'Thorax'
        ort = Tflip*THflip;
    case 'RightRadius'
        ort = arm*Rflip;
    case 'RightHand'
        ort = arm*Rflip;
    case 'RightHumerus'
        ort = arm*Rflip;
    case 'LeftRadius'
        ort = arm*Lflip;
    case 'LeftHand'
        ort =arm*Lflip;
    case 'LeftHumerus'
        ort = arm*Lflip;
    case 'Head'
        ort = gunit;
    otherwise
        return
end
frm = min(frm,length(ud.ort));
dis = mean(get(phnd,'vertices'));
ort = makeunit(ud.ort{frm})*ort;

function [nvr,nfc,ncdata,nvn] = traceobj(hnd,vr,fc,cdata,vn)

lvr = size(vr);
lvr = lvr(1);

hvr = get(hnd,'vertices');
hfc = get(hnd,'faces');
hvn = get(hnd,'vertexnormals');
if ~isempty(find(isnan(hvr)))
    nvr = vr;
    nfc = fc;
    ncdata = cdata;
    nvn = vn;
    return
end
hcdata = zeros(size(hvr));
if isnumeric(get(hnd,'facecolor'))
    clr = get(hnd,'facecolor');    
    hcdata(:,1) = clr(1);
    hcdata(:,2) = clr(2);
    hcdata(:,3) = clr(3);
else
    hfvcdata = get(hnd,'facevertexcdata');
    if length(hfvcdata(:,1))~=length(hvr(:,1))
        for i = 1:3
            hcdata(hfc(:,i),:) = hfvcdata;
        end
    else
        hcdata = hfvcdata;
    end
end
nvn = [vn;hvn];
nvr = [vr;hvr];
nfc = stackface(fc,hfc+lvr);
ncdata = [cdata;hcdata];
        
        
    
function r = stackface(top,bot)

if isempty(top);
    r = bot;
    return
elseif isempty(bot);
    r = top;
    return
end

st = size(top);
bt = size(bot);
if st(2)< bt(2);
    top(:,bt(2)) = top(:,end);
elseif st(2) > bt(2)
    bot(:,st(2)) = bot(:,end);
end
r = [top;bot];


function moveobject(hnd,dis)
ud = get(hnd,'userdata');
if actor('verify',hnd);
    ac = get(hnd,'tag');   
else
    hd = ud.parent;
    ac = get(hd,'tag');
end
actor('displace',ac,dis);


function r = getcenter(hnd)

if actor('verify',hnd)
    bp = get(hnd,'userdata');
    ac = get(hnd,'tag');
    if isstruct(bp)
        bp = 'head';
    end
    hud = findpart(ac,bp);
    r = getfield(hud.currentposition,bp);
else
    switch get(hnd,'type');
        case 'surface'
            r = [mean(mean(get(hnd,'xdata'))),mean(mean(get(hnd,'ydata'))),mean(mean(get(hnd,'zdata')))];
        case 'patch'
            r = mean(get(hnd,'vertices'));
    end
end
        
        
        
        
function r = makevec(m)
[rw,cl] = size(m);
if rw == 1
    r= m';
elseif cl == 1
    r = m;
else
    r = m(:,1);
end

function r = bodyparts

r = {'trunk','Rupperarm','Lupperarm','pelvis','neck','Rforearm','Lforearm','Rhand','Lhand',...
    'head','Rthigh','Lthigh','Lshank','Rshank','Lfoot','Rfoot'};

function bindall(data)
if isempty(data.tag)
    obj = findpart('all',data.bodypart);
    src = findpart(data.actor,data.bodypart);
else    
    obj = findobj(finddobj('axes'),'tag',data.tag);
    src = finddobj('object',data.actor,data.bodypart,data.tag);
    if isempty(src)
        src = obj(1);
    end
end

ctr = getcenter(src);
obj = setdiff(obj,src);
for i = 1:length(obj)
    octr = getcenter(obj(i));
    dis = ctr-octr;
    moveobject(obj(i),dis);
end



function freeze(hnd)
vr = get(hnd,'vertices');
fc = get(hnd,'faces');
cdata = get(hnd,'cdata');

fhnd = findobj(finddobj('axes'),'tag','freeze');
if isempty(fhnd)
    patch('tag','freeze','parent',finddobj('axes'),'cdata',cdata,'vertices',vr,'faces',fc,'facecolor','flat','edgecolor','none','facelighting','gouraud')
else
    fvr = get(fhnd,'vertices');
    ffc = get(fhnd,'faces');
    fcdata = get(fhnd,'cdata');
    lfvr = length(fvr(:,1));
    fvr = [fvr;vr];
    ffc = [ffc;fc+lfvr];
    fcdata = [fcdata;cdata];
    set(fhnd,'cdata',fcdata,'vertices',fvr,'faces',ffc);
end

function createfan(tg,data,sz,fclr)
frm = finddobj('frame','number');
mrk = finddobj('marker');
pt1 = findobj(mrk,'tag',data{1});
pt1 = get(pt1,'userdata');
if frm > length(pt1.dis(:,1))
    return
end
pt1 = pt1.dis(frm,:);

vertex = findobj(mrk,'tag',data{2});
vertex = get(vertex,'userdata');
vertex = vertex.dis(frm,:);

vec1 = pt1-vertex;

switch data{3}
    case 'xy'
        vec2 = vec1;
        vec2(3) = 0;
    case 'xz'
        vec2 = vec1;
        vec2(2) = 0;
    case 'yz'
        vec2 = vec1;
        vec2(1) = 0;
    otherwise
        pt2 = findobj(mrk,'tag',data{3});
        pt2 = get(pt2,'userdata');
        pt2 = pt2.dis(frm,:);
        vec2 = pt2-vertex;
end

vec = makeunit([vec1;vec2])*sz;
[vr,fc] = fan(vertex,vec);
ax = finddobj('axes');
hnd = findobj(ax,'type','patch','tag',tg);
if ~isempty(hnd)
    set(hnd,'faces',fc,'vertices',vr);
else
    patch('parent',ax,'vertices',vr,'faces',fc,'tag',tg,'facecolor',fclr,'edgecolor',[0 0 0])
end