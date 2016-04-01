function r = associatedlg(action,fld1,fld2)

% Main dialog box interface used by ensembler
%
% Created by JJ Loh 2006
%
% Updated by Philippe C. Dixon March 2016
% - improved sizing (larger fonts and box)


% Set Parameters
FigColor =  [.8 .8 .8];
BgColor = [0 0 0];
FgColor = [1 1 0];   % original [1 1 0]
Settings.FontSize = 14;

if iscell(action)
    if nargin ==3
        nm = fld2;
    else
        nm = 'associate dialog';
    end
    fld2 = fld1;
    fld1 = action;    
    action = 'start';
end

switch action
    
    case 'start'
        ss = screensize('centimeters');
        midpt = ss(3:4)/2;
        fsize = [24 12];            % total figure
        spos = [.1 .1 6 9.8];
        asize = [8 10];             % middle
        okbutt = [.1 .5 1 1];
        but = [0.7 0.7]; % arrow button size
        fig = figure('units','centimeter','position',[midpt(1)-fsize(1)/2 midpt(2)-fsize(2)/2 fsize(1) fsize(2)],'color',FigColor,...
                     'menubar','none','name','associate','closerequestfcn','associatedlg(''exit'')','numbertitle','off','name',nm);
        uicontrol('style','listbox','units','centimeter','position',spos,'tag','source1',...
                  'string',fld1,'backgroundcolor',BgColor,'foregroundcolor',FgColor,'FontSize',Settings.FontSize);
        uicontrol('style','listbox','units','centimeter','position',[fsize(1)-spos(1)-spos(3) spos(2) spos(3:4) ],...
                  'tag','source2','string',fld2,'backgroundcolor',BgColor,'foregroundcolor',[0 1 0],'FontSize',Settings.FontSize);
        uicontrol('style','pushbutton','units','centimeters','position',[spos(1)+spos(3)+0.2 fsize(2)/2-.25 but],...
                  'string','>>','callback','associatedlg(''transfer'')','tag','source1');
        uicontrol('style','pushbutton','units','centimeters','position',[fsize(1)-spos(1)-spos(3)-0.2-0.7,fsize(2)/2-.25 but],...
                  'string','<<','callback','associatedlg(''transfer'')','tag','source2');
        ax = axes('parent',fig,'units','centimeters','position',[fsize(1)/2-asize(1)/2 0 asize],'box','on',...
                  'xtick',[],'ytick',[],'box','on','tag','mainaxes','ylim',[-fsize(2)/2 fsize(2)/2],'xlim',[-1 1],...
                  'color',[0 0 0],'buttondownfcn','associatedlg(''buttondown'')');
        ok = uicontrol('style','pushbutton','units','centimeters','position',...
                       [fsize(1)-spos(1)-spos(3)-okbutt(1)-okbutt(3) okbutt(2:4)],'callback','delete(gcbo)','tag','ok','string','OK');
%         auto = uicontrol('style','pushbutton','units','centimeters','position',...
%                          [fsize(1)-spos(1)-spos(3) okbutt(2:4)],'callback','delete(gcbo)','tag','ok','string','OK');

        vr = [-1 -.3;1 -.3;1 .25;-1 .25];
        fc = [1 2 3 4];
        patch('parent',ax,'tag','target','vertices',vr,'faces',fc,'edgecolor',[1 0 0],...
              'facecolor','none','buttondownfcn','associatedlg(''buttondown'')');
        waitfor(ok)
        r = gatherdata;
        delete(gcf);
    case 'test'
        r = gatherdata;
    case 'exit'
        delete(findobj(gcf,'type','uicontrol','tag','ok'));
    case 'transfer'
        src = get(gcbo,'tag');
        srlist = findobj(gcf,'tag',src,'style','listbox');
        vl = get(srlist,'value');
        str = get(srlist,'string');
        el = str{vl};
        if vl+1 <=length(str)
            vl = vl+1;
        end
        cel = getelement;
        switch src;
            case 'source1'
                cel{1} = el;
            case 'source2'
                cel{2} = el;
        end
        setelement(cel,Settings);
        recenter;
        nextposition;
        set(srlist,'value',vl);
    case 'buttondown'
        state = uisuspend(gcf);        
        set(gcf,'windowbuttonmotionfcn','associatedlg(''motion'')');
        set(gcf,'windowbuttonupfcn','uiresume');
        set(gca,'userdata',get(gca,'currentpoint'));
        uiwait;
        uirestore(state);
    case 'motion'
        delta = get(gca,'userdata');
        curpt = get(gca,'currentpoint');
        delta = curpt-delta;
        set(gca,'userdata',curpt);
        txt = findobj(gca,'type','text','tag','elements');
        offsettext(txt,delta(1,2));        
end

function r = getelement
r = targetelementhandle;
r{1} = get(r{1},'string');
r{2} = get(r{2},'string');

function setelement(cl,Settings)
hnd = targetelementhandle;
if isempty(hnd{1})
    hnd = createelement;
end

s = fieldnames(Settings);

set(hnd{1},'string',cl{1});
set(hnd{2},'string',cl{2});

for i = 1:length(s)
    set(hnd{1},s{i},Settings.(s{i}));
    set(hnd{2},s{i},Settings.(s{i}));
end

function r = targetelementhandle
trg = findobj(gcf,'type','patch','tag','target');

pos = get(trg,'vertices');
ax = findobj(gcf,'type','axes','tag','mainaxes');
txt = findobj(ax,'type','text','tag','elements');

if isempty(txt)
    r = {[],[]};
    return
end

ylim = [min(pos(:,2)),max(pos(:,2))];

tpos = get(txt,'position');
tpos = cell2mat(tpos);
indx = find(tpos(:,2)>ylim(1) & tpos(:,2)<ylim(2));

if isempty(indx)
    r = {[],[]};
    return
end

txt = txt(indx);
r = {findobj(txt,'horizontalalignment','right'),findobj(txt,'horizontalalignment','left')};

function adjustelements

txt = findobj(gcf,'type','text','tag','elements');

if isempty(txt)
    return
end
trg = targetelementhandle;

if verLessThan('matlab','8.4.0')         % execute code for R2014a or earlier
    txt = setdiff(txt,cell2mat(trg));
else                                     % execute code for R2014b or later
    
end

   
if isempty(txt)
    return
end

tpos = get(trg{1},'position');
tpos = tpos(2);
tpch = findobj(gcf,'type','patch','tag','target');
tdis = get(tpch,'vertices');
tdis = max(tdis(:,2))-min(tdis(:,2));

otpos = cell2mat(get(txt,'position'));
ylim = [min(otpos(:,2)) max(otpos(:,2))];
if ylim(2)< tpos;
    delta = tpos-tdis-ylim(2);
elseif ylim(1)>tpos
    delta = tpos+tdis-ylim(1);
else
    return
end

for i = 1:length(txt)
    pos = get(txt(i),'position');
    pos(2)=pos(2)+delta;
    set(txt(i),'position',pos);
end
      
function hnd = createelement

tpch = findobj(gcf,'type','patch','tag','target');
tpos = get(tpch,'vertices');
tpos = mean(tpos(:,2));

t1 = text('string','','position',[-.1 tpos],'horizontalalignment','right','verticalalignment','middle','color',[1 1 0],'tag','elements','buttondownfcn','associatedlg(''buttondown'')');
t2 = text('string','','position',[.1 tpos],'horizontalalignment','left','verticalalignment','middle','color',[0 1 0],'userdata',t1,'tag','elements','buttondownfcn','associatedlg(''buttondown'')');
set(t1,'userdata',t2);
adjustelements;
hnd = {t1,t2};

function offsettext(txt,delta)
for i = 1:length(txt);
    pos = get(txt(i),'position');
    pos(2) = pos(2)+ delta;
    set(txt(i),'position',pos);
end

function recenter
trg = targetelementhandle;
if isempty(trg{1})
    return
end
tpos = get(trg{1},'position');
tpch = findobj(gcf,'type','patch','tag','target');
npos = get(tpch,'vertices');
npos = mean(npos(:,2));
delta = npos-tpos(2);
offsettext(findobj(gca,'tag','elements','type','text'),delta);

function nextposition
txt = findobj(gca,'type','text','tag','elements');
tpch = findobj(gcf,'type','patch','tag','target');
tpos = get(tpch,'vertices');
tdis = max(tpos(:,2))-min(tpos(:,2));
offsettext(txt,tdis);

function r = gatherdata

txt = findobj(gca,'type','text','tag','elements','horizontalalignment','right');
pos = get(txt,'position');
if isempty(pos)
    r = [];    
    return
elseif iscell(pos);
    pos = cell2mat(pos);
    pos= [pos(:,2),(1:length(pos(:,1)))'];
    pos = sortrows(pos,1);
    pos = flipud(pos);
else    
    pos = [pos(2),1];
end
r = [];
for i = 1:length(pos(:,1));
    indx = pos(i,2);
    thnd = txt(indx);
    plate = {get(thnd,'string'),get(get(thnd,'userdata'),'string')};
    r = [r;plate];
end

    
