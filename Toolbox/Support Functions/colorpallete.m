function varargout = colorpallete(action,varargin);

if isnumeric(action)
    defclr = action;
    action = 'start';
end
switch action
case 'start'
    ss = screensize('centimeters');
    ss = ss/2;
    fig = figure('units','centimeters','position',[ss(3)-4 ss(4)-2 8.5 4],'color',[.8 .8 .8],...
        'resize','off',...
        'numbertitle','off',...
        'menubar','none',...
        'doublebuffer','on',...
        'name','color');    
    pb = uicontrol('style','pushbutton','units','centimeters','position',[3 .1 2 1],'backgroundcolor',defclr,'callback','colorpallete(''pushbutton'')','string','done');
    rax = axes('units','centimeters','tag','red','position',[.5 1.2 7 .5],'color',[.2 0 0],'xtick',[],'ytick',[],...
        'box','on','xcolor',[1 0 0],'ycolor',[1 0 0],'buttondownfcn','colorpallete(''red'')','xlim',[0 1]);
    line('parent',rax,'xdata',[defclr(1) defclr(1)],'ydata',[0 1],'linewidth',2,'buttondownfcn','colorpallete(''red'')','color',[1 0 0]);
    text('parent',rax,'units','normalized','position',[1 .5],'horizontalalignment','left','verticalalignment','middle','tag','number','color',[1 0 0],'string',num2str(defclr(1),'%1.2f'));
    gax = axes('units','centimeters','tag','green','position',[.5 1.8 7 .5],'color',[0 .2 0],'xtick',[],'ytick',[],...
        'box','on','xcolor',[0 1 0],'ycolor',[0 1 0],'buttondownfcn','colorpallete(''green'')','xlim',[0 1]);
    line('parent',gax,'xdata',[defclr(2) defclr(2)],'ydata',[0 1],'linewidth',2,'buttondownfcn','colorpallete(''green'')','color',[0 1 0]);
    text('parent',gax,'units','normalized','position',[1 .5],'horizontalalignment','left','verticalalignment','middle','tag','number','color',[0 1 0],'string',num2str(defclr(2),'%1.2f'));    
    bax = axes('units','centimeters','tag','blue','position',[.5 2.4 7 .5],'color',[0 0 .2],'xtick',[],'ytick',[],...
        'box','on','xcolor',[0 0 1],'ycolor',[0 0 1],'buttondownfcn','colorpallete(''blue'')','xlim',[0 1]);
    line('parent',bax,'xdata',[defclr(3) defclr(3)],'ydata',[0 1],'linewidth',2,'buttondownfcn','colorpallete(''blue'')','color',[0 0 1]);
    text('parent',bax,'units','normalized','position',[1 .5],'horizontalalignment','left','verticalalignment','middle','tag','number','color',[0 0 1],'string',num2str(defclr(3),'%1.2f'));    
    waitfor(pb,'string','exit');
    varargout{1} = get(pb,'backgroundcolor');
    delete(fig);
case 'red'
    state = uisuspend(gcf);
    curpt = get(gca,'currentpoint');
    curpt = curpt(1);
    curpt = max(min(curpt,1),0);    
    pb = findobj(gcf,'style','pushbutton');
    clr = get(pb,'backgroundcolor');
    ln = findobj(gca,'type','line');
    set(ln,'xdata',[curpt,curpt]);
    set(pb,'backgroundcolor',[curpt,clr(2:3)]);
    set(gcf,'windowbuttonmotionfcn','colorpallete(''motion'',1)');
    set(gcf,'windowbuttonupfcn','uiresume');
    uiwait
    uirestore(state);
case 'green'
    state = uisuspend(gcf);    
    curpt = get(gca,'currentpoint');
    curpt = curpt(1);
    curpt = max(min(curpt,1),0);    
    pb = findobj(gcf,'style','pushbutton');
    clr = get(pb,'backgroundcolor');
    ln = findobj(gca,'type','line');
    set(ln,'xdata',[curpt,curpt]);
    
    set(pb,'backgroundcolor',[clr(1),curpt,clr(3)]);
    set(gcf,'windowbuttonmotionfcn','colorpallete(''motion'',2)');
    set(gcf,'windowbuttonupfcn','uiresume');
    uiwait
    uirestore(state);
    
case 'blue'
    state = uisuspend(gcf);    
    curpt = get(gca,'currentpoint');
    curpt = curpt(1);
    curpt = max(min(curpt,1),0);
    pb = findobj(gcf,'style','pushbutton');
    clr = get(pb,'backgroundcolor');
    ln = findobj(gca,'type','line');
    set(ln,'xdata',[curpt,curpt]);
    
    set(pb,'backgroundcolor',[clr(1:2),curpt]);
    set(gcf,'windowbuttonmotionfcn','colorpallete(''motion'',3)');
    set(gcf,'windowbuttonupfcn','uiresume');
    uiwait
    uirestore(state);
    
case 'motion'
    curpt = get(gca,'currentpoint');
    curpt = curpt(1);
    curpt = max(min(curpt,1),0);    
    pb = findobj(gcf,'style','pushbutton');
    clr = get(pb,'backgroundcolor');
    ln = findobj(gca,'type','line');
    set(ln,'xdata',[curpt,curpt]);
    clr(varargin{1})=curpt;
    set(pb,'backgroundcolor',clr);
    tx = findobj(gca,'type','text');
    set(tx,'string',num2str(curpt,'%1.2f'));
case 'pushbutton'
    set(gcbo,'string','exit');
    
end
        