function varargout = director(action,varargin)


% updated by Phil Dixon Oct 2009 
% -list of channels contains all changes (edited file marker.m line 114)
% - you can reload marker data using "reload marker"
%
% updated by Phil Dixon March 2010
% - you can load bones by clicking 'load bones' instead of using quick open
% - quick open has been removed from GUI
% - you can select to load a 'lower-limb' or 'full' plugin gait model 
%
% updated by Phil Dixon December 2010
% - you can now plot any channel you want as long as it is a n x 1 channel
%
global producer;
global p; 
global f;

if nargin ==0
    action = 'space';
end

switch action
    case 'space'
        if ~isempty(finddobj('figure'))
            figure(finddobj('figure'))
            return
        end
        fig = figure('tag','space','color',[0 0 0],'name','director',...
            'menubar','none','numbertitle','off','keypressfcn','dkeypress',...
            'buttondownfcn','director(''buttondown'')','doublebuffer','on','units','centimeters','resizefcn','director(''resize'')');
        mn = uimenu('parent',fig,'label','director','tag','current person');
        uimenu('parent',mn,'label','director','callback','director(''person'')');        
        uimenu('parent',mn,'label','cameraman','callback','director(''person'')');
        uimenu('parent',mn,'label','actor','callback','director(''person'')');
        uimenu('parent',mn,'label','lighting','callback','director(''person'')');
        uimenu('parent',mn,'label','costume','callback','director(''person'')');
        uimenu('parent',mn,'label','grips','callback','director(''person'')');
        uimenu('parent',mn,'label','props','callback','director(''person'')');
        ud.mark = [];
        lbl = (-1000:100:1000);
        ax = axes('parent',fig,'units','normalized','position',[0 0 1 1],'dataaspectratio',[1 1 1],'color',[0 0 0],...
            'xcolor',[0 0 0],'ycolor',[0 0 0],'zcolor',[0 0 0],'xtick',[],'ytick',[],'ztick',[],'buttondownfcn','cameraman(''buttondown'');',...
            'view',[114 25],'visible','on','userdata',ud,'tag','space','cameraviewanglemode','manual','xlim',[-1000 1000],'ylim',[-1000 1000],'zlim',[0 500],...
            'xtickmode','auto','ytickmode','auto','xgrid','off','ygrid','off','cameraposition',[200 200 250]*5,'cameratarget',[0 0 0],...
            'xtick',lbl,'ytick',lbl,'xticklabel',[],'yticklabel',[],'gridlinestyle','-','cameraviewangle',10);
        light('position',get(ax,'cameraposition'),'buttondownfcn','cameraman(''buttondown'')','parent',ax,'tag','camera light','style','local');
        cm = uicontextmenu('tag','main','callback','director(''contextmenu'')');
        uicontrol('style','pushbutton','units','centimeters','backgroundcolor',[.8 .8 .8],'foregroundcolor',[0 0 0],...
            'tag','current object','position',[.1 .1 1.5 .5],'string','');
        uicontrol('style','text','units','centimeters','backgroundcolor',[.8 .8 .8],'foregroundcolor',[0 0 0],...
            'tag','frame','position',[1.7 .1 1.5 .5],'string','1');

        uicontrol('style','togglebutton','units','centimeters','backgroundcolor',[.9 .9 .9],'foregroundcolor',[0 0 0],...
            'tag','displacement','position',[3.3 .1 1.2 .5],'string','1 cm','userdata',1,'callback','director(''units'')',...
            'deletefcn','director(''units delete'')','value',1,'uicontextmenu',cm);
        uicontrol('style','togglebutton','units','centimeters','backgroundcolor',[.8 .8 .8],'foregroundcolor',[0 0 0],...
            'tag','angle','position',[4.6 .1 1.2 .5],'string','1 deg','userdata',1,'callback','director(''units'')',...
            'deletefcn','director(''units delete'')','uicontextmenu',cm);
        uicontrol('style','togglebutton','units','centimeters','backgroundcolor',[.8 .8 .8],'foregroundcolor',[0 0 0],...
            'tag','volume','position',[5.9 .1 1.2 .5],'string','1 cm3','userdata',1,'callback','director(''units'')',...
            'deletefcn','director(''units delete'')','uicontextmenu',cm);
        xd = [lbl,lbl];
        xd(1:2:end) = lbl;
        xd(2:2:end) = lbl;
        yd = xd;
        yd(1:4:end) = max(lbl);
        yd(2:4:end) = min(lbl);
        yd(3:4:end) = min(lbl);
        yd(4:4:end) = max(lbl);
        
        nyd = [yd,fliplr(xd)];
        nxd = [xd,yd];
        line('parent',ax,'xdata',nxd,'ydata',nyd,'zdata',zeros(size(nyd)),'color',[0 0 0],'buttondownfcn','cameraman(''buttondown'');','tag','camera grid');
        
        ax2 = axes('unit','centimeters','position',[0 0 3 3],'cameraviewangle',40,'cameraposition',[2 2 2],'cameratarget',[0 0 0],'color',[.8 .8 .8],...
            'visible','off','tag','orientation window');
        [x,y,z] = arrow([0 0 0],[1 0 0],20);        
        surface('xdata',x,'ydata',y,'zdata',z,'facecolor',[1 0 0],'edgecolor','none','buttondownfcn','director(''orientation buttondown'')','facelighting','gouraud','tag','x');
        [x,y,z] = arrow([0 0 0],[0 1 0],20);        
        surface('xdata',x,'ydata',y,'zdata',z,'facecolor',[0 1 0],'edgecolor','none','buttondownfcn','director(''orientation buttondown'')','facelighting','gouraud','tag','y');
        [x,y,z] = arrow([0 0 0],[0 0 1],20);        
        surface('xdata',x,'ydata',y,'zdata',z,'facecolor',[0 0 1],'edgecolor','none','buttondownfcn','director(''orientation buttondown'')','facelighting','gouraud','tag','z');
        
        light('parent',ax2,'position',[3 0 0]);
        director('units load');
        producer.mov = [];
        producer.cut = 0;    
        producer.gravity = 1;
        producer.grips = struct;
        director('person','director');
        warning off;
        director('resize')
    case 'save'
        switch currentobject
            case 'bargraph'
                bargraphfxn('save');
            case 'internal image'
                grips('save internal image');
            case 'accessory'
                accessoryfxn('save');
            case 'special object'
                specialobject('save');
            case 'props'
                props('save');
        end
        
    case 'clear all objects'
        ax = finddobj('axes');
        delete(findobj(ax,'type','patch'));
        delete(findobj(ax,'type','surface'));
        

    case 'open'
        [f,p] = uigetfile('*.*','open file');
        if f == 0
            return
        end
        cd(p);
        [ext,fl] = extension(f);
        hnd = [];
        delete(finddobj('graph'));
        switch lower(ext)
            case '.zoo'
                distributedata([p,f],'zoo');
                marker('load zoo',[p,f]);
            case '.bmp'
                hnd = grips('image',[p,f]);
            case '.avi'
                hnd = grips('avi',[p,f]);
            case '.ort'
                actor('load orientation',[p,f]);
            case '.body'
                [hnd,f] = actor('create',[p,f]);
            case '.dis'
                actor('load displacement',[p,f]);
            case '.cam'
                cameraman('load',[p,f]);
            case '.iim'
                grips('load internal image',[p,f])
            case '.acs'
                accessoryfxn('load',[p,f]);
            case '.spo'
                costume('load special',[p,f]);
            case '.cos'
                costume('load',[p,f]);
            case '.tool'
                sculpttool('load',[p,f]);
            case '.cdata'
                actor('load cdata',[p,f]);
            case '.grip'
                grips('load',[p,f]);
            case '.light'
                lightman('load',[p,f]);
            case '.prop'
                props('load',[p,f]);
            case '.c3d'
                marker('load c3d',[p,f]);
            case '.z3d'
                marker('load z3d',[p,f]);                
        end

        if ~isempty(hnd)
            set(finddobj('current object'),'string',f);
        end
        set(gcf,'name',f);
    case 'resize'
        fig = finddobj('figure');
        ax = finddobj('orientation window');
        fpos = get(fig,'position');
        apos = get(ax,'position');
        apos(1) = fpos(3)-apos(3);
        apos(2) = fpos(4)-apos(4);
        set(ax,'position',apos);
        
    case 'reload markers'
       marker('load zoo',[p,f])
        
    case 'load bones'
        
        d=which('director'); % returns path to ensemlber
        path = pathname(d) ;  % local folder where director resides
         
        bones = [path,'Cinema objects\bones\golembones'];
        
        openall(bones);
        director('first position');
        
       
%     case 'quick open'
%         fld = uigetfolder;
%         if isempty(fld)
%             return
%         end
%         cd(fld)
%         openall(fld);
%         director('first position');
        
    case 'multi open'
        fld = uigetfolder;
        if isempty(fld)
            return
        end
        cd(fld)
        multiopen(fld)

    case 'units'
        [unt,all] = finddobj('units');
        set(all,'value',0,'backgroundcolor',[.8 .8 .8]);
        set(gcbo,'value',1,'backgroundcolor',[.9 .9 .9]);
        figure(gcf);

    case 'change units'
        unt = get(gco,'string');
        indx = findstr(unt,' ');
        unt = unt(indx:end);
        answer = inputdlg(unt,get(gco,'tag'));
        if isempty(answer)
            return
        elseif isempty(answer{1})
            return
        end
        num = str2num(answer{1});
        if isempty(num)
            return
        end
        set(gco,'userdata',num,'string',[num2str(num),unt]);

    case 'units delete'
        global unitvar
        [tmp,all] = finddobj('units');
        lvar = length(unitvar)+1;

        unitvar(lvar).tag = get(gcbo,'tag');
        unitvar(lvar).userdata = get(gcbo,'userdata');
        unitvar(lvar).string = get(gcbo,'string');
        if length(all) == 1;
            fl = which('unitmenu.prf');
            save(fl,'unitvar');
            clear global unitvar
        end

    case 'units load'
        fl = which('unitmenu.prf');
        t = load(fl,'-mat');
        [tmp,all] = finddobj('units');
        for i = 1:length(t.unitvar)
            obj = findobj(all,'tag',t.unitvar(i).tag);
            set(obj,'userdata',t.unitvar(i).userdata,'string',t.unitvar(i).string);
        end

    case 'person'
        pt = finddobj('person menu');
        if nargin == 1                    
            cblb = get(gcbo,'label');
        else
            cblb = varargin{1};
        end
        
        set(pt,'label',cblb);
        menu(cblb);
        

    case 'contextmenu'
        delete(get(gcbo,'children'));
        [tmp,all] = finddobj('units');
        if actor('verify',gco);
            uimenu(gcbo,'label','next','callback','actor(''next sequence'')');
            uimenu(gcbo,'label','prev','callback','actor(''prev sequence'')');
            uimenu(gcbo,'label','load sequence','callback','actor(''load sequence'')');
        elseif ~isempty(intersect(gco,all))
            uimenu(gcbo,'label','change','callback','director(''change units'')');
        end

    case 'colorpallete'
        if ~isempty(finddobj('colorpallete'));
            delete(finddobj('colorpallete'));
            return
        end
        [tp,hnd] = currentobject;
        switch tp
            case 'actor'
                clr = get(hnd(1),'facecolor');
            case 'bargraph'
                clr = get(hnd,'facecolor');
            otherwise
                clr = [.8 .8 .8];
        end
        uicontrol('style','pushbutton','tag','color','units','centimeters','position',[.1 .7 1.5 .5],'backgroundcolor',clr,'callback','director(''color callback'')');

    case 'color callback'
        clr = colorpallete(get(gcbo,'backgroundcolor'));
        set(finddobj('colorpallete'),'backgroundcolor',clr);

    case 'preview'
        producer.cut = 0;
        tp = finddobj('top menu');
        set(tp,'enable','off');
        set(findobj(tp,'label','play'),'enable','on');
        set(gcbo,'label',' cut  ','callback','director(''preview cut'')','enable','on');
        cameraman('new film');
        uic = findobj(gcf,'type','uicontrol','visible','on');
        set(uic,'visible','off');
        index = finddobj('frame','number');
        hnd = finddobj('frame');
        while ~producer.cut
            index = index+1;
            %specialobject('clear');
            mark('next');
            set(gcf,'name',['preview: frame ',num2str(index)]);
            set(hnd,'string',num2str(index));
        end
        set(uic,'visible','on');
        set(finddobj('top menu'),'enable','on');
        set(gcf,'name','director');

    case 'action'
        producer.cut = 0;
        set(finddobj('top menu'),'enable','off');
        set(gcbo,'label',' cut  ','callback','director(''cut'')','enable','on');
        cameraman('new film');
        uic = findobj(gcf,'type','uicontrol','visible','on');
        set(uic,'visible','off');
        cameraman('record');
        index = 1;
        hnd = finddobj('frame');
        while ~producer.cut
            index = index+1;
            mark('next');
            cameraman('record');
            set(gcf,'name',['preview: frame ',num2str(index)]);
            set(hnd,'string',num2str(index));
        end
        set(uic,'visible','on');
        set(finddobj('top menu'),'enable','on');

    case 'cut'
        set(gcbo,'label','action','callback','director(''action'')');
        producer.cut = 1;

    case 'preview cut'
        set(gcbo,'label','practice','callback','director(''preview'')');
        producer.cut = 1;

    case 'first position'        
        cameraman('new film');
        mark('goto',1);
        delete(findobj(finddobj('axes'),'tag','trace'));
    case 'goto'
        mark('goto',varargin{1});
    case 'next frame'
        mark('next');

    case 'prev frame'
        mark('prev');
    case 'cleanup'
        set(gcf,'windowbuttondownfcn','');
        uic = findobj(gcf,'type','uicontextmenu');
        uic = setdiff(uic,finddobj('contextmenu'));
        for i = 1:length(uic);
            set(findobj('uicontextmenu',uic(i)),'uicontextmenu',[]);
            delete(uic(i));
        end
        delete(finddobj('garbage'));       
        set(finddobj('actor'),'buttondownfcn','actor(''buttondown'')');

    case 'next person'
        nextperson(varargin{1});

    case 'next mark'
        mark('next');
    case 'prev mark'
        mark('prev');
        
    case 'refresh'
        mark('refresh');
    case 'clean object';
        [tp,hnd] = currentobject;
        switch tp
            case 'costume'
                costume('clean',hnd);
        end        
        
    case 'gravity'
        switch get(gcbo,'checked')
            case 'on'
                set(gcbo,'checked','off');
                producer.gravity = 0;
            case 'off'
                set(gcbo,'checked','on');
                producer.gravity = 1;
        end
        
    case 'orientation buttondown'
        tg = get(gcbo,'tag');
        switch get(gcf,'selectiontype')
            case 'alt'
                move(tg,'neg');
            case 'normal'
                move(tg);
        end
        
    case 'goto callback'
        frm = inputdlg({'goto frame'},'goto');
        director('goto',str2num(frm{1}));
        delete(findobj(finddobj('axes'),'tag','trace'));

        
        
    case 'show hindfoot vectors'
        
        marker
        disp('showing vectors')
        
        
end









function mark(action,varargin)
frm = finddobj('frame','number');

switch action
    case 'next'
        frm = frm+1;
        direction = 'forward';
    case 'prev'
        frm = frm-1;
        direction = 'backward';
    case 'goto'        
        nfrm = varargin{1};
        if nfrm > frm
            direction = 'forward';
        elseif nfrm < frm
            direction = 'backward';
        else
            direction = 'still';
        end
        frm = nfrm;
    case 'refresh'
        direction = 'still';
end
frm = max(frm,1);
set(finddobj('frame'),'string',num2str(frm));
actor('goto',frm);
grips('goto image',frm);
grips('goto data',frm);
grips('goto iimage',frm);
marker('goto',frm);
specialobject('stick');
costume('stick');
accessoryfxn('stick');
grips('random task');
props('goto',frm);
cameraman('goto',frm,direction);

lightman('refresh');


pause(.1);


function menu(action)
fig = finddobj('figure');
mn = finddobj('person menu');
delete(setdiff(findobj('type','uimenu','parent',fig),mn));
delete(finddobj('controls'));
delete(finddobj('bomb'));
delete(finddobj('costume pointer'));
set(finddobj('actor'),'facealpha',1,'edgecolor','none');
controls(action);
switch action
    case 'director'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
%         uimenu(mn,'label','quick open','callback','director(''quick open'')');   
        uimenu(mn,'label','load bones','callback','director(''load bones'')');
        uimenu(mn,'label','reload markers','callback','director(''reload markers'')');
        uimenu(mn,'label','save','callback','director(''save'')');
        uimenu(mn,'label','color','callback','director(''colorpallete'')');

        mn = uimenu(fig,'label','object');
        uimenu(mn,'label','ice','callback','grips(''ice'');');
        uimenu(mn,'label','invisible wand','callback','director(''wand'')');
        if isgravity
            chk = 'on';
        else
            chk = 'off';
        end
        uimenu(mn,'label','gravity','checked',chk,'callback','director(''gravity'')');
        uimenu(mn,'label','delete all objects','callback','director(''clear all objects'')');
        mn1 = uimenu(fig,'label','play');
        uimenu(mn1,'label','practice','callback','director(''preview'')','accelerator','p');
        uimenu(mn1,'label','first position','callback','director(''first position'')','accelerator','1');
        uimenu(mn1,'label','go to','callback','director(''goto callback'')');
     
        mn = uimenu(fig,'label','OFM analysis');
        uimenu(mn,'label','show hindfoot vectors','callback','director(''show hindfoot vectors'')');
        uimenu(mn,'label','show tibia vectors','callback','director(''show tibia vectors'')');
        uimenu(mn,'label','show forefoot vectors','callback','director(''show forefoot vectors'')');
        uimenu(mn,'label','show hallux vectors','callback','director(''show hallux vectors'')');
 
        set(gcf,'name','director');
        
    case 'cameraman'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','save','callback','cameraman(''save'')');
        mn = uimenu(fig,'label','tools');
        uimenu(mn,'label','make first position','callback','cameraman(''make first position'')');        
        uimenu(mn,'label','clear','callback','cameraman(''clear'')');
        uimenu(fig,'label','practice','callback','director(''preview'')');
        uimenu(fig,'label','first position','callback','director(''first position'')');
        set(gcf,'name','cameraman');
    case 'actor'       
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','save displacement','callback','actor(''save displacement'')');
        uimenu(mn,'label','save orientation','callback','actor(''save orientation'')');
        uimenu(mn,'label','save color data','callback','actor(''save cdata'')');
        
        mn = uimenu(fig,'label','filter','callback','filtermenu(''start'')');
        uimenu(mn,'label','orientation','callback','actor(''filter orientation'')');
        uimenu(mn,'label','displacement','callback','actor(''filter displacement'')');
        
        mn = uimenu(fig,'label','rotate');
        mn2 = uimenu(mn,'label','body');
        uimenu(mn2,'label','90','callback','actor(''rotate body'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','180','callback','actor(''rotate body'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','270','callback','actor(''rotate body'',str2num(get(gcbo,''label'')))');
        
        mn2 = uimenu(mn,'label','orientation');
        uimenu(mn2,'label','90','callback','actor(''rotate ort'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','180','callback','actor(''rotate ort'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','270','callback','actor(''rotate ort'',str2num(get(gcbo,''label'')))');
        
        mn2 = uimenu(mn,'label','flip orientation');
        uimenu(mn2,'label','x','callback','actor(''flip ort'',get(gcbo,''label''))');
        uimenu(mn2,'label','y','callback','actor(''flip ort'',get(gcbo,''label''))');
        uimenu(mn2,'label','z','callback','actor(''flip ort'',get(gcbo,''label''))');
        
        mn = uimenu(fig,'label','special object');
        uimenu(mn,'label','create','callback','specialobject(''setup'')');
        uimenu(mn,'label','copy','callback','specialobject(''copy'')');
        uimenu(mn,'label','copy all','callback','specialobject(''copy all'')');
        uimenu(mn,'label','edit bargraph','callback','specialobject(''edit bargraph'')');
        uimenu(mn,'label','ramp speed','callback','actor(''ramp speed'')')
    case 'lighting'
        uimenu(fig,'label','create','callback','lightman(''create'')');
        uimenu(fig,'label','save','callback','lightman(''save'')');
        set(gcf,'name','lighting');        
    case 'costume'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','open all','callback','costume(''quick load'')');
        uimenu(mn,'label','save','callback','costume(''save'')');
        mn = uimenu(fig,'label','object');
        uimenu(mn,'label','fabric','callback','costume(''fabric'')');
        uimenu(mn,'label','clean','callback','director(''clean object'')');
        uimenu(mn,'label','delete','callback','costume(''delete'')','separator','on');
        
        mn = uimenu(fig,'label','tool');
        uimenu(mn,'label','rasp','callback','sculpttool(''rasp'')');
        uimenu(mn,'label','plane','callback','sculpttool(''plane'')');        
    case 'grips'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','save','callback','grips(''save'')');
        uimenu('parent',fig,'label','bind','callback','grips(''bind'')');
    case 'props'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','open with markers','callback','props(''load with markers'')');
        uimenu(mn,'label','save','callback','props(''save'')');
        
        mn = uimenu(fig,'label','tools');
        uimenu(mn,'label','associate markers','callback','props(''associate marker'')');
        uimenu(mn,'label','puck trajectory','callback','props(''puck trajectory'')');
end
director('cleanup');
set(gcf,'name',action);


function nextperson(action)

ordr = {'director','cameraman','actor','lighting','costume'};
cindx = find(strcmp(ordr,{currentperson}));
switch action
    case 'next'
        cindx = cindx+1;
    case 'prev'
        cindx = cindx-1;
end

if cindx >length(ordr)
    cindx = 1;
elseif cindx <1
    cindx = length(ordr);
end
director('person',ordr{cindx});


function openall(pth)

if ~strcmp(pth(end),'\');
    pth = [pth,'\'];
end

fl = engine('path',pth);

[bodyf,dataf,fl] = separatefiles(fl);
for i = 1:length(bodyf)
    [f,p] = partitionfile(bodyf{i});
    actor('create',bodyf{i},extension(f,''));
end

fl = [fl;dataf];
for i = 1:length(fl)
    filename = fl{i};
    [f,p] = partitionfile(fl{i});
    switch lower(extension(filename));        
        case '.ort'
            actor('load orientation',filename);
        case '.dis'
            actor('load displacement',filename);
        case '.cdata'
            actor('load cdata',filename);            
        case '.cam'
            cameraman('load',filename);
        case '.spo'
            costume('load special',[p,f]);
        case '.cos'
            costume('load',filename,extension(f,''));
        case '.grip'
            grips('load',filename);
        case '.light'
            lightman('load',filename);
        case '.prop'
            props('load',filename);
        case '.c3d'
            marker('load c3d',filename);
        case '.z3d'
            marker('load z3d',filename);

    end
end


function [ac,d,o] = separatefiles(f)
ac = [];
o = [];
d = [];
for i = 1:length(f)
    switch extension(f{i})
        case '.body'
            ac = [ac;f(i)];
        case '.c3d'
            d = [d;f(i)];
        otherwise
            o = [o;f(i)];
    end
end




function move(d,varargin)
val = get(finddobj('units','displacement'),'userdata');
if nargin == 2
    val = -val;
end
[tp,hnd] = currentobject;
switch tp
    case 'props'
        switch currentunits
            case 'displacement'
                switch d
                    case 'x'
                        vec = [val 0 0];
                    case 'y'
                        vec = [0 val 0];
                    case 'z'
                        vec = [0 0 val];
                end
                props('displace',vec)
            case 'rotation'
                val = get(finddobj('units','rotation'),'userdata');
                if nargin == 2
                    val = -val;
                end               
                props('rotate',hnd,val,d);
        end

    case 'marker'
        switch d
            case 'x'
                vec = [val 0 0];
            case 'y'
                vec = [0 val 0];
            case 'z'
                vec = [0 0 val];
        end
        vr = get(hnd,'vertices');
        vr = displace(vr,vec);
        set(hnd,'vertices',vr);
    case 'prop marker'
                switch d
                    case 'x'
                        vec = [val 0 0];
                    case 'y'
                        vec = [0 val 0];
                    case 'z'
                        vec = [0 0 val];
                end
                target = get(hnd,'userdata');
                tg = get(hnd,'tag');
                ud = get(target,'userdata');
                indx = find(strcmp(tg,ud.mname));
                gunit = [1 0 0;0 1 0;0 0 1];
                %vec = ctransform(gunit,ud.currentorientation,vec);
                ud.mvertices(indx,:) = ud.mvertices(indx,:)+vec;
                set(target,'userdata',ud);
                props('goto',finddobj('frame','number'));

end


function multiopen(fld)

fl = engine('path',fld,'extension','c3d');

for i = 1:length(fl)
    marker('load c3d',fl{i});
    puck = findobj(finddobj('axes'),'tag','puck');
    pud = get(puck,'userdata');
    mxfrm = length(pud.dis(:,1));
    for j = 1:mxfrm
        mark('goto',j);
        pause(.0001);
    end
end

function distributedata(fl,type)
t = load(fl,'-mat');

switch type
    case 'zoo'
        data = t.data;
        fld = setdiff(fieldnames(data),'zoosystem');
        cos = finddobj('costume');
        hd = findpart('all','head');
        for i = 1:length(fld)
            hnd = findobj(cos,'tag',fld{i});
            if ~isempty(hnd)
                hud = get(hnd,'userdata');
                if isfield(hud,'ydata')
                    hud.ydata = data.(fld{i}).line;
                    set(hnd,'userdata',hud);
                end
            end
            insertcdata(hd,fld{i},data.(fld{i}).line);            
         end
end

function insertcdata(hd,fld,yd)

for i = 1:length(hd)
    hud = get(hd(i),'userdata');
    if isfield(hud,'cdata');
        if isfield(hud.cdata,fld);
            hud.cdata.(fld).cdata = yd/max(yd);
        end
    end
    set(hd(i),'userdata',hud);
end
                


               
        
