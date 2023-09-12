function startup_ensembler(nm,nrows,ncols,xwid,ywid,xspace,yspace,fw,fh,...
    i,nfigs,FontName,FontSize,units,msgbox_space,opening_msg)

% STARTUP_ENSEMBLER initializes the GUI labels


% Revision History
%
% Updated Feb 2017 by Philippe C. Dixon
% - possibility to set font type and size from original ensembler prompt
% - axes resize automatically if user changes size of figure
%
% Updated May 2017 by Philippe C. Dixon
% - Bug fix for users of legacy Matlab version < r2014b ('8.4.0')
%
% Updated Aug 2017 by Philippe C. Dixon
% - A new message box feature allows user to receive feedback directly in ensembler



if nargin < 10
    i = 1;
    nfigs = 1;
    FontName = 'Arial'; % default axis font
    FontSize = 14;      % default axis font size
    units = 'inches';   % default units for ensembler
    msgbox_space = 1.25;
    opening_msg = '';
end

mult = 1; % label font size multiplier

fig = figure('name',nm,'units',units,'position',[0 0 fw fh],'menubar','none',...
    'numbertitle','off','keypressfcn','ensembler(''keypress'')',...
     'Resize','off');

if i == nfigs % only the master gets uimenu
    
    mn = uimenu(gcf,'label','File');
    uimenu(mn,'label','set working directory','callback','ensembler(''set working directory'')','separator','on');
    uimenu(mn,'label','load data','callback','ensembler(''load data'')','separator','on');
    uimenu(mn,'label','load single file','callback','ensembler(''load single file'')');
    uimenu(mn,'label','save fig','callback','ensembler(''save fig'')','separator','on');
    uimenu(mn,'label','export','callback','ensembler(''export'')');
    %uimenu(mn,'label','export event data','callback','ensembler(''export event data'')');
    uimenu(mn,'label','exit','callback','ensembler(''exit'')','separator','on');
    uimenu(mn,'label','restart','callback','ensembler(''restart'')');

    mn = uimenu(gcf,'label','Edit');
    uimenu(mn,'label','edit fig names','callback','ensembler(''edit fig names'')');
    uimenu(mn,'label','decrease fonts','callback','ensembler(''decrease fonts'')','separator','on');
    uimenu(mn,'label','increase fonts','callback','ensembler(''increase fonts'')');
    uimenu(mn,'label','property editor on','callback','ensembler(''property editor on'')','separator','on');
    uimenu(mn,'label','property editor off','callback','ensembler(''property editor off'')');
    uimenu(mn,'label','resize','callback','ensembler(''resize'')');
    %uimenu(mn,'label','quickedit','callback','ensembler(''quickedit'')','separator','on');
    
    % uimenu(mn,'label','datacursormode off','callback','ensembler(''datacursormode off'')','separator','on');
    
    mn = uimenu(gcf,'label','Ensembler');
    uimenu(mn,'label','ensemble (SD)','callback','ensembler(''ensemble data (SD)'')');
    uimenu(mn,'label','ensemble (CI)','callback','ensembler(''ensemble data (CI)'')');
    uimenu(mn,'label','ensemble (CB)','callback','ensembler(''ensemble data (CB)'')');
    uimenu(mn,'label','ensemble (subject x conditon) (SD)','callback','ensembler(''ensemble (subject x conditon) (SD)'')','separator','on');
    uimenu(mn,'label','ensemble (subject x conditon) (CI)','callback','ensembler(''ensemble (subject x conditon) (CI)'')');
    uimenu(mn,'label','combine data','callback','ensembler(''combine'')','separator','on');
    uimenu(mn,'label','combine all','callback','ensembler(''combine custom'')');
    uimenu(mn,'label','combine within','callback','ensembler(''combine within'')');
    uimenu(mn,'label','clear outliers','callback','ensembler(''clear outliers'')','separator','on');
    uimenu(mn,'label','clear all','callback','ensembler(''clear all'')');
    
    mn = uimenu(gcf,'label','Insert');
    uimenu(mn,'label','title','callback','ensembler(''title'')');
    uimenu(mn,'label','axis ids (a,b,c,...)','callback','ensembler(''axisid'')');
    uimenu(mn,'label','sig diff star','callback','ensembler(''sig diff star'')');
    uimenu(mn,'label','legend','callback','ensembler(''legend'')','separator','on');
    uimenu(mn,'label','legend within','callback','ensembler(''legend within'')');
    uimenu(mn,'label','horizontal line','callback','ensembler(''horizontal line'')','separator','on');
    uimenu(mn,'label','vertical line','callback','ensembler(''vertical line'')');
    uimenu(mn,'label','normative PiG Kinematics','callback','ensembler(''normative PiG Kinematics'')','separator','on');
    uimenu(mn,'label','normative PiG Kinetics','callback','ensembler(''normative PiG Kinetics'')');
    uimenu(mn,'label','normative OFM Angles','callback','ensembler(''normative OFM Kinematics'')');
    uimenu(mn,'label','normative EMG','callback','ensembler(''normative EMG'')');
    
    mn = uimenu(gcf,'label','Axes');
    uimenu(mn,'label','re-tag','callback','ensembler(''retag'')');
    uimenu(mn,'label','xlabel','callback','ensembler(''xlabel'')','separator','on');
    uimenu(mn,'label','ylabel','callback','ensembler(''ylabel'')');
    uimenu(mn,'label','x limit','callback','ensembler(''xlimit'')','separator','on');
    uimenu(mn,'label','y limit','callback','ensembler(''ylimit'')');
    uimenu(mn,'label','x ticks','callback','ensembler(''xticks'')');
    uimenu(mn,'label','y ticks','callback','ensembler(''yticks'')');
    uimenu(mn,'label','axis font size','callback','ensembler(''axis font size'')','separator','on');
    uimenu(mn,'label','resize axis','callback','ensembler(''resize axis'')');
    uimenu(mn,'label','delete single axis','callback','ensembler(''delete single axis'')','separator','on');
    uimenu(mn,'label','clear all empty axes','callback','ensembler(''clear all empty axes'')');
    uimenu(mn,'label','clear titles','callback','ensembler(''clear titles'')');
    uimenu(mn,'label','clear prompt','callback','ensembler(''clear prompt'')');
    
    mn = uimenu(gcf,'label','Line');
    uimenu(mn,'label','line graph','callback','ensembler(''line graph'')');
    uimenu(mn,'label','line style','callback','ensembler(''line style'')');
    uimenu(mn,'label','line style within','callback','ensembler(''line style within'')');
    uimenu(mn,'label','line width','callback','ensembler(''line width'')');
    uimenu(mn,'label','line color','callback','ensembler(''line color'')');
    uimenu(mn,'label','line color within','callback','ensembler(''line color within'')');
    uimenu(mn,'label','quick style','callback','ensembler(''quick style'')','separator','on');
    
    mn = uimenu(gcf,'label','Bar Graph');
    uimenu(mn,'label','violin graph','callback','ensembler(''violin graph'')');
    uimenu(mn,'label','box whisker','callback','ensembler(''box whisker'')');
    uimenu(mn,'label','bar graph','callback','ensembler(''bar graph'')');
    uimenu(mn,'label','bar color','callback','ensembler(''bar color'')');
    uimenu(mn,'label','reorder bars','callback','ensembler(''reorder bars'')');
    
    mn = uimenu(gcf,'label','Stdev');
    uimenu(mn,'label','visible','callback','ensembler(''std on off'')');
    uimenu(mn,'label','transparency','callback','ensembler(''std shade'')');
    uimenu(mn,'label','stdline','callback','ensembler(''stdline'')');
    uimenu(mn,'label','stcolor','callback','ensembler(''stdcolor'')');
    uimenu(mn,'label','stcolor within','callback','ensembler(''stdcolor within'')');
    
    mn = uimenu(gcf,'label','Events');
    uimenu(mn,'label','clear all events','callback','ensembler(''clear all events'')');
    uimenu(mn,'label','clear event by type','callback','ensembler(''clear event by type'')');
    uimenu(mn,'label','delete all events','callback','ensembler(''delete all events'')','separator','on');
    uimenu(mn,'label','delete event by type','callback','ensembler(''delete event by type'')');
    uimenu(mn,'label','delete single event','callback','ensembler(''delete single event'')');
    uimenu(mn,'label','add other channel event','callback','ensembler(''add other channel event'')','separator','on');
    % uimenu(mn,'label','add manual event','callback','ensembler(''add manual event'')','separator','on');
    uimenu(mn,'label','add max event','callback','ensembler(''add max event'')','separator','on');
    uimenu(mn,'label','add min event','callback','ensembler(''add min event'')');
    uimenu(mn,'label','add ROM event','callback','ensembler(''add ROM event'')');
    uimenu(mn,'label','add gait events','callback','ensembler(''add gait events'')','separator','on');
    
    mn = uimenu(gcf,'label','Zoom');
    uimenu(mn,'label','zoom on','callback','ensembler(''zoom on'')');
    uimenu(mn,'label','zoom off','callback','ensembler(''zoom off'')');
    uimenu(mn,'label','zoom restore','callback','ensembler(''zoom restore'')');
    
    mn = uimenu(gcf,'label','Processing');
    uimenu(mn,'label','convert to zoo','callback','ensembler(''convert to zoo'')');
    uimenu(mn,'label','explode channels','callback','ensembler(''explode channels'')');
    uimenu(mn,'label','partition','callback','ensembler(''partition'')');
    uimenu(mn,'label','normalize','callback','ensembler(''normalize'')');
    uimenu(mn,'label','filter','callback','ensembler(''filter'')','separator','on')
    uimenu(mn,'label','custom','callback','ensembler(''custom'')','separator','on');
    %uimenu(mn,'label','load process record','callback','ensembler(''load process record'')','separator','on');
    %uimenu(mn,'label','run process record','callback','ensembler(''run process record'')');

    mn = uimenu(gcf,'label','Analysis');
    uimenu(mn,'label','coupling angles','callback','ensembler(''coupling angles'')','separator','on');
    uimenu(mn,'label','relative angles','callback','ensembler(''relative phase'')','separator','on');
    uimenu(mn,'label','continuous stats','callback','ensembler(''continuous stats'')','separator','on');
    uimenu(mn,'label','clear colorbars','callback','ensembler(''clear colorbars'')');
    
end


% Creates 'prompt' box where trial info is placed when a line is clicked
%
% uicontrol('units',units,'style','text','position',[0 fpos(4)-.25 fpos(3) .25],'tag',...
%     'prompt','backgroundcolor',get(gcf,'color'),'FontSize',FontSize);


fpos = get(fig,'position');

xvec = getspacing(ncols,xwid,xspace,fpos(3));
yvec = getspacing(nrows,ywid,yspace,fpos(4));
lyvec = length(yvec);

% resize figure to make space for msg box
%
set(fig,'position',[fpos(1:3)  fpos(4)+msgbox_space]);

for x = 1:length(xvec)
    for y = 1:length(yvec)
        xpos = (x-1)*xwid+sum(xvec(1:x));
        ypos = (y-1)*ywid+sum(yvec(1:y))+msgbox_space;
        
        %row & column number
        cnum = mod(x,length(xvec));
        rnum = mod(y,length(yvec));
        if rnum == 0
            rnum = length(yvec);
        end
        if cnum == 0
            cnum = length(xvec);
        end
        
        if verLessThan('matlab','8.4.0') % legacy fix, less customization
            ax = axes('units',units,'position',[xpos,ypos,xwid,ywid],'tag',...
                num2str([lyvec-rnum+1 cnum]),'box','on','userdata',...
                [rnum,cnum],'buttondownfcn','ensembler(''buttondown'')',...
                'FontName',FontName,'FontSize',FontSize);
        else
            ax = axes('units',units,'position',[xpos,ypos,xwid,ywid],'tag',...
                num2str([lyvec-rnum+1 cnum]),'box','on','userdata',...
                [rnum,cnum],'buttondownfcn','ensembler(''buttondown'')',...
                'FontName',FontName,'FontSize',FontSize,'LabelFontSizeMultiplier',mult,...
                'TitleFontSizeMultiplier',mult,'TitleFontWeight','bold');
        end
        
        %set(ax,'DataAspectRatio',[1 1 1]) % keep axes square
        % set(ax,'units','normalized')      % auto scales axes
       
        
        hnd = title(ax,get(ax,'tag'));
        set(hnd,'units','normalized','position',[.5 1 0],'horizontalalignment','center',...
            'verticalalignment','bottom');
        
    end
end

% craete prompt box for all
%
fpos = get(fig,'position');
uicontrol('units',units,'style','text','position',[0 fpos(4)-0.25 fpos(3) .25],'tag',...
    'prompt','backgroundcolor',get(gcf,'color'),'FontSize',FontSize);


% Creates a 'messagebox' where user feedback could be placed
%
if i==nfigs
    uicontrol('units',units,'style','text','position',[0 0 fpos(3) msgbox_space],'tag',...
        'messagebox','backgroundcolor',[0.5 0.5 0.5],'FontSize',FontSize,...
        'HorizontalAlignment','Left');
    ensembler_msgbox([],opening_msg)
end
