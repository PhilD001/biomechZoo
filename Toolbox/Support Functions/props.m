function varargout = props(action,varargin)

% varargout = PROPS(action,varargin) creates various props used by director
%
% Updated by JJ Loh and Philippe C. Dixon June 2015
% - new case added to load the skate props
%
% Updated by Philippe C. Dixon November 2015
% - props relies on exisitng functions to prepare COP data 
% - all available bones will plot
% - force plate props will be resized based on corners data
%   (data.zoosystem.Analog.FPlates.CORNERS), if available

% Updated by Philippe C. Dixon December 2016
% - Added toe 'bones' to zooplugingait subfunction
%
% Updated by Philippe C. Dixon April 2017
% - improved searching of prop files using ensembler
%
% Updated by Philippe C. Dixon July 2017
% - added ability to deal with Kistler force plates. There are still
%   some issues with correctly orienting the cop for some force plate
%   orientations
% - added creation of PiG bones-if available 


switch action
    
    case 'goto'
        mark(varargin{1}); % advaces all props to new position
        
    case 'create net'
        xd = (-2.5:.5:2.5);
        yd = sqrt(2.5^2-xd.*xd);
        xd = [xd,fliplr(xd)];
        yd = [yd,-yd];
        zd = zeros(size(yd));
        r = 4*35/(2*pi);
        
        vplate = [xd',yd',zd'];
        nvplate = displace(vplate,[0 r-2.5 0]);
        bvplate = vecrotate(vecrotate(displace(vplate,[0 100 0]),90,'y'),30,'z');
        tvplate = vecrotate(displace(vplate,[0 15 0]),90,'y');
        plength = length(xd);
        h = 127.7183-3.5-19.5;
        fplate = [(1:plength-1)',(2:plength)',(plength+2:2*plength)',(plength+1:2*plength-1)'];
        vr = [nvplate;displace(nvplate,[0 0 h]);...
            displace(vecrotate(nvplate,10,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,20,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,30,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,40,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,50,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,60,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,70,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,80,'x'),[0 0 h]);...
            displace(vecrotate(nvplate,90,'x'),[0 r-97 h])];
        
        fc = [fplate;...
            fplate+plength;...
            fplate+2*plength;...
            fplate+3*plength;...
            fplate+4*plength;...
            fplate+5*plength;...
            fplate+6*plength;...
            fplate+7*plength;...
            fplate+8*plength;...
            fplate+9*plength;];
        
        % adding the base
        vr = displace(vr,[0 -max(vr(:,2))+97 0]);
        ds = mean(vr(1:plength,:))-mean(bvplate);
        ds(3) = ds(3)+2.5;
        
        vr = flipud(vr);
        
        
        vr = [vr;displace(bvplate,ds);...
            displace(vecrotate(bvplate,10,'z'),ds);...
            displace(vecrotate(bvplate,20,'z'),ds);...
            displace(vecrotate(bvplate,30,'z'),ds);...
            displace(vecrotate(bvplate,40,'z'),ds);...
            displace(vecrotate(bvplate,50,'z'),ds);...
            displace(vecrotate(bvplate,60,'z'),[ds(1),0,ds(3)])];
        
        fc = [fc;...
            fplate+plength*10;...
            fplate+plength*11;...
            fplate+plength*12;...
            fplate+plength*13;...
            fplate+plength*14;...
            fplate+plength*15;...
            fplate+plength*16];
        
        ds = mean(vr(1:plength,:))-mean(tvplate)+[0 75 0];
        
        vr = [vr;displace(tvplate,ds);...
            displace(tvplate,ds+[-15 0 0]);...
            displace(vecrotate(tvplate,30,'z'),ds+[-15 0 0]);...
            displace(vecrotate(tvplate,60,'z'),ds+[-15 0 0]);...
            displace(vecrotate(tvplate,90,'z'),ds+[-15 0 0]);...
            displace(vecrotate(tvplate,90,'z'),[ds(1)-15 0 ds(3)])];
        
        fc = [fc;...
            fplate+plength*18;...
            fplate+plength*19;...
            fplate+plength*20;...
            fplate+plength*21;...
            fplate+plength*22];
        
        nvr = vr;
        nvr(:,2) = -nvr(:,2);
        fc = [fc;length(vr(:,1))+fc];
        vr = [vr;nvr];
        
        vr = vecrotate(vr,180,'z');
        vr = displace(vr,[428 -min(vr(:,2))-2.5-43,0]);
        
        if nargout==2
            varargout{1} = vr;
            varargout{2} = fc;
        else
            patch('parent',finddobj('axes'),'faces',fc,'vertices',vr,'facecolor',[1 0 0],'edgecolor','none','facelighting','gouraud','clipping','off','tag','net');
        end
        
    case 'make3d'
        [tp,hnd] = currentobject;
        vr = get(hnd,'vertices');
        fc = get(hnd,'faces');
        cdata = get(hnd,'cdata');
        nvr = displace(vr,[-2 0 0]);
        lvr = length(vr(:,1));
        nfc = fc+lvr;
        set(hnd,'vertices',[vr;nvr],'faces',[fc;nfc],'cdata',[cdata;cdata]);
        
    case 'makeprop'
        hnd = varargin{1};
        ud.vertices = get(hnd,'vertices');
        ud.faces = get(hnd,'faces');
        cdata(1:length(ud.faces(:,1)),1,1:3) = .8;
        set(hnd,'facecolor','flat','edgecolor','none','buttondownfcn',...
            'props(''buttondown'')','cdata',cdata,'userdata',ud,...
            'FaceLighting','gouraud','createfcn','props(''createfcn'')','clipping','off','facevertexalphadata',1,'facealpha',.99);
        
    case 'object'
        ud.vertices = varargin{1};
        ud.faces = varargin{2};
        lfc = length(ud.faces(:,1));
        ud.cdata(1:lfc,1,1:3) = .8;
        createprop(ud,varargin{3});
        
    case 'puck trajectory'
        mrk = finddobj('marker');
        indx = listdlg('liststring',get(mrk,'tag'),'name','choose puck markers');
        
        [xyz,ort] = pucktrajectory(mrk(indx),240);
        [tp,hnd] = currentobject;
        hud = get(hnd,'userdata');
        hud.dis = xyz;
        hud.ort = ort;
        hud.puckmarkers = get(mrk(indx),'tag');
        hud.samplerate = 240;
        set(hnd,'userdata',hud);
        rezerovertices(hnd);
        
    case 'refresh'
        refreshprop;
        
    case 'create marker'
        nm = inputdlg({'marker name','size(cm)'},'marker properties',1,{'','1.5'});
        if isempty(nm)
            return
        elseif isempty(str2num(nm{2}))
            return
        end
        hnd = currentobject('handle');
        vindx = findbomb(hnd,'vindex');
        if isempty(vindx)
            return
        end
        vr = get(hnd,'vertices');
        createmarker(nm{1},str2num(nm{2}),vr(vindx(1),:));
        
    case 'associate marker'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'props')
            return
        end
        pud = get(hnd,'userdata');
        mrk = finddobj('marker');
        if length(mrk)<2
            return
        end
        r = associatedlg(pud.mname,get(mrk,'tag'));
        pud.association = r;
        
        set(hnd,'userdata',pud);
        
    case 'keypress'
        cky = get(gcf,'currentkey');
        switch cky
            case 'delete'
                delete(varargin{1});
        end
        
    case 'buttondown'
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        set(finddobj('highlight'),'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        if ~strcmp(currentperson,'props')
            cameraman('buttondown');
            return
        end
        cpos = get(gca,'cameraposition');
        ctarg = get(gca,'cameratarget');
        hd = get(gca,'currentpoint');
        pt = get(gcbo,'vertices');
        fc = get(gcbo,'faces');
        [vindx,findx] = face2line(pt,fc,hd([2,1],:),'closer');
        if isempty(vindx) || isempty(findx)
            return
        end
        findx = findx(1);
        vindx = vindx(1);
        
        if strcmp(get(gcf,'selectiontype'),'alt')
            bomb(gcbo,vindx,findx);
        else
            delete(findbomb(gcbo));
            bomb(gcbo,vindx,findx);
        end
        numfc = length(fc(:,1));
        fvad(1:numfc,1) = 1;
        fvad(findx) = 1;
        set(gcbo,'facevertexalphadata',fvad,'facecolor','flat','edgecolor',[0 0 1],'facealpha','flat');
        
        ahnd = finddobj('highlight');
        set(ahnd,'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        buttondownfxn;
        caliper(finddobj('bomb'));
        cameraman('buttondown');
        
    case 'prop marker buttondown'
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        set(finddobj('highlight'),'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        if ~strcmp(currentperson,'props')
            cameraman('buttondown');
            return
        end
        
    case 'prop marker deletefcn'
        trg = get(gcbo,'userdata');
        if ~ishandle(trg)
            return
        end
        ud = get(trg,'userdata');
        tg = get(gcbo,'tag');
        indx = find(strcmp(ud.mname,tg));
        ud.mname(indx) = [];
        ud.mvertices(indx,:) = [];
        set(trg,'userdata',ud);
        
    case 'save'
        
        [tp,hnd] = currentobject;
        vr = get(hnd,'vertices');
        fc = get(hnd,'faces');
        ud = get(hnd,'userdata');
        if isfield(ud,'association') || isfield(ud,'joint') || isfield(ud,'puckmarkers') || isfield(ud,'fx');
            object = ud;
            object.cdata = get(hnd,'cdata');
        else
            mrk= finddobj('marker');
            object.vert = vr;
            object.face = fc;
            
            object.marker = struct;
            object.cdata = get(hnd,'cdata');
            
            for i = 1:length(mrk);
                object.marker(i).tag = get(mrk(i),'tag');
                object.marker(i).position = mean(get(mrk(i),'vertices'));
            end
        end
        object.vertexnormals = get(hnd,'vertexnormals');
        [f,p] = uiputfile('*.prop');
        if f == 0;
            return
        end
        save([p,f],'object');
        
    case 'load skates'
        fl = varargin{1};
        hnd = props('load',fl);
        skate(hnd);
        
    case 'load'
        
        filename = varargin{1};
        t = load(filename,'-mat');
        if isfield(t.object,'association')|| isfield(t.object,'joint') || isfield(t.object,'vertices');
            ud = t.object;
        else
            ud.vertices = t.object.vert;
            ud.faces = t.object.face;
            if isfield(t.object,'cdata')
                ud.cdata = t.object.cdata;
            else
                ud.color = [.8 .8 .8];
            end
            if ~isempty(fieldnames(t.object.marker))
                ud.mvertices = [];
                ud.mname = [];
                for i = 1:length(t.object.marker);
                    ud.mvertices = [ud.mvertices;t.object.marker(i).position];
                    ud.mname = [ud.mname,{t.object.marker(i).tag}];
                end
            end
        end
        [f,p] = partitionfile(filename);
        f = extension(f,'');
        if nargin == 2
            varargout{1} = createprop(ud,f);
        else
            varargout{1} = createprop(ud,varargin{2});
        end
         
    case 'load with markers'
        
        [f,p] = uigetfile('*.prop');
        if f == 0
            return
        end
        filename = [p,f];
        t = load(filename,'-mat');
        ud.vertices = t.object.vert;
        ud.faces = t.object.face;
        ud.color = [.8 .8 .8];
        ud.mvertices = [];
        ud.mname = [];
        for i = 1:length(t.object.marker)
            ud.mvertices = [ud.mvertices;t.object.marker(i).position];
            ud.mname = [ud.mname,{t.object.marker(i).tag}];
            marker('create',t.object.marker(i).tag,1.5,t.object.marker(i).position,[1 0 0]);
        end
        
        [f,p] = partitionfile(filename);
        f = extension(f,'');
        
        ud.color = [.8 .8 .8];
        createprop(ud,f);
        
    case 'buttondownfxns'
        
        hnd = findobj(finddobj('figure'),'tag','bdownfxns');
        if isempty(findobj(hnd,'value',1))
            set(gcbo,'value',0);
        else
            set(hnd,'value',0);
            set(gcbo,'value',1);
            buttondownfxn;
        end
        switch get(gcbo,'string')
            case 'color'
                r = colorpallete(get(gcbo,'foregroundcolor'));
                set(gcbo,'foregroundcolor',r);
        end
        
        figure(gcf)
        
    case 'origin'
        
        if strcmp(get(gcf,'selectiontype'),'alt')
            delete(gcbo);
            return
        end
        cpos = get(gca,'cameraposition');
        ctarg = get(gca,'cameratarget');
        hd = get(gca,'currentpoint');
        tl = hd(2,:);
        hd = tl+(cpos-ctarg);
        
        pt = get(gcbo,'vertices');
        fc = get(gcbo,'faces');
        [vindx,findx] = face2line(pt,fc,[tl;hd],'closer');
        if isempty(findx)
            return
        end
        ohnd = findobj(finddobj('axes'),'tag','origin');
        oud = get(ohnd,'userdata');
        
        cdata = get(gcbo,'cdata');
        c(1,1:3) = cdata(findx(1),1,:);
        gunit = [1 0 0;0 1 0;0 0 1];
        if c == [1 0 0]
            nort = round(vecrotate(gunit,90,'x'));
        elseif c == [0 1 0]
            nort = round(vecrotate(gunit,90,'y'));
        elseif c == [0 0 1]
            nort = round(vecrotate(gunit,90,'z'));
        end
        oud.rort = ctransform(oud.rort,gunit,nort);
        
        set(ohnd,'userdata',oud);
        origin('refresh');
        
    case 'vertex position'
        
        clr = get(gcbo,'backgroundcolor');
        if strcmp(get(gcf,'selectiontype'),'open')
            val = inputdlg('enter an value');
            num = str2num(val{1});
            if isempty(num)
                return
            end
            set(gcbo,'backgroundcolor',round(clr),'userdata',num,'string',num2str(num));
            return
        end
        if max(clr) == 1
            clr = clr*.7;
        else
            clr = round(clr);
        end
        set(gcbo,'backgroundcolor',clr);
        
    case 'displace'
        
        vec = varargin{1};
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'props')
            return
        end
        displaceprop(hnd,vec);
        
    case 'rotate'
        
        hnd = varargin{1};
        deg = varargin{2};
        ax = varargin{3};
        
        ud = get(hnd,'userdata');
        vr = get(hnd,'vertices');
        
        if isfield(ud,'currentorientation')
            pre = ud.currentpredis;
            post = ud.currentpostdis;
            ort = ud.currentorientation;
            ort = vecrotate(ort,deg,ax);
            ud.currentorientation = ort;
            set(hnd,'userdata',ud,'vertices',zero2real(ud.vertices,pre,post,ort));
        end
        
    case 'load pucks'
        
        fld = uigetfolder;
        cd(fld)
        [pfl,ppth] = uigetfile('*.prop','get puck');
        
        cd(ppth)
        fl = engine('path',fld,'extension','c3d');
        r = readc3d(fl{1});
        
        lst = listchannelc3d(r);
        indx = listdlg('liststring',lst,'name','choose puck markers');
        mrk1 = lst{indx(1)};
        mrk2 = lst{indx(2)};
        global producer
        for i = 1:length(fl)
            r = readc3d(fl{i});
            m1 = clean(getchannelc3d(r,mrk1,'all'));
            m2 = clean(getchannelc3d(r,mrk2,'all'));
            [xyz,ort] = pucktrajectory(m1,m2,240);
            phnd = props('load',[ppth,pfl],['puck',num2str(i)]);
            pud = get(phnd,'userdata');
            pud.dis = xyz;
            pud.ort = ort;
            pud.filename = fl{i};
            set(phnd,'userdata',pud);
            rezerovertices(phnd);
            producer.grips.linetrace(i).target = ['puck',num2str(i)];
            producer.grips.linetrace(i).color = file2clr(fl{i});
        end
        
    case 'create'
        
        createprop(varargin{1},varargin{2})
        %create a prop varargin{1} = userdata
        %varargin{2} = tag;
        
    case 'plugin gait'
        c3d = varargin{1};
        plugingait(c3d);
        
    case 'zoo plugin gait'
        zdata = varargin{1};
        zooplugingait(zdata);
        
        %     case 'load analog c3d'   % original code
        %         c3d = varargin{1};
        %         loadanalog(c3d);
        
    case 'load analog c3d'
        zdata = varargin{1};
        zooloadanalog(zdata);
        
    case 'load analog zoo'
        zdata = varargin{1};
        zooloadanalog(zdata);

end

function bomb(hnd,vindx,findx)
bm = findbomb(hnd);
if length(bm)>=3 && strcmp(getbdownfxn,'add face')
    for i = 1:length(bm)
        bud = get(bm(i),'userdata');
        if bud.bindex==1
            delete(bm(i));
        else
            bud.bindex = bud.bindex-1;
            set(bm(i),'userdata',bud);
        end
    end
    bindx = 3;
else
    bindx = length(bm)+1;
end
bud.bindex = bindx;
bud.vindex = vindx;
bud.findex = findx;
bud.object = hnd;
createbomb(bud);

function createbomb(bud)
vr = get(bud.object,'vertices');
dis = vr(bud.vindex,:);
fc = get(bud.object,'faces');
fc = fc(bud.findex,:);

vr = vr(fc,:);
d = mindis(vr);
[x,y,z] = sphere(15);
x = x*(d*.2)+dis(1);
y = y*(d*.2)+dis(2);
z = z*(d*.2)+dis(3);

surface('parent',finddobj('axes'),'xdata',x,'ydata',y,'zdata',z,'tag','bomb','userdata',bud,'facecolor',[1 0 0],'clipping','off','edgecolor','none');

function r = mindis(vr)
r = inf;
for i = 2:length(vr(:,1))
    m = displace(vr(i:end,:),-vr(1,:));
    plate = min(sqrt(diag(m*m')));
    r = min(r,plate);
end

function r = findbomb(hnd,varargin)
bm = findobj(finddobj('axes'),'tag','bomb');
r = [];
for i = 1:length(bm)
    bud = get(bm(i),'userdata');
    if bud.object == hnd
        r = [r;bm(i)];
    else
        delete(bm(i));
    end
end
bm = r;
if nargin == 2
    r = [];
    for i = 1:length(bm)
        bud = get(bm(i),'userdata');
        r(bud.bindex,1) = getfield(bud,varargin{1});
    end
end

function r = findface(fplate,fc)

lfc = length(fc(:,1));
for i = 1:length(fplate)
    tmp = mod(find(fc==fplate(i)),lfc);
    if i > 1
        r = intersect(r,tmp);
    else
        r = tmp;
    end
end
r(find(r==0))=lfc;

function addface(hnd,index)
fc = get(hnd,'faces');
cdata = get(hnd,'cdata');
if isempty(findface(index,fc))
    fc = [fc;makerow(index)];
    cdata(end+1,1,:) = cdata(end,1,:);
    fvad = ones(length(fc(:,1)),1);
    set(hnd,'faces',fc,'cdata',cdata,'facevertexalphadata',fvad);
    return
end

function createmarker(nm,sz,pos)
[x,y,z] = sphere(15);
x = (x*sz/2)+pos(1);
y = (y*sz/2)+pos(2);
z = (z*sz/2)+pos(3);

[vr,fc] = surface2patch(x,y,z);
ud.vertices = vr;
ud.faces = fc;
ud.color = [0 1 0];
ax = finddobj('axes');

patch('parent',ax,'tag',nm,'facecolor',ud.color,'edgecolor','none','buttondownfcn',...
    'marker(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'userdata',ud,...
    'FaceLighting','gouraud','createfcn','marker(''createfcn'')','clipping','off');

function r = createpropmarker(nx,ny,nz,tg,ud)
r = surface('parent',finddobj('axes'),'facecolor',[1 0 0],'xdata',nx,'ydata',ny,'zdata',nz,'userdata',ud,'tag',tg,...
    'edgecolor','none','facelighting','gouraud','buttondownfcn','props(''prop marker buttondown'')',...
    'createfcn','props(''prop marker createfcn'')','deletefcn','props(''prop marker deletefcn'')');

function c = createprop(ud,tg)

% places prop at origin
ax = finddobj('axes');
if isfield(ud,'cdata');
    cdata = ud.cdata;
    ud = rmfield(ud,'cdata');
elseif isfield(ud,'bodypart')
    fc = ud.faces;
    if isempty(fc)
        cdata = [];
    else
        cdata(1,1:length(fc(:,1)),1) = ud.color(1);
        cdata(1,1:length(fc(:,1)),2) = ud.color(2);
        cdata(1,1:length(fc(:,1)),3) = ud.color(3);
    end
    
else
    ud.color = [.8 .8 .8];
    fc = ud.faces;
    if isempty(fc)
        cdata = [];
    else
        cdata(1,1:length(fc(:,1)),1) = ud.color(1);
        cdata(1,1:length(fc(:,1)),2) = ud.color(2);
        cdata(1,1:length(fc(:,1)),3) = ud.color(3);
    end
end

ud.currentorientation = [1 0 0;0 1 0;0 0 1];
ud.currentpredis = [0 0 0];
ud.currentpostdis = [0 0 0];

c = patch('parent',ax,'tag',tg,'facecolor','flat','edgecolor','none','buttondownfcn',...
    'props(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'cdata',cdata,'userdata',ud,...
    'FaceLighting','gouraud','createfcn','props(''createfcn'')','clipping','off','facevertexalphadata',1,'facealpha',.99);


if isfield(ud,'vertexnormals');
    set(c,'vertexnormals',ud.vertexnormals);
end

if isfield(ud,'mvertices')
    drawmarker(ud.mvertices,ud.mname,c);
end

function deletevertex(hnd,vindx)

%deletes a vertex
vr = get(hnd,'vertices');
fc = get(hnd,'faces');
ud = get(hnd,'userdata');

vr(vindx,:) = [];
ud.vertices(vindx,:) = [];

numfc = length(fc(:,1));
findx = find(fc==vindx);
findx = unique(mod(findx,numfc));
findx(find(findx==0)) = numfc;
%getting the rows that contain the vertex

fc(findx,:) = [];
cdata(1:length(fc(:,1)),1,1:3) = .8;
findx = find(fc>vindx);
fc(findx) = fc(findx)-1;
ud.faces = fc;
fvad = ones(length(fc(:,1)),1);

set(hnd,'vertices',vr,'faces',fc,'cdata',cdata,'facevertexalphadata',fvad,'userdata',ud);

function buttondownfxn

[tp,hnd] = currentobject;
vindx = findbomb(hnd,'vindex');
findx = findbomb(hnd,'findex');
if isempty(findx) || isempty(vindx)
    return
end
findx = findx(end);
fc = get(hnd,'faces');
vr = get(hnd,'vertices');

c = finddobj('controls');
xhnd = findobj(c,'tag','x');
yhnd = findobj(c,'tag','y');
zhnd = findobj(c,'tag','z');

if get(xhnd,'backgroundcolor') == [1 0 0];
    vr(vindx(1),1) = get(xhnd,'userdata');
else
    set(xhnd,'string',num2str(vr(vindx(1),1)),'userdata',vr(vindx(1),1));
end

if get(yhnd,'backgroundcolor') == [0 1 0];
    vr(vindx(1),2) = get(yhnd,'userdata');
else
    set(yhnd,'string',num2str(vr(vindx(1),2)),'userdata',vr(vindx(1),2));
end

if get(zhnd,'backgroundcolor') == [0 0 1];
    vr(vindx(1),3) = get(zhnd,'userdata');
else
    set(zhnd,'string',num2str(vr(vindx(1),3)),'userdata',vr(vindx(1),3));
end
set(hnd,'vertices',vr);

switch getbdownfxn
    case 'del vertex'
        deletevertex(hnd,vindx(1));
    case 'add face'
        if length(vindx)>=3
            addface(hnd,vindx(1:3));
        end
    case 'rot face'
        fc(findx,:) = fc(findx,[1 3 2]);
        ud = get(hnd,'userdata');
        ud.faces = fc;
        set(hnd,'faces',fc,'userdata',ud);
        delete(findobj(finddobj('axes'),'type','line','tag','tempobj'));
        hnd = plotnormals(hnd,2,'face');
        set(hnd,'tag','tempobj');
        
    case 'v normal'
        nvr = get(hnd,'vertexnormals');
        nvr = newvnormal(vr,nvr,vindx);
        ud = get(hnd,'userdata');
        set(hnd,'vertexnormals',nvr);
        delete(findobj(finddobj('axes'),'type','line','tag','tempobj'));
        hnd = plotnormals(hnd,2);
        set(hnd,'tag','tempobj');
    case 'nothing'
    case 'no edges'
        set(hnd,'edgecolor','none');
    case 'set origin'
        origin('create',hnd,vindx);
    case 'color'
        chnd = findobj(finddobj('controls'),'string','color');
        
        cdata = get(hnd,'cdata');
        cdata(findx,1,:) = get(chnd,'foregroundcolor');
        set(hnd,'cdata',cdata);
        
    case 'set object'
        origin('set object');
        
    case 'jointer'
        addjoint(hnd,vindx(1));
end

function r = getbdownfxn

hnd = findobj(findobj(finddobj('figure'),'tag','bdownfxns'),'value',1);

if isempty(hnd)
    r = 'nothing';
else
    r = get(hnd,'string');
end

function origin(action,varargin)

ohnd = findobj(finddobj('axes'),'tag','origin');

switch action
    case 'refresh'
        oud = get(ohnd,'userdata');
    case 'set object'
        ohnd = findobj(finddobj('axes'),'tag','origin');
        if isempty(ohnd)
            set(findobj(finddobj('figure'),'string','set object','type','uicontrol'),'value',0,'string','set origin');
            return
        end
        oud = get(ohnd,'userdata');
        gunit = [1 0 0;0 1 0;0 0 1];
        ort = makeunit(ctransform(oud.ort,gunit,oud.rort));
        transformhnd(oud.object,gunit,ort,-oud.dis);
        mrk = finddobj('marker');
        for i = 1:length(mrk)
            transformhnd(mrk(i),gunit,ort,-oud.dis)
        end
        delete(ohnd);
        set(findobj(finddobj('figure'),'string','set object','type','uicontrol'),'value',0,'string','set origin');
        return
    case 'create'
        hnd = varargin{1};
        vindex = varargin{2};
        if length(unique(vindex))~=3 && isempty(ohnd)
            return
        end
        oud.object = hnd;
        oud.vindex = vindex;
        set(findobj(finddobj('figure'),'type','uicontrol','string','set origin'),'string','set object','value',0);
end

vr = get(oud.object,'vertices');
vr = vr(oud.vindex,:);
i = vr(2,:)-vr(1,:);
j = vr(3,:)-vr(1,:);
k = cross(i,j);
j = -cross(i,k);
coeff = sqrt(i*i');
unt = makeunit([i;j;k]);
dis = vr(1,:);
oud.ort = unt;
oud.dis = dis;
gunit = [1 0 0;0 1 0;0 0 1];
if ~isfield(oud,'rort')
    oud.rort = gunit;
end

unt = ctransform(unt,gunit,oud.rort);
[ovr,ofc,cdata] = k2graphics('orientation',unt,dis,coeff);

if isempty(ohnd)
    patch('parent',finddobj('axes'),'vertices',ovr,'faces',ofc,'cdata',cdata,'edgecolor','none','facecolor','flat',...
        'facelighting','gouraud','tag','origin','userdata',oud,'buttondownfcn','props(''origin'')','facevertexalphadata',1,'facealpha',.99);
    
else
    set(ohnd,'vertices',ovr,'faces',ofc,'cdata',cdata,'userdata',oud);
end

function transformhnd(hnd,unt,unt2,dis)

vr = get(hnd,'vertices');
vr = displace(vr,dis);
vr = ctransform(unt,unt2,vr);
set(hnd,'vertices',vr);
ud = get(hnd,'userdata');
if isfield(ud,'mvertices')
    ud.mvertices = ctransform(unt,unt2,displace(ud.mvertices,dis));
end
if isfield(ud,'vertices')
    ud.vertices = ctransform(unt,unt2,displace(ud.vertices,dis));
end

function mark(frm)

gunit = [1 0 0;0 1 0;0 0 1];
phnd = finddobj('props');
jhnd = finddobj('props','joint');
phnd = [makecolumn(setdiff(phnd,jhnd));makecolumn(jhnd)];

for i = 1:length(phnd)
    
    pud = get(phnd(i),'userdata');
    
    if isfield(pud,'association') %prop is an object that is fitted to markers
        mvr = getmarkers(pud.association(:,2),frm);
        ovr = getmarkers(phnd(i));
        [zdis,ort,pdis] = fitobject(ovr,mvr);
        vr = pud.vertices;
        fc = pud.faces;
        vr = displace(vr,zdis);
        vr = ctransform(ort,gunit,vr);
        vr = displace(vr,pdis);
        
        mvr = displace(pud.mvertices,zdis);
        mvr = ctransform(ort,gunit,mvr);
        mvr = displace(mvr,pdis);
        nvr = ctransform(ort,gunit,pud.vertexnormals);
        pud.currentorientation = ort;
        pud.currentpredis = zdis;
        pud.currentpostdis = pdis;
        drawmarker(mvr,pud.mname,phnd(i),'invisible');
        
    elseif isfield(pud,'joint') %prop is a joint that joins two props
        [vr,fc,cdata,nvr] = getjointdata(pud);
        set(phnd(i),'vertices',vr,'faces',fc,'cdata',cdata,'vertexnormals',nvr);
        continue
        
    elseif isfield(pud,'fx');
        forceplate('refresh',phnd(i));
        continue
        
    elseif isfield(pud,'ort') %prop is moves on its own
        if frm > length(pud.ort);
            continue
        end
        vr = ctransform(pud.ort{frm},gunit,pud.vertices);
        vr = displace(vr,pud.dis(frm,:));
        fc = pud.faces;
        nvr = 'none';
        
    else
        continue
    end
    
    if isfield(pud,'units');
        vr = vr*pud.units;
    end
    
    % move each prop a single frame
    if ischar(nvr)
        set(phnd(i),'vertices',vr,'faces',fc,'userdata',pud,'normalmode','auto');
    else
        set(phnd(i),'vertices',vr,'faces',fc,'userdata',pud,'vertexnormals',nvr);
    end
end

function r = getmarkers(mrk,frm)

r = [];
if nargin == 1;
    pud = get(mrk,'userdata');
    vr = pud.mvertices;
    nm = pud.mname;
    as = pud.association(:,1);
    for i = 1:length(as);
        indx = find(strcmp(as{i},nm));
        if isempty(indx)
            r = [r;[NaN,NaN,NaN]];
        else
            r = [r;vr(indx,:)];
        end
    end
else
    mhnd = finddobj('marker');
    for i = 1:length(mrk)
        hud= get(smartfind(mhnd,mrk{i}),'userdata');
        if isempty(hud)
            plate = [NaN NaN NaN];
        elseif frm > length(hud.dis(:,1))
            plate = [NaN,NaN,NaN];
        else
            plate = hud.dis(frm,:);
        end
        r = [r;plate];
    end
end


function r = smartfind(hnd,tg)

r = findobj(hnd,'tag',tg);
if isempty(r)
    r = findobj(hnd,'tag',['z',tg]);
end


function drawmarker(mvr,nm,pt)
[x,y,z] = sphere(15);
x = x*.7;
y = y*.7;
z = z*.7;
ax = finddobj('axes');
for i = 1:length(nm);
    nx = x+mvr(i,1);
    ny = y+mvr(i,2);
    nz = z+mvr(i,3);
    hnd = findobj(ax,'tag',nm{i},'userdata',pt);
    if nargin == 4
        delete(hnd);
    else
        if isempty(hnd)
            createpropmarker(nx,ny,nz,nm{i},pt);
        else
            set(hnd,'xdata',nx,'ydata',ny,'zdata',nz);
        end
    end
end


function [xyz,ort] = pucktrajectory(mrk,smp,varargin)

if nargin == 2
    if iscell(mrk)
        tmp = mrk;
        mrk = [];
        ax = finddobj('axes');
        mrk(1) = findobj(ax,'tag',tmp{1});
        mrk(2) = findobj(ax,'tag',tmp{2});
    end
    p1 = get(mrk(1),'userdata');
    p1 = p1.dis;
    
    p2 = get(mrk(2),'userdata');
    p2 = p2.dis;
    
elseif nargin == 3
    p1 = mrk;
    p2 = smp;
    smp = varargin{1};
end
ort = {[1 0 0;0 1 0;0 0 1]};
xyz = (p1+p2)/2;

%getting the velocity
v = xyz(2:end,:)-xyz(1:end-1,:);
v = [[0 0 0];v];
v = v*smp;

%finding the first point that needs extrapolation
indx = max(find(~isnan(v(:,1))));
indx = indx-5;
v0 = v(indx,:);
d0 = xyz(indx,:);

nxyz = trajectory(d0,v0,smp,428);

if isempty(nxyz)
    lxyz = 1;
    xyz(indx+1:end,:) = [];
else
    lxyz = length(nxyz(:,1));
    % putting the data in the xyz variable
    xyz(indx:indx+lxyz-1,:) = nxyz;
    
    %deleteing the  rest
    xyz(indx+lxyz:end,:) = [];
end

for i = 2:indx+lxyz-1
    if i == indx
        trf = ctransform(ort{i-1},ort{i-2});
    end
    if i >= indx
        ort{i}  = makeunit(ort{i-1}*trf);
    else
        pt1 = p1(i,:);
        pt2 = p2(i,:);
        pt3 = p1(i,:)-p1(i-1,:)+p2(i-1,:);
        tort = getort(pt1,pt2,pt3);
        if isnan(tort)
            tort = ort{i-1};
        end
        ort{i}=tort;
    end
end


function ort = getort(pt1,pt2,pt3)

vec1 = pt2-pt1;
vec2 = pt3-pt1;

if angle(vec1,vec2)<10
    ort = gunit;
else
    i = vec1;
    k = cross(vec1,vec2);
    j = cross(k,i);
    if k(3) <0
        k = -k;
        nvec = -cross(i,k);
        if dot(nvec,j)<0
            j = -j;
        end
    end
    ort = makeunit([i;j;k]);
end


function refreshprop
prp = finddobj('props');
mrk = finddobj('marker');
for i = 1:length(prp)
    ud = get(prp(i),'userdata');
    if isfield(ud,'puckmarkers');
        if isempty(findobj(mrk,'tag',ud.puckmarkers{1})) || isempty(findobj(mrk,'tag',ud.puckmarkers{2}))
            continue
        end
        
        if ishandle(findobj(mrk,'tag',ud.puckmarkers{1})) && ishandle(findobj(mrk,'tag',ud.puckmarkers{2}))
            [xyz,ort] = pucktrajectory(ud.puckmarkers,ud.samplerate);
            ud.dis = xyz;
            ud.ort = ort;
            set(prp(i),'userdata',ud);
        end
    end
end


function displaceprop(hnd,vec)

if strcmp(getbdownfxn,'vertex')
    bm = finddobj('bomb');
    for i = 1:length(bm)
        bud = get(bm(i),'userdata');
        vr = get(bud.object,'vertices');
        vr(bud.vindex,:) = vr(bud.vindex,:)+vec;
        ud = get(bud.object,'userdata');
        ud.vertices = real2zero(vr,ud.currentpredis,ud.currentpostdis,ud.currentorientation);
        set(bud.object,'vertices',vr,'userdata',ud);
    end
else
    vr = get(hnd,'vertices');
    vr = displace(vr,vec);
    set(hnd,'vertices',vr);
end


function clr = file2clr(flnm)
flnm = lower(flnm);
top =  findstr(flnm,'top');
ri = findstr(flnm,'right');

if ~isempty(top)
    top = 1;
else
    top = 0;
end
if ~isempty(ri)
    ri = 1;
else
    ri = 0;
end

if top && ri
    clr = [1 0 0];
elseif top && ~ri
    clr = [0 1 0];
elseif ~top && ri
    clr = [0 0 1];
else
    clr = [1 1 0];
end


function caliper(hnd)

if length(hnd) == 2
    stk = [];
    for i = 1:length(hnd);
        ud = get(hnd(i),'userdata');
        vr = get(ud.object,'vertices');
        stk = [stk;vr(ud.vindex,:)];
    end
    mx = max(stk);
    mn = min(stk);
    vec = stk(1,:)-stk(2,:);
    nm = [mx-mn,sqrt(vec*vec')];
    nm = num2str(nm);
elseif length(hnd)==1
    ud = get(hnd,'userdata');
    nm = num2str(ud.vindex);
else
    nm = '';
end
set(gcf,'name',nm)


function vr = zero2real(vr,predis,postdis,ort)

vr = displace(vr,predis);
vr = ctransform(ort,[1 0 0;0 1 0;0 0 1],vr);
vr = displace(vr,postdis);


function vr = real2zero(vr,predis,postdis,ort)
vr = displace(vr,-postdis);
vr = ctransform([1 0 0;0 1 0;0 0 1],ort,vr);
vr = displace(vr,-predis);


function addjoint(hnd,vindx)

jhnd = finddobj('props','joint');
if isempty(jhnd)
    tg = inputdlg('enter the name for the joint');
    if isempty(tg)
        return
    end
    tg = tg{1};
    ud.color = [.8 .8 .8];
    ud.vertices = [];
    ud.faces = [];
    ud.joint(1).object= get(hnd,'tag');
    ud.joint(1).vertices= vindx;
    r = createprop(ud,tg);
    set(r,'userdata',ud);
    
    return
elseif length(jhnd) ~= 1
    return
end

ud = get(jhnd,'userdata');
obj = get(hnd,'tag');
found = 0;
ljnt = length(ud.joint);
for i = 1:ljnt
    if strcmp(ud.joint(i).object,obj);
        ud.joint(i).vertices = [ud.joint(i).vertices;vindx];
        found = 1;
        break
    end
end
if ~found
    ud.joint(ljnt+1).object = get(hnd,'tag');
    ud.joint(ljnt+1).vertices = vindx;
end
set(jhnd,'userdata',ud);


function [vr,fc,cdata,nvr] = getjointdata(ud)

vstk = [];
bstk = [];
nstk = [];
ax = finddobj('axes');
for i = 1:length(ud.joint);
    bstk = [bstk;length(ud.joint(i).vertices)];
    hnd = findobj(ax,'tag',ud.joint(i).object);
    vr = get(hnd,'vertices');
    nvr = get(hnd,'vertexnormals');
    if isempty(vr)
        continue
    end
    vstk = [vstk;vr(ud.joint(i).vertices,:)];
    nstk = [nstk;nvr(ud.joint(i).vertices,:)];
end
if isempty(vstk)
    vr = [];
    fc = [];
    cdata = [];
    nvr = [];
    return
end
nvr = nstk;
vr = vstk;
bstk = bstk(1);
fc = [[(1:bstk-1)',(2:bstk)',(bstk+1:2*bstk-1)'];[(2:bstk)',(bstk+2:2*bstk)',(bstk+1:2*bstk-1)']];

fc = fc(:,[1 2 3]);
numfc = length(fc(:,1));
findx = find(fc>length(vr(:,1)));
findx = unique(mod(findx,numfc));
findx(find(findx==0)) = numfc;
fc(findx,:) = [];

cdata(1,1:length(fc(:,1)),1) = ud.color(1);
cdata(1,:,2) = ud.color(2);
cdata(1,:,3) = ud.color(3);


function r = newvnormal(vr,nvr,vindx)
r = nvr;
if length(vindx) == 1
    r(vindx,:) = -r(vindx,:);
    return
end

mvr = mean(vr(vindx,:));
ort = makeunit(displace(vr(vindx,:),-mvr));
r(vindx,:) = ort;


function rezerovertices(hnd)

hud = get(hnd,'userdata');
dis = hud.dis;
indx = min(find(~isnan(dis(:,1))));
vr = hud.vertices(:,3);
delta = min(vr)+dis(indx,3);
vr = vr-delta;
hud.vertices(:,3) = vr;
set(hnd,'userdata',hud);


function plugingait(c3d)

amat = {'PEL','Pelvis';...
    'LFE','LeftFemur';...
    'LTI','LeftTibia';...
    'LFO','LeftFoot';...
    'LTO','LeftToe';...
    'RFE','RightFemur';...
    'RTI','RightTibia';...
    'RFO','RightFoot';...
    'RTO','RightToe';...
    'TRX','Thorax';...
    'HED','Head';...
    'LCL','LeftClavicle';...
    'LHU','LeftHumerus';...
    'LRA','LeftRadius';...
    'LHN','LeftHand';...
    'RCL','RightClavicle';...
    'RHU','RightHumerus';...
    'RRA','RightRadius';...
    'RHN','RightHand'};

prp = finddobj('props');
dim = {'O','A','L','P'};
for i = 1:length(amat(:,1))
    d = [];
    for j = 1:4
        d{j} = getchannelc3d(c3d,[amat{i,1},dim{j}],'all');
    end
    bn = amat{i,2};
    [dis,ort] = getdata(d);
    hnd = findobj(prp,'tag',bn);
    hud = get(hnd,'userdata');
    hud.dis =dis;
    hud.ort = ort;
    set(hnd,'userdata',hud);
end


function zooplugingait(data)
     
amat = {'PEL','Pelvis';...
    'LFE','LeftFemur';...
    'LTI','LeftTibia';...
    'LFO','LeftFoot';...
    'LTO','LeftToe';...
    'RFE','RightFemur';...
    'RTI','RightTibia';...
    'RFO','RightFoot';...
    'RTO','RightToe';...
    'TRX','Thorax';...
    'HED','Head';...
    'LCL','LeftClavicle';...
    'LHU','LeftHumerus';...
    'LRA','LeftRadius';...
    'LHN','LeftHand';...
    'RCL','RightClavicle';...
    'RHU','RightHumerus';...
    'RRA','RightRadius';...
    'RHN','RightHand'};

prp = finddobj('props');
dim = {'O','A','L','P'};
for i = 1:length(amat(:,1))
    d = [];
    
    if isfield(data,[amat{i,1},dim{1}])  % if you have dim1 you have them all
        
        for j = 1:4
            d{j} = data.([amat{i,1},dim{j}]).line;
        end
        bn = amat{i,2};
        [dis,ort] = getdata(d);
        hnd = findobj(prp,'tag',bn);
        hud = get(hnd,'userdata');
        hud.dis =dis;
        hud.ort = ort;
        set(hnd,'userdata',hud);
    end
end

function [dis,ort] = getdata(data)

dis = data{1}/10;

a = (data{2}-data{1})/10;
l = (data{3}-data{1})/10;
p = (data{4}-data{1})/10;

[rw,~] = size(a);
ort = [];
for i = 1:rw
    ort = [ort;{[a(i,:);l(i,:);p(i,:)]}];
end


function zooloadanalog(data)

s = filesep;    % determine slash direction based on computer type


d = which('director'); % returns path to ensemlber
path = pathname(d) ;  % local folder where director resides

ach =  data.zoosystem.Analog.Channels;
nplates = data.zoosystem.Analog.FPlates.NUMUSED;

if ismember('F1X1',ach)
    disp('kistler force plates detected, computed GRF')
    data = kistlerGRF_data(data);
    ach =  data.zoosystem.Analog.Channels;
end
% attempt to catch 'standard' force plate channel names
%
fpch = cell(size(ach));

for i = 1:length(ach)
    ch = ach{i};
    
    if length(ch) ==3  && (isin(lower(ch(1)),'f') || isin(lower(ch(1)),'m')) 
        fpch{i} = ach{i};
    elseif isin(ch,'Force') || isin(ch,'Moment')
        fpch{i} = ach{i};
    end
end

fpch(cellfun(@isempty,fpch)) = [];     


% compute cop in global coordinates
if ~isempty(fpch)
    localOr = getFPLocalOrigin(data);
    
    [globalOr,orientFP] = getFPGlobalOrigin(data);
    
     if ~isfield(data,'COP1') 
        data = centreofpressure_data(data,localOr,globalOr,orientFP);
     end
    
     for i = 1:nplates
         f = ['forceplate',num2str(i),'.prop'];
         file = engine('fld',path,'search file',f);
         if isempty(file)
             error(['cannot locate file: ',f])
         end
         prp = props('load',file{1});     
         zooinsertdata(prp,fpch,data);
         setfporientation(prp,data,globalOr)    % set global orientation of FP
         getfpcop(prp,data)
     end
    

end
% forceplate('refresh COP');  % old code no longer works

function getfpcop(phnd,data)

fpnum =  get(phnd,'Tag');                     % get fp number
fpnum = fpnum(end); 
pud = get(phnd,'userdata');

x = data.(['COP',fpnum]).line(:,1);           % extract COP 
y = data.(['COP',fpnum]).line(:,2);         
z = data.(['COP',fpnum]).line(:,3);

x(isnan(x)) = 0 ;  
y(isnan(y)) = 0 ;  
z(isnan(z)) = 0 ;  


x = DecimateAnalog(x,data.zoosystem.AVR);     % downsample
y = DecimateAnalog(y,data.zoosystem.AVR);     % if required
z = DecimateAnalog(z,data.zoosystem.AVR);

pud.cop = clean([x y z]);
set(phnd,'userdata',pud);


function setfporientation(phnd,data,globalOr)

fpnum =  get(phnd,'Tag');
fpnum = fpnum(end);
pud = get(phnd,'userdata');

% resize force plate
if isfield(data.zoosystem.Analog,'FPlates')
    corners = data.zoosystem.Analog.FPlates.CORNERS(:,:,str2double(fpnum));
    Length = (max(corners(1,:)) - min(corners(1,:)))/10;  % in cm
    Width = (max(corners(2,:)) - min(corners(2,:)))/10;   % in cm
    
    Lratio = Length/50;
    Wratio = Width/50;
    
    pud.vertices(:,1) = pud.vertices(:,1)*Lratio;
    pud.vertices(:,2) = pud.vertices(:,2)*Wratio;

end

% move force plate
pud.vertices = displace(pud.vertices,globalOr.(['FP',fpnum])*100);         %displace FP checked good


set(phnd,'userdata',pud);


function zooinsertdata(phnd,ch,zdata)

pud = get(phnd,'userdata');

if isfield(pud,'fz')
    
    indx = myfindstr(lower(ch),'fz',pud.id);
    if isempty(indx)
        error('force field empty')
    end
    if max(zdata.(ch{indx}).line) < 10;   % these are forces of body on ground
        conv = -1;
    else                                  % these are forces of ground on body
        conv = 1;
    end 
    pud.fz = conv*DecimateAnalog(zdata.(ch{indx}).line,zdata.zoosystem.AVR);
    
    indx = myfindstr(lower(ch),'fx',pud.id);
    if isempty(indx)
        error('force field empty')
    end
    pud.fx = conv*DecimateAnalog(zdata.(ch{indx}).line,zdata.zoosystem.AVR);
    
    indx = myfindstr(lower(ch),'fy',pud.id);
    if isempty(indx)
        error('force field empty')
    end
    pud.fy = -conv*DecimateAnalog(zdata.(ch{indx}).line,zdata.zoosystem.AVR);
    
    % shrink GRF vector for adults
    if max(pud.fz) > 900  % adult
        pud.coeff = 0.05;
    end
   
%     indx = myfindstr(lower(ch),'mx',pud.id);
%     if isempty(indx)
%         error('moment field empty')
%     end
%      pud.mx = DecimateAnalog(zdata.(ch{indx}).line,zdata.zoosystem.AVR);
%     
%     indx = myfindstr(lower(ch),'my',pud.id);
%     if isempty(indx)
%         error('moment field empty')
%     end
%     pud.my = DecimateAnalog(zdata.(ch{indx}).line,zdata.zoosystem.AVR);
%     
%     indx = myfindstr(lower(ch),'mz',pud.id);
%     if isempty(indx)
%         error('moment field empty')
%     end
%     pud.mz = DecimateAnalog(zdata.(ch{indx}).line,zdata.zoosystem.AVR);

    set(phnd,'userdata',pud);
    
    
end

function indx = myfindstr(cl,str1,str2)
indx = [];
for i = 1:length(cl);
    if ~isempty(findstr(cl{i},str1)) && ~isempty(findstr(cl{i},str2))
        indx = i;
        return
    end
end

function r = DecimateAnalog(vec,num)
r = vec(1:num:end);

function r = clean(xyz)
r = xyz/10;
indx = find(xyz==0);
a = zeros(size(xyz));
a(indx) = 1;
indx = find(sum(a')==3);
r(indx,:) = NaN;

function skate(hnd)

ud = get(hnd,'userdata');

if isin(ud.bodypart,'R')
    side = 'Right';
elseif isin(ud.bodypart,'L')
    side = 'Left';
else
    return
end

% get displacement of tibia
or_hd = findobj(finddobj('axes'),'tag',[side,'Tibia']);
dis = get(or_hd,'userdata');
dis = dis.dis;

% get orientation of foot
%
hd = findobj(finddobj('axes'),'tag',[side,'Foot']);
hud = get(hd,'userdata');
if isempty(hud)
    return
elseif isfield(hud,'ort');
    
    ort = hud.ort;
    ort = makeunit(ort);
else
    return
end

ort = transform_ort(ort,[3,2,1]);
ort = transform_ort(ort,[2 -1 3]);

ud.ort = ort;
ud.dis = dis;

% resize skates
ud.vertices = ud.vertices./1.2;

set(hnd,'userdata',ud);
