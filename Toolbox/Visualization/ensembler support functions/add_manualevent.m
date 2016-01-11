
function add_manualevent(ch,r)

if nargin==1
    r={};
end

h=datacursormode;
set(h,'DisplayStyle','window','Enable','on')

hnd = gcf;
pause

if ~isin(computer,'WIN64')
    setWindowOnTop(hnd,'true')
end

hnd = gcf;
dcm_obj=datacursormode(hnd);
info_struct = getCursorInfo(dcm_obj);
position = info_struct.Position;
ln = info_struct.Target;

if isempty(r)
    r = inputdlg('name of event');
end

fl = get(ln,'UserData');
data = load(fl,'-mat');
data = data.data;
data.(ch).event.(char(r)) = [position(1) position(2) 0];

save(fl,'data');

disp('event tagged')
datacursormode off

if ~isin(computer,'WIN64')
    setWindowOnTop(hnd,'false')
end

