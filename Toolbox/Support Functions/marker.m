function varargout = marker(action,varargin)

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
    case 'create'
        %createmarker(name,size,position,color)
        varargout{1} = createmarker(varargin{1},varargin{2},varargin{3},varargin{4});
        
    case 'load c3d'
        delete(finddobj('marker'));
        data = loadc3d(varargin{1});
        props('refresh');
        varargout{1} = data;
        
    case 'load z3d'
        delete(finddobj('marker'));
        loadz3d(varargin{1});
        props('refresh');
        
    case 'load zoo'
        delete(finddobj('marker'));
        data = loadzoo(varargin{1});
        props('refresh');
        varargout{1} = data;

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

function r = createmarker(nm,sz,pos,clr)
[x,y,z] = sphere(15);
x = (x*sz/2);
y = (y*sz/2);
z = (z*sz/2);

[vr,fc] = surface2patch(x,y,z);
ud.vertices = vr;
ud.faces = fc;
ud.color = clr;
ud.dis = pos;
ud.size = sz;
ax = finddobj('axes');

r = patch('parent',ax,'tag',nm,'facecolor',ud.color,'edgecolor','none','buttondownfcn',...
    'marker(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'userdata',ud,...
    'FaceLighting','gouraud','createfcn','marker(''createfcn'')','clipping','off');
mark(finddobj('frame','number'));

% function loadc3d(filename)   % ORIGINAL
% 
% % r = readc3d(filename)% 
% 
% [v,a] = listchannelc3d(r);
% if ~isempty(intersect(v,{'PELO'})) && ~isempty(findobj(finddobj('props'),'tag','Pelvis'))
%     props('plugin gait',r);
% end
% props('load analog c3d',r);
%     
% v = setdiff(v,plugingaitchannels);
% indx = listdlg('liststring',v);
% v = v(indx);
% for i = 1:length(v)
%     xyz = getchannelc3d(r,v{i},'all');
%     dis = clean(xyz);
%     tg = v{i};
%     createmarker(tg,1.5,dis,newcolor(i));
% end

function data = loadc3d(filename)

data = c3d2zoo(filename);


ch = data.zoosystem.Video.Channels; % all channels are loaded

if ~isempty(intersect(ch,{'PELO'})) && ~isempty(findobj(finddobj('props'),'tag','Pelvis'))
    props('zoo plugin gait',data);
end

if ismember('Fx1',data.zoosystem.Analog.Channels)    
    props('load analog zoo',data);  % inserts force plates
end

v = cell(size(ch));

for i = 1:length(ch)
    
    if ~isin(ch{i},{'x1','y1','z1','x2','y2','z2','Force','Moment','Angle','Power'}) 
        v{i} = ch{i};
    end
    
end

v(cellfun(@isempty,v)) = [];   


indx = listdlg('liststring',v,'PromptString','add markers','name','add markers');
v = v(indx);
for i = 1:length(v)
    xyz = data.(v{i}).line;
    dis = clean(xyz);
    tg = v{i};
    createmarker(tg,1.5,dis,newcolor(i));
end
   


function data = loadzoo(filename)

data = zload(filename);

ch = data.zoosystem.Video.Channels; % all channels are loaded

if ~isempty(intersect(ch,{'PELO'})) && ~isempty(findobj(finddobj('props'),'tag','Pelvis'))
    props('zoo plugin gait',data);
end

if ismember('Fx1',data.zoosystem.Analog.Channels)    
    props('load analog zoo',data);  % inserts force plates
end

v = cell(size(ch));

for i = 1:length(ch)
    
    if ~isin(ch{i},{'x1','y1','z1','x2','y2','z2','Force','Moment','Angle','Power'}) 
        v{i} = ch{i};
    end
    
end

v(cellfun(@isempty,v)) = [];   


indx = listdlg('liststring',v,'PromptString','add markers','name','add markers');
v = v(indx);
for i = 1:length(v)
    xyz = data.(v{i}).line;
    dis = clean(xyz);
    tg = v{i};
    createmarker(tg,1.5,dis,newcolor(i));
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
    
