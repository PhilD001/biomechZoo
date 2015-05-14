function varargout = sculpttool(action,varargin)

switch action
    case 'rasp'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'costume')
            return
        end
        ax = finddobj('axes');
        ctarg = get(ax,'cameratarget');
        answer = inputdlg({'length (cm)';'width (cm)';'radius(cm)';'resolution (cm)'},'length',1,{'10','2','10','.2'});
        if isempty(answer);
            return
        end        
        createrasp(str2num(answer{1}),str2num(answer{2}),str2num(answer{3}),str2num(answer{4}),ctarg,hnd);
        
    case 'plane'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'costume')
            return
        end
        ax = finddobj('axes');
        ctarg = get(ax,'cameratarget');
        answer = inputdlg({'length (cm)';'width (cm)';'resolution (cm)'},'length',1,{'10','2','.2'});
        if isempty(answer);
            return
        end        
        createplane(str2num(answer{1}),str2num(answer{2}),str2num(answer{3}),ctarg,hnd);
    case 'buttondown'
        hi = finddobj('highlight');
        set(hi,'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        cameraman('buttondown');
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        
        
    case 'keypress'
        keypress(varargin{1});
        
    case 'carve'
        tl = finddobj('tool');
        if isempty(tl)
            return
        end        
        ud = get(tl,'userdata');
        obj = ud.target;
        ovr = get(obj,'vertices');
        tvr = get(tl,'vertices');
        tfc = get(tl,'faces');
        hnd = finddobj('units','volume');
        
        [oindx,tindx] = findclosevert(ovr,tvr,get(hnd,'userdata'));
        if isempty(oindx)
            return
        end
        stick2tool(obj,tl,oindx,tindx);
        
    case 'create patch'
        tl = finddobj('tool');
        if isempty(tl)
            return
        end        
        ud = get(tl,'userdata');
        obj = ud.target;
        ud = get(obj,'userdata');
        vr = ud.vertices;
        fc = ud.faces;
        lvr = length(vr(:,1));
        svr = get(tl,'vertices');
        svr = gunit2cosunit(svr,obj);
        sfc = get(tl,'faces');
        vr = [vr;svr];
        fc = [fc;sfc+lvr];
        ud.vertices = vr;
        ud.faces = fc;
        set(obj,'userdata',ud);
        costume('stick',obj);
    case 'save'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'tool')
            return
        end
        [f,p] = uiputfile('*.tool');
        if f == 0
            return
        end
        cd(p);
        f = extension(f,'.tool');
        ud = get(hnd,'userdata');
        tr = ud.target;
        tud = get(tr,'userdata');
        hd = findpart(tud.actor,'head');
        hud = get(hd,'userdata');
        odis = getfield(hud.currentposition,tud.bodypart);
        oort = getfield(hud.currentorientation,tud.bodypart);
        rdis = ud.dis-odis;
        rdis = ctransform([1 0 0;0 1 0;0 0 1],oort,rdis);
        ud.rdis = rdis;
        tooldata = ud;
        save([p,f],'tooldata');
        
    case 'load'
        [tp,hnd] = currentobject;
        if ~strcmp(tp,'costume')
            return
        end
        t = load(varargin{1},'-mat');
        tooldata = t.tooldata;
        tooldata.target = hnd;
        tud = get(hnd,'userdata');
        hd = findpart(tud.actor,'head');
        hud = get(hd,'userdata');
        odis = getfield(hud.currentposition,tud.bodypart);
        oort = getfield(hud.currentorientation,tud.bodypart);
        rdis = ctransform(oort,[1 0 0;0 1 0;0 0 1],tooldata.rdis);
        tooldata.dis = odis+rdis;
        tooldata = rmfield(tooldata,'rdis');
        
        delete(findobj(finddobj('tool'),'tag',tooldata.type));
        patch('tag',tooldata.type,'userdata',tooldata,'edgecolor','none','facecolor',[.8 .8 .8],'buttondownfcn','sculpttool(''buttondown'')');
        refreshtool;
        
end
        
function createrasp(len,wid,ra,res,initialpos,trg);

delete(findobj(finddobj('axes'),'tag','rasp'));
numvert = round(len/res);
inc = len/numvert;

%length is along the x
%width is along the y

plate1 = [len/2,wid/2,0];
plate2 = [len/2,-wid/2,0];
dis = (0:inc:len)';


stk1 = dis-len/2;
stk2 = stk1;

stk1(:,2) = wid/2;
stk2(:,2) = -wid/2;
stk1(:,3) = 0;
stk2(:,3) = 0;

lstk = length(stk1(:,1));
vr = [stk1;stk2];
fc = (1:lstk-1)';
fc(:,2) = fc(:,1)+1;
fc(:,3) = fc(:,1)+lstk+1;
fc(:,4) = fc(:,1)+lstk;

fc1 = fc(:,[1,2,3]);
fc2 = fc(:,[3,4,1]);
fc = [fc1;fc2];

%creating circle
xd = vr(:,1);
    
cntr = [min(xd),ra];
yd = sqrt(ra^2-((xd-cntr(1)).*(xd-cntr(1))))-cntr(2);
if ra < len
    indx = find(vr(:,1)<=ra);
    vr(indx,3) = yd(indx);
    indx = find(vr(:,1)>ra);
    tmp = vr(indx,3);
    vr(indx,3) =  vr(indx,1);
    vr(indx,1) = tmp;
else
    yd = sqrt(ra^2-((xd-cntr(1)).*(xd-cntr(1))))-cntr(2);
    vr(:,3) = yd;
end


ud.type = 'rasp';
ud.vertices = vr;
ud.faces = fc;
ud.ort = [1 0 0;0 1 0;0 0 1];
ud.dis = initialpos;
ud.target = trg;
ud.length = len;
ud.width = wid;
ud.resolution = res;
ud.radius = ra;





patch('parent',finddobj('axes'),'edgecolor','none','facecolor',[.8 .8 .8],'vertices',vr,'faces',fc,'userdata',ud,...
    'buttondownfcn','sculpttool(''buttondown'')','tag','rasp');
refreshtool;


function refreshtool

t = finddobj('tool');
for i = 1:length(t);
    ud = get(t(i),'userdata');
    vr = ud.vertices;
    vr = ctransform(ud.ort,[1 0 0;0 1 0;0 0 1],vr);
    vr(:,1) = vr(:,1)+ud.dis(1);
    vr(:,2) = vr(:,2)+ud.dis(2);
    vr(:,3) = vr(:,3)+ud.dis(3);
    set(t(i),'vertices',vr,'faces',ud.faces);
end
    

function keypress(hnd);
[md,mval] = currentunits;
dval = finddobj('units','displacement','number');
rval = finddobj('units','rotation','number');

cky = get(gcf,'currentkey');
ud = get(hnd,'userdata');

vec = [];
switch cky
    case 'uparrow'
        vec = [0 -dval 0];        
    case 'downarrow'
        vec = [0 dval 0];
    case 'leftarrow'
        vec = [dval 0 0];
    case 'rightarrow'
        vec = [-dval 0 0];
    case 't'
        vec = [0 0 dval];
    case 'u'
        vec = [0 0 -dval];
    case '6'
        if strcmp(md,'rotation');
            ud.ort = vecrotate(ud.ort,rval,'x');
        else
            ud.ort = [0 1 0;0 0 1;-1 0 0];
        end
    case '4'
        if strcmp(md,'rotation');
            ud.ort = vecrotate(ud.ort,-rval,'x');
        else
            ud.ort = [0 1 0;0 0 1;1 0 0];
        end
    case '2'
        if strcmp(md,'rotation');
            ud.ort = vecrotate(ud.ort,rval,'y');
        else
            ud.ort = [1 0 0;0 0 1;0 1 0];
        end
    case '8'
        if strcmp(md,'rotation');
            ud.ort = vecrotate(ud.ort,-rval,'y');
        else        
            ud.ort = [1 0 0;0 0 1;0 -1 0];            
        end
    case 'a'
        if ud.ort(3,3)== 1
            ud.ort = [1 0 0;0 1 0;0 0 -1];
        else
            ud.ort = [1 0 0;0 1 0;0 0 1];
        end
    case 'q'
        if strcmp(md,'rotation');
            ud.ort = vecrotate(ud.ort,rval,'z');
        end
    case 'w'
        if strcmp(md,'rotation');
            ud.ort = vecrotate(ud.ort,-rval,'z');
        end
    case 'e'
        if strcmp(md,'volume');
            curvetool(hnd,mval);
            return
        end
    case 'r'
        sculpttool('carve');
        
    case 'c'
        sculpttool('create patch');
        return
    otherwise
        return
end
if ~isempty(vec)
    vec = ctransform(ud.ort,[1 0 0;0 1 0;0 0 1],vec);
    ud.dis = ud.dis+vec;
end
set(hnd,'userdata',ud);
refreshtool;




function stick2tool(obj,tl,oindx,tindx);

ovr = get(obj,'vertices');
tvr = get(tl,'vertices');
tfc = get(tl,'faces');
for i = 1:length(oindx);
    %getting point on object
    pt = ovr(oindx(i),:);
    
    %finding plane on tool
    fc = min(findface(tfc,tindx(i)));
    fc = tfc(fc,:);
    pln = tvr(fc(1:3),:);
    
    ovr(oindx(i),:) = pointplane('intersect',pt,pln);
end
set(obj,'vertices',ovr);

function r = findface(fc,vindx);
r = [];
for i = 1:length(fc(1,:));
    r = union(r,find(fc(:,i)==vindx));        
end
    
function createplane(len,wid,res,initialpos,trg);

delete(findobj(finddobj('axes'),'tag','plane'));
numvert = round(len/res);
inc = len/numvert;

%length is along the x
%width is along the y

plate1 = [len/2,wid/2,0];
plate2 = [len/2,-wid/2,0];
dis = (0:inc:len)';


stk1 = dis-len/2;
stk2 = stk1;

stk1(:,2) = wid/2;
stk2(:,2) = -wid/2;
stk1(:,3) = 0;
stk2(:,3) = 0;

lstk = length(stk1(:,1));
vr = [stk1;stk2];
fc = (1:lstk-1)';
fc(:,2) = fc(:,1)+1;
fc(:,3) = fc(:,1)+lstk+1;
fc(:,4) = fc(:,1)+lstk;


ud.type = 'plane';
ud.vertices = vr;
ud.faces = fc;
ud.ort = [1 0 0;0 1 0;0 0 1];
ud.dis = initialpos;
ud.target = trg;
ud.length = len;
ud.width = wid;
ud.resolution = res;





patch('parent',finddobj('axes'),'edgecolor','none','facecolor',[.8 .8 .8],'vertices',vr,'faces',fc,'userdata',ud,'tag','tool',...
    'buttondownfcn','sculpttool(''buttondown'')','tag','plane');
refreshtool;
    

function curvetool(hnd,val);

ud = get(hnd,'userdata');
if ~isfield(ud,'radius');
    return
end

vr = ud.vertices;
ud.radius = ud.radius+val;
%creating circle
xd = vr(:,1);

cntr = [min(xd),ud.radius];
yd = sqrt(ud.radius^2-((xd-cntr(1)).*(xd-cntr(1))))-cntr(2);
vr(:,3) = yd;
ud.vertices = vr;
set(hnd,'userdata',ud);
refreshtool;


function indx = findcarvevert(hnd);

ud = get(hnd,'userdata');


function r = gunit2cosunit(vr,hnd);

ud = get(hnd,'userdata');
hd = findpart(ud.actor,'head');
hud = get(hd,'userdata');
pos = getfield(hud.currentposition,ud.bodypart);
vr(:,1) = vr(:,1)-pos(1);
vr(:,2) = vr(:,2)-pos(2);
vr(:,3) = vr(:,3)-pos(3);
r = vr;