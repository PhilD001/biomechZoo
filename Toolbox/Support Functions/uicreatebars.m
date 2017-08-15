function varargout = uicreatebars(varargin);

hi = finddobj('highlight');
if ~actor('verify',hi)
    errordlg('bodypart not selected');
    return
end
ac = get(hi,'tag');
bp = get(hi,'userdata');
if isstruct(bp)
    bp = 'head';
end

[f,p] = uigetfile('*.*','open your file');

if f == 0;
    varargout{1} = [];
    return
end
cd(p);

t = load([p,f],'-mat');
fld = allfieldnames(t);

kw = mylistdlg('name','select bars to create','list',{},'source list',fld);

if isempty(kw);
    varargout{1} = [];
    return
end

ud.fxn = 'bargraph'
ud.data.actor = ac;
ud.data.segment = bp;

for i = 1:length(kw)    
    ud.keywords = kw(i);
    specialobject('create',ud,kw{i});
end
    
