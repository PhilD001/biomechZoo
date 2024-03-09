function varargout = propsBones(action,varargin) 


switch action

     case 'goto'
        mark(varargin{1}); % advaces all props to new position
        

case 'load'
        filename = varargin{1};
        t = load(filename,'-mat');
        [f,p] = partitionfile(filename);
        f = extension(f,'');
        

        if strfind(p,'golembones')
            ud = t.object;
            ud.dis = NaN*ud.dis; % removes 'ghost' data from bones
        
        elseif isfield(t.object,'association')|| isfield(t.object,'joint') || isfield(t.object,'vertices')
            ud = t.object;
       
             if strfind(f,'one')
                ud.color = [1 1 1];
             end
            
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
                for i = 1:length(t.object.marker)
                    ud.mvertices = [ud.mvertices;t.object.marker(i).position];
                    ud.mname = [ud.mname,{t.object.marker(i).tag}];
                end
            end
        end
       
        if nargin == 2
            varargout{1} = createprop(ud,f);
        else
            varargout{1} = createprop(ud,varargin{2});
        end


end


function c = createprop(ud,tg)

% places prop at origin
ax = findobj('Type', 'axes', 'Tag', '3Dspace');
%ax = finddobj('axes');
if isfield(ud,'cdata')
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


if isfield(ud,'vertexnormals')
    set(c,'vertexnormals',ud.vertexnormals);
end

if isfield(ud,'mvertices')
    drawmarker(ud.mvertices,ud.mname,c);
end

function mark(frm)
load('objects.mat'); % Chargez la variable objects depuis le fichier MAT
gunit = [1 0 0;0 1 0;0 0 1];
phnd = objects;
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
        
    elseif isfield(pud,'fx')
        forceplate('refresh',phnd(i));
        continue
        
    elseif isfield(pud,'ort') %prop is moves on its own
        if frm > length(pud.ort)
            continue
        end
        vr = ctransform(pud.ort{frm},gunit,pud.vertices);
        vr = displace(vr,pud.dis(frm,:));
        fc = pud.faces;
        nvr = 'none';
        
    else
        continue
    end
    
    if isfield(pud,'units')
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
if nargin == 1
    pud = get(mrk,'userdata');
    vr = pud.mvertices;
    nm = pud.mname;
    as = pud.association(:,1);
    for i = 1:length(as)
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
