function varargout = zmarker(action,varargin)

switch action
    case 'buttondown'
        if strcmp(get(gcf,'selectiontype'),'alt')            
            hnd1 = finddobj('highlight');
            caliper(hnd1,gcbo);
        end
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        set(finddobj('highlight'),'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);        
        if ~strcmp(currentperson,'props')
            cameraman('buttondown');
            return
        end
        if ~strcmp(get(gcf,'selectiontype'),'alt')            
            caliper;
        end
        
        buttondownfxn;
   
    case 'load c3d'
        delete(finddobj('marker'));
        loadc3d(varargin{1});
        props('refresh');
        
     case 'load zoo'
        delete(finddobj('marker'));
        loadzoo(varargin{1});
        props('refresh');
    case 'goto'
        mark(varargin{1});
  
end


function caliper(varargin)

if nargin == 2;
    h1 = varargin{1};
    h2 = varargin{2};
    if isempty(h1)||isempty(h2)
        return
    end
    vr1 = mean(get(h1,'vertices'));
    vr2 = mean(get(h2,'vertices'));
    delta = vr2-vr1;
else
    bm = finddobj('bomb');
    vr = get(gco,'vertices');
    midpt = mean(vr);
    if isempty(bm);
        set(gcf,'name','');
        return
    else
        bud = get(bm(1),'userdata');
        vr = get(bud.object,'vertices');
        vr = vr(bud.vindex,:);
        delta = midpt-vr;       
    end
end
mg = sqrt(delta*delta');
set(gcf,'name',num2str([delta,mg]));

% function r = createmarker(nm,sz,pos,clr)
% [x,y,z] = sphere(15);
% x = (x*sz/2);
% y = (y*sz/2);
% z = (z*sz/2);
% 
% [vr,fc] = surface2patch(x,y,z);
% ud.vertices = vr;
% ud.faces = fc;
% ud.color = clr;
% ud.dis = pos;
% ud.size = sz;
% ax = finddobj('axes');
% 
% r = patch('parent',ax,'tag',nm,'facecolor',ud.color,'edgecolor','none','buttondownfcn',...
%     'marker(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'userdata',ud,...
%     'FaceLighting','gouraud','createfcn','marker(''createfcn'')','clipping','off');
% mark(finddobj('frame','number'));

function loadc3d(filename)
r = readc3d(filename);
[v,a] = listchannelc3d(r);
if ~isempty(intersect(v,{'PELO'})) && ~isempty(findobj(finddobj('props'),'tag','Pelvis'))
    props('plugin gait',r);
end
props('load analog c3d',r);
    
v = setdiff(v,plugingaitchannels);
indx = listdlg('liststring',v);
v = v(indx);
for i = 1:length(v)
    xyz = getchannelc3d(r,v{i},'all');
    dis = clean(xyz);
    tg = v{i};
    createmarker(tg,1.5,dis,newcolor(i));
end
    
   
function loadzoo(filename)
data = load(filename,'-mat');
data = data.data;
%v = data.zoosystem.Video;
v = setdiff(fieldnames(data),'zoosystem'); %phil edit. This allows for new channels
if ~isempty(intersect(v,{'PELO'})) && ~isempty(findobj(finddobj('props'),'tag','Pelvis'))
    props('zoo plugin gait',data);
end
props('load analog zoo',data);
    
indx = listdlg('liststring',v,'PromptString','add markers','name','add markers');
v = v(indx);
for i = 1:length(v)
    xyz = data.(v{i}).line;
    dis = clean(xyz);
    tg = v{i};
    createmarker(tg,1.5,dis,newcolor(i));
end


% Phil edit 12.2010
% you can plot any channel you want as long as it is n x 1 vector
% a=[];
% if isfield(data.zoosystem,'Analog');
% a = data.zoosystem.Analog;
% end



a = {};
cha = setdiff(fieldnames(data),'zoosystem')';

for i = 1:length(cha)
     [r,c] = size(data.(cha{i}).line);
     if c ==1
         a = [a ; char(cha{i})];
     end
end

if ~isempty(a)

indx = listdlg('liststring',a,'PromptString','plot data','name','plot data');
a = a(indx);
for i = 1:length(a)
    yd = data.(a{i}).line;
    nm = a{i};
    grips('data graph',yd,nm,newcolor(i));
end
end

function loadz3d(filename)
r = load(filename,'-mat');
fld = fieldnames(r.data);
for i = 1:length(fld)
    tg = fld{i};
    if ~isfield(r.data.(tg),'line')
        continue
    end
    dis = r.data.(tg).line;    
    createmarker(tg,1.5,dis,newcolor(i));
end



function buttondownfxn
switch getbdownfxn
    case 'del vertex'
        delete(gco);
end


function r = clean(xyz)
r = xyz/10;
indx = find(xyz==0);
a = zeros(size(xyz));
a(indx) = 1;
indx = find(sum(a')==3);
r(indx,:) = NaN;

function mark(frm)
mrk = finddobj('marker');
for i = 1:length(mrk)
    mud = get(mrk(i),'userdata');
    indx = min(max(1,frm),length(mud.dis(:,1)));    
    dis = mud.dis(indx,:);
    vr = displace(mud.vertices,dis);
    set(mrk(i),'vertices',vr);
end
    
function r = getbdownfxn
hnd = findobj(findobj(finddobj('figure'),'tag','bdownfxns'),'value',1);

if isempty(hnd)
    r = 'nothing';   
else
    r = get(hnd,'string');
end
    
