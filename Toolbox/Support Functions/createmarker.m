function r = createmarker(nm,sz,dis,clr)

% ARGUMENTS
%  nm   ... name of marker
%  sz   ... size of marker
%  dis  ... n x 3 vector. Position of marker through time
%  clr  ... the color of the new marker


[x,y,z] = sphere(15); % generates a sphere
x = (x*sz/2);   % changes size
y = (y*sz/2);
z = (z*sz/2);

[vr,fc] = surface2patch(x,y,z);
ud.vertices = vr;
ud.faces = fc;
ud.color = clr;
ud.dis = dis;
ud.size = sz;
ax = finddobj('axes');

r = patch('parent',ax,'tag',nm,'facecolor',ud.color,'edgecolor','none','buttondownfcn',...
    'marker(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'userdata',ud,...
    'FaceLighting','gouraud','createfcn','marker(''createfcn'')','clipping','off');
mark(finddobj('frame','number'));



function mark(frm)
mrk = finddobj('marker');  % custom findobj function
for i = 1:length(mrk)
    mud = get(mrk(i),'userdata');
    indx = min(max(1,frm),length(mud.dis(:,1)));    
    dis = mud.dis(indx,:);
    vr = displace(mud.vertices,dis);
    set(mrk(i),'vertices',vr);
end