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
% - vector analysis has been added to view LCS rotations and graphs
% - other menu bar updates
%
% updated by Phil Dixon May 2011
% - added new menu items for control of background color and axis gridlines
% - modified vector analysis representation
%
% Updated by Phil Dixon Oct 2011
% - added delete current object to director menu
% - functionality with mac attempted. Further work is needed
%
% Updated by Phil Dixon Feb 2012
% - can plot events on side graph see function marker lines 139 - 175
%
% Updated by Phil Dixon Jan 2013
% - finally (after 4 years) can be run on MAC OSX platform. (edited 'partitionfile.m')

global producer;
global p;
global f;

data = [];

if nargin ==0
    action = 'space';
end

s = slash;

switch action

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

        if isempty(tp)
            tp = ' ';
        end

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


    case 'clear all objects'
        ax = finddobj('axes');
        delete(findobj(ax,'type','patch'));
        delete(findobj(ax,'type','surface'));

    case 'clear current object'
        delete(gco)
        
    case 'load bones'
        s = slash;
        d=which('director'); % returns path to ensembler
        path = pathname(d) ;  % local folder where director resides
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openall(bones);
        director('first position');
        disp('bones loaded')

    case 'open'
        [f,p] = uigetfile('*.*','open file');
        if f == 0
            return
        end
        cd(p);
        shortp = p(round(length(p)/2):end);
        disp(['file loaded: ... ',shortp,f])
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
        p = [pwd,s];
        marker('load zoo',[p,f])
        
    case 'display PiG lower-limbs'
        p = [pwd,s];
        marker('pig lower',[p,f])
                     
    case 'display PiG all'
        p = [pwd,s];
        marker('pig all',[p,f])
        
    case 'ofm'
         p = [pwd,s];
        marker('ofm',[p,f])
        
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

    case 'save figure'
        disp('feature not yet available, please use print screen')

    case 'space'
        
        
        if ~isempty(finddobj('figure'))
            figure(finddobj('figure'))
            return
        end
        fig = figure('tag','space','color',[0 0 0 ],'name','director',...
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

        s = slash;
        d=which('director'); % returns path to ensembler
        path = pathname(d) ;  % local folder where director resides
%         bones = [path,'Cinema objects',s,'bones',s,'golembones'];
%         openall(bones);
        director('first position');
%         disp('bones loaded')
        
    case 'units'
        [unt,all] = finddobj('units');
        set(all,'value',0,'backgroundcolor',[.8 .8 .8]);
        set(gcbo,'value',1,'backgroundcolor',[.9 .9 .9]);
        figure(gcf);


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


    case 'Background Color'

        if ~isempty(finddobj('colorpallete'));
            color = get(finddobj('colorpallete'),'backgroundcolor');
            set(gca,'color',color)
        else
            %             clr = colorpallete(get(gcbo,'backgroundcolor'));
            %             set(finddobj('colorpallete'),'backgroundcolor',clr);
            disp('please select color option before trying to change color')
        end

    case 'set background black'
        set(gca,'color',[0 0 0])

    case 'set background gray'
        set(gca,'color',[.1 .1 .1])

    case 'set background white'
        set(gca,'color',[1 1 1 ])

    case 'clear axes grid'
        h = findobj('Tag','camera grid');
        set(h,'Visible','off')
        
     case 'restore axis grid'
        h = findobj('Tag','camera grid');
        set(h,'Visible','on')
        
        
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
        
    case 'gait cycle'
        
        %---load bones
        s = slash;
        d=which('director'); % returns path to ensembler
        path = pathname(d) ;  % local folder where director resides
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openall(bones);
        director('first position');
        disp('bones loaded')
        
         %--load trial----
        pth = [path,'Cinema objects',s,'sample zoo files',s];
        file = 'childgait.zoo';
        
        %--keep only gait cycle----
        data = zload([pth,file]);
        
        if ~isfield(data.zoosystem.CompInfo,'Director')
            data = partitiondata(data,'FSminus1','FSplus1');
            data.zoosystem.CompInfo.Director = 'gait cycle';
            save([pth,file],'data');
        end

        %---change background color-----
        set(gca,'color',[.3 .3 .3])

        
        %---load trial for director----
       
        distributedata([pth,file],'zoo');
        marker('load zoo',[pth,file]);
        
        %---play trial in director---
         director('preview')
        
   
        %---stop trial----
        director('preview cut') % does not work

    case 'static trial'
        
         %---load bones
        s = slash;
        d=which('director'); % returns path to ensembler
        path = pathname(d) ;  % local folder where director resides
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openall(bones);
        director('first position');
        disp('bones loaded')
        
         %--load trial----
        pth = [path,'Cinema objects',s,'sample zoo files',s];
        file = 'HC013A04.zoo';

               
        distributedata([pth,file],'zoo');
        marker('load zoo',[pth,file]);
        
          %---change background color-----
        set(gca,'color',[.3 .3 .3])
        
          %---play trial in director---
        director('first position');
        
        %--add anatomical plane props
        props('create anatomical planes')
        
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



        % ------VECTOR ANALYSIS CASES------------

        s = slash;
        
        
    case 'LegFloorAngle'
        
         frm = finddobj('frame','number');        %--load data---
         p = [pwd,s];
         data = zload([p,f]);
         
        COP = data.TurnCOP.line;  
        COP = clean(COP);
         tg = 'COP';
         
         createmarker(tg,1.5,COP,'m');
         
         HJC = data.TurnHJC.line;   
         HJC = clean(HJC);
         tg = 'HJC';
         
         createmarker(tg,1.5,HJC,'m');
         
         vect = HJC-COP;
         
         [x1,y1,z1] = arrow(COP(frm,:),vect(frm,:),3);
         surface('xdata',x1,'ydata',y1,'zdata',z1,'facecolor','m','edgecolor','none','buttondownfcn','director(''orientation buttondown'')',...
             'facelighting','flat','tag',' ','UserData',frm);
         
         
     case 'COM'
         
         frm = finddobj('frame','number');        %--load data---
         p = [pwd,s];
         data = zload([p,f]);
         
         
         %---load right tibia'----
         xyz = data.CentreOfMass.line;   % we use AJC as Tibia origin
         dis = clean(xyz);
         tg = 'COM';
         
         
         createmarker(tg,1.5,dis,'m');
         
     

     case 'Pelvis'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);

        xyz = data.PELO.line;            %---load Pelvis'----
        dis = clean(xyz);
        tg = 'PELO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x,y,z,frm)

        
    case 'Right Hip'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);

        xyz = data.PELO.line;            %---load Pelvis'----
        dis = clean(xyz);
        tg = 'PELO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x,y,z,frm)


        xyz = data.RFEO.line;            %---load right femur'----
        dis = clean(xyz);
        tg = 'RFE0';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)



    case 'Right Knee'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);

        xyz = data.RFEO.line;            %---load right femur'----
        dis = clean(xyz);
        tg = 'RFE0';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)

        xyz = data.RTIO.line;            %---load right tibia'----
        dis = clean(xyz);
        tg = 'RTI0';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)
        

    case 'Right Ankle'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);

        xyz = data.RTIO.line;            %---load right tibia'----
        dis = clean(xyz);
        tg = 'RTIO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)


        xyz = data.RFOO.line;            %---load right ankle'----
        dis = clean(xyz);
        tg = 'RFOO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/2,y/2,z/2,frm)


    case 'Left Hip'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);


        xyz = data.PELO.line;            %---load Pelvis'----
        dis = clean(xyz);
        tg = 'PELO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x,y,z,frm)


        xyz = data.LFEO.line;            %---load Left femur'----
        dis = clean(xyz);
        tg = 'LFEO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)



    case 'Left Knee'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);


        xyz = data.LFEO.line;            %---load Left femur'----
        dis = clean(xyz);
        tg = 'LFEO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)

        xyz = data.LTIO.line;            %---load Left tibia'----
        dis = clean(xyz);
        tg = 'LTIO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)

    case 'Left Ankle'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);

        xyz = data.LTIO.line;            %---load Left tibia'----
        dis = clean(xyz);
        tg = 'LTIO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/4,y/4,z/4,frm)

        xyz = data.LFOO.line;            %---load Left ankle'----
        dis = clean(xyz);
        tg = 'LFOO';
        root = tg(1:3);
        createmarker(tg,1.5,dis,'m');

        [o,x,y,z]= makeortpg(data,root);
        makearrowsurf(o,x/2,y/2,z/2,frm)


    case 'Right Hindfoot/Tibia'
        
        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];
        data = zload([p,f]);

        
        
        %---load right tibia'----
        xyz = data.RAJC.line;   % we use AJC as Tibia origin
        dis = clean(xyz);
        tg = 'RTIB0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,x,y,z]= makeort(data,root);
        makearrowsurf(o,x,y,z/4,frm,root)
        
        xyz = data.RHDF0.line;        %---load right hindfoot'----
        dis = clean(xyz);
        tg = 'RHDF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)  % flip axes around



    case 'Right Forefoot/Hindfoot'
        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];

        t = extension(f);

        switch t

            case '.zoo'
                data = load([p,f],'-mat');
                data = data.data;

            case '.c3d'
                disp('c3d format not yet supported for vector analysis, please convert file to zoo using c3d2zoo')
                return
        end

        xyz = data.RFOF0.line;        %---load right forefoot'----
        dis = clean(xyz);
        tg = 'RFOF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');

        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)

        xyz = data.RHDF0.line;
        dis = clean(xyz);
        tg = 'RHDF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');

        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)

    case 'Right Hallux/Forefoot'

        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];

        t = extension(f);

        switch t

            case '.zoo'
                data = load([p,f],'-mat');
                data = data.data;

            case '.c3d'
                disp('c3d format not yet supported for vector analysis, please convert file to zoo using c3d2zoo')
                return
        end

        xyz = data.RHLX0.line;        %---load right hallux'----
        dis = clean(xyz);
        tg = 'RHLX0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);

        [x1,y1,z1] = arrow(o(frm,:),x(frm,:),20);
        surface('xdata',x1,'ydata',y1,'zdata',z1,'facecolor','r','edgecolor','none','buttondownfcn','director(''orientation buttondown'')',...
            'facelighting','flat','tag','RHLXx','UserData',frm);
        
        xyz = data.RFOF0.line;            %---load right forefoot'----
        dis = clean(xyz);
        tg = 'RFOF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)


    case 'Left Hindfoot/Tibia'
        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];

        t = extension(f);

        switch t

            case '.zoo'
                data = load([p,f],'-mat');
                data = data.data;

            case '.c3d'
                disp('c3d format not yet supported for vector analysis, please convert file to zoo using c3d2zoo')
                return
        end
        xyz = data.LAJC.line;         %---load left tibia'----
        dis = clean(xyz);
        tg = 'LTIB0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,x,y,z]= makeort(data,root);
        makearrowsurf(o,x,y,z/4,frm,root)

        xyz = data.LHDF0.line;        %---load left hindfoot'----
        dis = clean(xyz);
        tg = 'LHDF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z/4,frm,root)

        
    case 'Left Forefoot/Hindfoot'
        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];

        t = extension(f);

        switch t

            case '.zoo'
                data = load([p,f],'-mat');
                data = data.data;

            case '.c3d'
                disp('c3d format not yet supported for vector analysis, please convert file to zoo using c3d2zoo')
                return
        end

        xyz = data.LFOF0.line;         %---load left forefoot'----
        dis = clean(xyz);
        tg = 'LFOF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)

        xyz = data.LHDF0.line;          %---load left hindfoot'----
        dis = clean(xyz);
        tg = 'LHDF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)

    case 'Left Hallux/Forefoot'
        frm = finddobj('frame','number');        %--load data---
        p = [pwd,s];

        t = extension(f);

        switch t

            case '.zoo'
                data = load([p,f],'-mat');
                data = data.data;

            case '.c3d'
                disp('c3d format not yet supported for vector analysis, please convert file to zoo using c3d2zoo')
                return
        end

        xyz = data.LHLX0.line;           %---load left hallux----
        dis = clean(xyz);
        tg = 'LHLX0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);

        [x1,y1,z1] = arrow(o(frm,:),x(frm,:),20);
        surface('xdata',x1,'ydata',y1,'zdata',z1,'facecolor','r','edgecolor','none','buttondownfcn','director(''orientation buttondown'')',...
            'facelighting','flat','tag','LHLXx','UserData',frm);

        xyz = data.LFOF0.line;        %---load left forefoot'----
        dis = clean(xyz);
        tg = 'LFOF0';
        root = tg(1:4);
        createmarker(tg,1.5,dis,'m');
        [o,z,y,x]= makeort(data,root);
        makearrowsurf(o,x,y,z,frm,root)

    case 'Keep Current Frame'
        cframe = finddobj('frame','number');

        RTIBxhnd = findobj('tag','RTIBx');
        RTIByhnd = findobj('tag','RTIBy');
        RTIBzhnd = findobj('tag','RTIBz');

        RHDFxhnd = findobj('tag','RHDFx');
        RHDFyhnd = findobj('tag','RHDFy');
        RHDFzhnd = findobj('tag','RHDFz');

        RFOFxhnd = findobj('tag','RFOFx');
        RFOFyhnd = findobj('tag','RFOFy');
        RFOFzhnd = findobj('tag','RFOFz');

        RHLXxhnd = findobj('tag','RHLXx');
        RHLXyhnd = findobj('tag','RHLXy');
        RHLXzhnd = findobj('tag','RHLXz');

        LTIBxhnd = findobj('tag','LTIBx');
        LTIByhnd = findobj('tag','LTIBy');
        LTIBzhnd = findobj('tag','LTIBz');

        LHDFxhnd = findobj('tag','LHDFx');
        LHDFyhnd = findobj('tag','LHDFy');
        LHDFzhnd = findobj('tag','LHDFz');

        LFOFxhnd = findobj('tag','LFOFx');
        LFOFyhnd = findobj('tag','LFOFy');
        LFOFzhnd = findobj('tag','LFOFz');

        LHLXxhnd = findobj('tag','LHLXx');
        LHLXyhnd = findobj('tag','LHLXy');
        LHLXzhnd = findobj('tag','LHLXz');

        for i = 1:length(RTIBxhnd)
            if ~isempty(RTIBxhnd) && get(RTIBxhnd(i),'UserData')~=cframe
                delete(RTIBxhnd(i))
            end

            if ~isempty(RTIByhnd) && get(RTIByhnd(i),'UserData')~=cframe
                delete(RTIByhnd(i))
            end

            if ~isempty(RTIBzhnd) && get(RTIBzhnd(i),'UserData')~=cframe
                delete(RTIBzhnd(i))
            end

        end

        for i = 1:length(RHDFxhnd)
            if ~isempty(RHDFxhnd) && get(RHDFxhnd(i),'UserData')~=cframe
                delete(RHDFxhnd(i))
            end

            if ~isempty(RHDFyhnd) && get(RHDFyhnd(i),'UserData')~=cframe
                delete(RHDFyhnd(i))
            end

            if ~isempty(RHDFzhnd) && get(RHDFzhnd(i),'UserData')~=cframe
                delete(RHDFzhnd(i))
            end

        end

        for i = 1:length(RFOFxhnd)
            if ~isempty(RFOFxhnd) && get(RFOFxhnd(i),'UserData')~=cframe
                delete(RFOFxhnd(i))
            end

            if ~isempty(RFOFyhnd) && get(RFOFyhnd(i),'UserData')~=cframe
                delete(RFOFyhnd(i))
            end

            if ~isempty(RFOFzhnd) && get(RFOFzhnd(i),'UserData')~=cframe
                delete(RFOFzhnd(i))
            end
        end

        for i = 1:length(RHLXxhnd)
            if ~isempty(RHLXxhnd) && get(RHLXxhnd(i),'UserData')~=cframe
                delete(RHLXxhnd(i))
            end

            if ~isempty(RHLXyhnd) && get(RHLXyhnd(i),'UserData')~=cframe
                delete(RHLXyhnd(i))
            end

            if ~isempty(RHLXzhnd) && get(RHLXzhnd(i),'UserData')~=cframe
                delete(RHLXzhnd(i))
            end
        end

        for i = 1:length(LTIBxhnd)
            if ~isempty(LTIBxhnd) && get(LTIBxhnd(i),'UserData')~=cframe
                delete(LTIBxhnd(i))
            end

            if ~isempty(LTIByhnd) && get(LTIByhnd(i),'UserData')~=cframe
                delete(LTIByhnd(i))
            end

            if ~isempty(LTIBzhnd) && get(LTIBzhnd(i),'UserData')~=cframe
                delete(LTIBzhnd(i))
            end

        end

        for i = 1:length(LHDFxhnd)
            if ~isempty(LHDFxhnd) && get(LHDFxhnd(i),'UserData')~=cframe
                delete(LHDFxhnd(i))
            end

            if ~isempty(LHDFyhnd) && get(LHDFyhnd(i),'UserData')~=cframe
                delete(LHDFyhnd(i))
            end

            if ~isempty(LHDFzhnd) && get(LHDFzhnd(i),'UserData')~=cframe
                delete(LHDFzhnd(i))
            end
        end

        for i = 1:length(LFOFxhnd)
            if ~isempty(LFOFxhnd) && get(LFOFxhnd(i),'UserData')~=cframe
                delete(LFOFxhnd(i))
            end

            if ~isempty(LFOFyhnd) && get(LFOFyhnd(i),'UserData')~=cframe
                delete(LFOFyhnd(i))
            end

            if ~isempty(LFOFzhnd) && get(LFOFzhnd(i),'UserData')~=cframe
                delete(LFOFzhnd(i))
            end
        end

        for i = 1:length(LHLXxhnd)
            if ~isempty(LHLXxhnd) && get(LHLXxhnd(i),'UserData')~=cframe
                delete(LHLXxhnd(i))
            end

            if ~isempty(LHLXyhnd) && get(LHLXyhnd(i),'UserData')~=cframe
                delete(LHLXyhnd(i))
            end

            if ~isempty(LHLXzhnd) && get(LHLXzhnd(i),'UserData')~=cframe
                delete(LHLXzhnd(i))
            end
        end


    case 'Show Graph'

        %--load data---
        frm = finddobj('frame','number');
        p = [pwd,s];
        data = load([p,f],'-mat');
        data = data.data;

        RTIBxhnd = findobj('tag','RTIBx');
        RHDFxhnd = findobj('tag','RHDFx');
        RFOFxhnd = findobj('tag','RFOFx');
        RHLXxhnd = findobj('tag','RHLXx');

        LTIBxhnd = findobj('tag','LTIBx');
        LHDFxhnd = findobj('tag','LHDFx');
        LFOFxhnd = findobj('tag','LFOFx');
        LHLXxhnd = findobj('tag','LHLXx');

        if ~isempty(RTIBxhnd) && ~ isempty(RHDFxhnd)
            chv = 'RHFTBA';
            chg = 'Rhftba';
            yd1 = data.(chv).line;

            if isfield(data,[chg,'_x'])
                yd2 = [data.([chg,'_x']).line  data.([chg,'_y']).line data.([chg,'_z']).line] ;
            else
                yd2 = yd1;
            end

        end

        if ~isempty(RHDFxhnd) && ~ isempty(RFOFxhnd)
            chv = 'RFFHFA';
            chg = 'Rffhfa';
            yd1 = data.(chv).line;

            if isfield(data,[chg,'_x'])
                yd2 = [data.([chg,'_x']).line  data.([chg,'_y']).line data.([chg,'_z']).line] ;
            else
                yd2 = yd1;
            end

        end

        if ~isempty(RFOFxhnd) && ~ isempty(RHLXxhnd)

            chv = 'RHXFFA';
            chg = 'Rhxffa';
            yd1 = data.(chv).line(:,1);

            if isfield(data,[chg,'_x'])
                yd2 = data.([chg,'_x']).line;
            else
                yd2 = yd1;
            end

        end


        if ~isempty(LTIBxhnd) && ~ isempty(LHDFxhnd)

            chv = 'LHFTBA';
            chg = 'Lhftba';
            yd1 = data.(chv).line;

            if isfield(data,[chg,'_x'])
                yd2 = [data.([chg,'_x']).line  data.([chg,'_y']).line data.([chg,'_z']).line] ;
            else
                yd2 = yd1;
            end

        end



        if ~isempty(LHDFxhnd) && ~ isempty(LFOFxhnd)

            chv = 'LFFHFA';
            chg = 'Lffhfa';
            yd1 = data.(chv).line;

            if isfield(data,[chg,'_x'])
                yd2 = [data.([chg,'_x']).line  data.([chg,'_y']).line data.([chg,'_z']).line] ;
            else
                yd2 = yd1;
            end

        end



        if ~isempty(LFOFxhnd) && ~ isempty(LHLXxhnd)

            chv = 'LHXFFA';
            chg = 'Lhxffa';
            yd1 = data.(chv).line(:,1);

            if isfield(data,[chg,'_x'])
                yd2 = data.([chg,'_x']).line;
            else
                yd2 = yd1;
            end

        end


        if ~isempty(LHLXxhnd)

            g1 = grips('data graph',yd1,[chv,'x (Vicon : solid  G&S : dashed)'],'r');
            line('Parent',g1,'YData',yd2,'XData',1:1:length(yd2),'color','r','LineStyle',':')

        elseif ~isempty(RHLXxhnd)

            g1 = grips('data graph',yd1,[chv,'x (Vicon : solid  G&S : dashed)'],'r');
            line('Parent',g1,'YData',yd2,'XData',1:1:length(yd2),'color','r','LineStyle',':')

        else

            g1 = grips('data graph',yd1(:,1),[chv,'x (Vicon : solid  G&S : dashed)'],'r');
            line('Parent',g1,'YData',yd2(:,1),'XData',1:1:length(yd2),'color','r','LineStyle',':')

            g2 = grips('data graph',yd1(:,2),[chv,'y (Vicon : solid  G&S : dashed)'],'g');
            line('Parent',g2,'YData',yd2(:,2),'XData',1:1:length(yd2),'color','g','LineStyle',':')

            g3 = grips('data graph',yd1(:,3),[chv,'z (Vicon : solid  G&S : dashed)'],'b');
            line('Parent',g3,'YData',yd2(:,3),'XData',1:1:length(yd2),'color','b','LineStyle',':')

        end




    case 'Clear All'

        hnd = findobj('FaceLighting','flat');
        for i = 1:length(hnd)
            delete(hnd(i))
        end

        mhnd = findobj('type','patch');

        for j = 1:length(mhnd)
            if  ~isempty(strfind(get(mhnd(j),'ButtonDownFcn'),'marker'))
                delete(mhnd(j))
            end
        end

        ghnd = findobj('type','axes');

        for k = 1:length(ghnd)
            if  ~isempty(strfind(get(ghnd(k),'CreateFcn'),'graph createfcn'))
                delete(ghnd(k))
            end
        end
        disp('Vector analysis cleared')
        
        
        
        
        
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
vectors('goto')
lightman('refresh');

pause(.01);

function vectors(command)

switch command

    case 'goto'

        if ~isempty(findobj('tag','RHDF0')) && ~isempty(findobj('tag','RTIB0'))
            director('Right Hindfoot/Tibia')
        end

        if ~isempty(findobj('tag','RFOF0')) && ~isempty(findobj('tag','RHDF0'))
            director('Right Forefoot/Hindfoot')
        end

        if ~isempty(findobj('tag','RHLX0')) && ~isempty(findobj('tag','RFOF0'))
            director('Right Hallux/Forefoot')
        end

        if ~isempty(findobj('tag','LHDF0')) && ~isempty(findobj('tag','LTIB0'))
            director('Left Hindfoot/Tibia')
        end

        if ~isempty(findobj('tag','LFOF0')) && ~isempty(findobj('tag','LHDF0'))
            director('Left Forefoot/Hindfoot')
        end

        if ~isempty(findobj('tag','LHLX0')) && ~isempty(findobj('tag','LFOF0'))
            director('Left Hallux/Forefoot')
        end

end


% =========EMBEDDED FUNCTIONS============


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
        uimenu(mn,'label','load bones','callback','director(''load bones'')');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','quick open','callback','director(''quick open'')');
        uimenu(mn,'label','reload markers','callback','director(''reload markers'')','separator','on');
        uimenu(mn,'label','display PiG all','callback','director(''display PiG all'')');
        uimenu(mn,'label','display PiG lower-limbs','callback','director(''display PiG lower-limbs'')');
        uimenu(mn,'label','display OFM markers','callback','director(''ofm'')');
        uimenu(mn,'label','save','callback','director(''save'')');
        uimenu(mn,'label','system colors','callback','director(''colorpallete'')', 'separator','on');
        uimenu(mn,'label','set background color','callback','director(''Background Color'')');
        uimenu(mn,'label','quick set background black','callback','director(''set background black'')');
        uimenu(mn,'label','quick set background gray','callback','director(''set background gray'')');
        uimenu(mn,'label','quick set background white','callback','director(''set background white'')');
        uimenu(mn,'label','clear axes grid','callback','director(''clear axes grid'')','separator','on');
        uimenu(mn,'label','restore axis grid','callback','director(''restore axis grid'')');
        
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
        uimenu(mn,'label','delete current object','callback','director(''clear current object'')');

        
        mn1 = uimenu(fig,'label','play');
        uimenu(mn1,'label','practice','callback','director(''preview'')','accelerator','p');
        uimenu(mn1,'label','first position','callback','director(''first position'')','accelerator','1');
        uimenu(mn1,'label','go to','callback','director(''goto callback'')');
        uimenu(mn1,'label','sample gait cycle','callback','director(''gait cycle'')');
        uimenu(mn1,'label','sample static trial','callback','director(''static trial'')');


      

        mn = uimenu(fig,'label','Vector analysis');
        uimenu(mn,'label','Pelvis','callback','director(''Pelvis'')');
        uimenu(mn,'label','COM','callback','director(''COM'')');
        uimenu(mn,'label','Right Hip','callback','director(''Right Hip'')');
        uimenu(mn,'label','Right Knee','callback','director(''Right Knee'')');
        uimenu(mn,'label','Right Ankle','callback','director(''Right Ankle'')');
        uimenu(mn,'label','Left Hip','callback','director(''Left Hip'')');
        uimenu(mn,'label','Left Knee','callback','director(''Left Knee'')');
        uimenu(mn,'label','Left Ankle','callback','director(''Left Ankle'')');

        uimenu(mn,'label','Right Hindfoot/Tibia','callback','director(''Right Hindfoot/Tibia'')','separator','on');
        uimenu(mn,'label','Right Forefoot/Hindfoot','callback','director(''Right Forefoot/Hindfoot'')');
        uimenu(mn,'label','Right Hallux/Forefoot','callback','director(''Right Hallux/Forefoot'')');
        uimenu(mn,'label','Left Hindfoot/Tibia','callback','director(''Left Hindfoot/Tibia'')');
        uimenu(mn,'label','Left Forefoot/Hindfoot','callback','director(''Left Forefoot/Hindfoot'')');
        uimenu(mn,'label','Left Hallux/Forefoot','callback','director(''Left Hallux/Forefoot'')');

        uimenu(mn,'label','Keep Current Frame','callback','director(''Keep Current Frame'')','separator','on');
        uimenu(mn,'label','Show Graph','callback','director(''Show Graph'')');
        uimenu(mn,'label','Clear All','callback','director(''Clear All'')');
        uimenu(mn,'label','LegFloorAngle','callback','director(''LegFloorAngle'')','separator','on');

        
        
        mn = uimenu(fig,'label','Arrow Color Codes');
        uimenu(mn,'label','x-axis: Red');
        uimenu(mn,'label','y-axis: Green');
        uimenu(mn,'label','z-axis: Blue');
        
        set(gcf,'name','director V2.0: The Future of Biomechanical Visualization'); % Just having fun

end
director('cleanup');
% set(gcf,'name',action);


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

s = slash;

if ~strcmp(pth(end),s);
    pth = [pth,s];
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


function openfromworkspace(data)


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



function [o,z,y,x]= makeort(data,root)

if ~isfield(data,[root,'0'])

      
    if isin(root,'LPR')
    
        bone0 = clean(data.LPROXFF.line);
        root = 'LFOF';
        
    elseif isin(root,'R')
        bone0 = clean(data.RAJC.line);
         
    else
        bone0 = clean(data.LAJC.line);
    end
else
    bone0 = clean(data.([root,'0']).line);
end

bone1 = clean(data.([root,'1']).line);
bone2 = clean(data.([root,'2']).line);
bone3 = clean(data.([root,'3']).line);

o = bone0;
z = bone1-o;
y = bone2-o;
x = bone3-o;



function [o,x,y,z]= makeortpg(data,root)

boneO = clean(data.([root,'O']).line);
boneA = clean(data.([root,'A']).line);
boneL = clean(data.([root,'L']).line);
boneP = clean(data.([root,'P']).line);

o = boneO;
x = boneA-o;
y = boneL-o;
z = boneP-o;


function makearrowsurf(o,x,y,z,frm,tag)

if nargin ==5
    tag = '';
end

[x1,y1,z1] = arrow(o(frm,:),x(frm,:),20);
surface('xdata',x1,'ydata',y1,'zdata',z1,'facecolor','r','edgecolor','none','buttondownfcn','director(''orientation buttondown'')',...
    'facelighting','flat','tag',[tag,'x'],'UserData',frm);
[x2,y2,z2] = arrow(o(frm,:),y(frm,:),20);
surface('xdata',x2,'ydata',y2,'zdata',z2,'facecolor','g','edgecolor','none','buttondownfcn','director(''orientation buttondown'')',...
    'facelighting','flat','tag',[tag,'y'],'UserData',frm);
[x3,y3,z3] = arrow(o(frm,:),z(frm,:),20);
surface('xdata',x3,'ydata',y3,'zdata',z3,'facecolor','b','edgecolor','none','buttondownfcn','director(''orientation buttondown'')',...
    'facelighting','flat','tag',[tag,'z'],'UserData',frm);



function r = clean(xyz)
r = xyz/10;
indx = find(xyz==0);
a = zeros(size(xyz));
a(indx) = 1;
indx = find(sum(a')==3);
r(indx,:) = NaN;


