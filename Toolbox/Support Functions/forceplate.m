function varargout = forceplate(action,varargin)

switch action
    
    case 'refresh' % FP on top of each other until we refresh
        
        hnd = varargin{1};
        pud = get(hnd,'userdata');
        frm =finddobj('frame','number');
        fplateindx = min(frm,length(pud.ort));
        frm = min(frm,length(pud.fx));
        
        m = [pud.fx pud.fy pud.fz];
        mvec = magnitude(m)*pud.coeff;
        vec = m(frm,:)*pud.coeff;
        mg = mvec(frm);
        vr = pud.arrowvr;
        vr(:,1) = vr(:,1)*mg;
        vr(:,2) = vr(:,2)*mg;
        vr(:,3) = vr(:,3)*mg;
        
        if vec(1) == 0 && vec(2)==0
            tort = gunit;
        else
            tort =  makeunit([cross(vec,[0 0 1]);cross(cross(vec,[0 0 1]),vec);vec]);
        end
        
        vr = ctransform(tort,gunit,vr);
        % vr = displace(vr,pud.arrowdis(frm,:));  % this doesn't work PD Feb 2014
        vr = displace(vr,pud.cop(frm,:));         % new code Feb 2014 (see props.m)
        
        afc = pud.arrowfc;
        if isfield(pud,'XaxisVertices')
            xvr = pud.XaxisVertices;
            yvr = pud.YaxisVertices;
            zvr = pud.ZaxisVertices;
            fc = pud.AxisFaces;
        else
            [xvr,yvr,zvr,fc] = axis;
            pud.XaxisVertices = xvr;
            pud.YaxisVertices = yvr;
            pud.ZaxisVertices = zvr;
            pud.AxisFaces = fc;
            set(hnd,'userdata',pud);
        end
        
        xvr(:,1) = xvr(:,1)*vec(1);
        yvr(:,2) = yvr(:,2)*vec(2);
        zvr(:,3) = zvr(:,3)*vec(3);
        
%         xvr = displace(xvr,[-25.5 -25.5 0]);
%         yvr = displace(yvr,[-25.5 -25.5 0]);
%         zvr = displace(zvr,[-25.5 -25.5 0]);
        clr = abs(mg)/max(abs(mvec));
        [vr,fc,cdata] = mergepatches(vr,afc,[clr .6 0],xvr,fc,[1 0 0],yvr,fc,[0 1 0],zvr,fc,[0 0 1]);
        
         vr = ctransform(pud.ort{fplateindx},gunit,vr);
         vr = displace(vr,pud.dis(fplateindx,:));

        if ishandle(pud.arrowhnd)
            set(pud.arrowhnd,'vertices',vr,'faces',fc,'cdata',cdata);

        else
            pud.arrowhnd = patch('parent',finddobj('axes'),'vertices',vr,'faces',fc,'facecolor','flat','cdata',cdata,'edgecolor','none','facelighting','gouraud','buttondownfcn','','tag','FParrow','facealpha',.99);
            set(hnd,'userdata',pud);
        end
        
        fplatevr = displace(ctransform(pud.ort{fplateindx},gunit,pud.vertices),pud.dis(fplateindx,:)); %new position of FP
        set(hnd,'vertices',fplatevr);
        

        
%         move COP marker
%         hnd = findobj('Tag','COP');
% 
%         if ~isempty(hnd)
%             delete(hnd)
%         end
%         
%         mhnd = createmarker('COP',1.5,pud.cop(frm,:),'m');
        
     
end


function [vr,fc,cdata] = mergepatches(varargin)
vr = varargin{1};
fc = varargin{2};
cplate = varargin{3};
cdata(1:length(fc(:,1)),1,1) = cplate(1);
cdata(1:length(fc(:,1)),1,2) = cplate(2);
cdata(1:length(fc(:,1)),1,3) = cplate(3);

for i = 4:3:nargin
    vplate = varargin{i};
    fplate = varargin{i+1};
    cplate = varargin{i+2};
    
    lvr = length(vr(:,1));
    vr = [vr;vplate];
    fc = [fc;fplate+lvr];
    clr(1:length(fplate(:,1)),1,1) = cplate(1);
    clr(1:length(fplate(:,1)),1,2) = cplate(2);
    clr(1:length(fplate(:,1)),1,3) = cplate(3);
    
    cdata = [cdata;clr];
end

function [xvr,yvr,zvr,fc] = axis

xvec = [0 0 .5];
yvec = [0 0 .5];
zvec = [.5 0 0];

xvr = [];
yvr = [];
zvr = [];
for i = 0:15:345
    xvr = [xvr;vecrotate(xvec,i,'x')];
    yvr = [yvr;vecrotate(yvec,i,'y')];
    zvr = [zvr;vecrotate(zvec,i,'z')];
end
lvr = length(xvr(:,1));
nxvr = xvr;
nxvr(:,1) = 1;
xvr = [xvr;nxvr];

nyvr = yvr;
nyvr(:,2) = 1;
yvr = [yvr;nyvr];

nzvr = zvr;
nzvr(:,3) = 1;
zvr = [zvr;nzvr];

fc = [(1:lvr-1)',(2:lvr)',(lvr+2:2*lvr)',(lvr+1:2*lvr-1)'];

fc = [fc;[lvr 1 lvr+1 2*lvr]];


