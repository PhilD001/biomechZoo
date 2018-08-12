function director(action,varargin)

% director(action,varargin) is a three-dimensional virtual environment that can be used
% to visualize motion capture data within MatLab. Current version is able to read
% files in which standard Plug-in Gait (lower or full) marker set is used
% and display body using 'bones'. Otherwise, only markers will show
%
%
% NOTES
% - If trials contain force plate data, force plates and ground reaction
%   force vectors (for up to three plates) will appear in the virtual space
% - Additional objects ('props') can be loaded (see 'cinema objects' sub-folder
%   of 'Visualization' folder. Limited functionality currently exists for
%   these additional objects.  User is encouraged to modify or add objects
%   by studying the method used to display force plates
% - Step 3 in the director instructions from the manuscript (appendix C) is
%   automatically done in current version of director

% Revision History
%
% Created by JJ Loh 2005-2007
%
% Updated by Yannick Michaud-Paquette 2013-2014
% - Major improvements to GUI including improved graphing capabilities and the slide bar
%
% Updated by Philippe C. Dixon February 2014
% - Any data can be graphed (Video or Analog).
% - Except for CentreOfMass, markers are expected to be less than 6 characters long
% - Force plate COP and GRF vectors fully functiona
% - Full compatibility with zoosystem v1.2 (no backwards compatibility)
% - c3d files rely on zoo functions. They are loaded as struct and then
%   no longer follow their own processes
%
% Updated by Philippe C. Dixon May 2015
% - Further compatibility with mac platforms added

% Updated by JJ Loh and Philippe C. Dixon May 2015
% - Subjects with footwear can be visualized in director. So far the only footwear type
%   is 'skates'. Subjects with the field data.zoosystem.Anthro.Feet = 'skates' will be
%   rendered wearing 'skates' props (found in ~\the zoosystem\Toolbox\Visualization\Cinema objects\skate)
%   The function bmech_footwear should be run to record the footwear type in the zoo file.
%   Alternatively, the user can add the following code in the 'loadfile' function embedded
%   in 'marker.m' after the loading section (near line 125): data.zoosystem.Anthro.Feet = 'skates'
%   The handling of the prop is performed in the embedded function 'skate'
%   of 'props.m'.
% - New footwear types can be created by following this example
%
% Updated by Philippe C. Dixon March 2016
% - fixed bug with slider mark not updating graph mark (*)
%
% Updated by Philippe C. Dixon May 2017
% - Solved 'stop' button issue (nonresponsive or delayed on certain platforms)
%
% Updated by Philippe C. Dixon Oct 2017
% - fixed axis color code mismatch between global axes and graph window
% - fixed bug where global grid layout disappeared when using graphing
%   window
%
% Updated by Philippe C. Dixon Dec 2017
% - improved usability with 'close file' button
%
% Updated by Philippe C. Dixon April 2018
% - Major improvements to GUI layout including: 
% (1) selectable file tree to choose which markers/graph to display
% (2) normalization of object positionning to improve resizing



global producer;
global p;
global f;
global data;


% default settings
%
xcol = [1 0 0]; % red color for x axis arrow
ycol = [0 1 0]; % green color for y axis arrows
zcol = [0 0 1]; % blue color for z axis arrows
y_baseline = 0.03; % normalized offset from bottom of director for objects
x_baseline = 0.18;

button_col = [18/255 99/255 150/255];  % color from website
panel_col =  [18/255 99/255 150/255]; %[0.90 0.90 0.90];   % gray
lbl_col = 'w';                  % color for graph window text



% Data graph embedded in director window
%
% bkg_col = 'w';         % background color for graph window
%graph_legend = false;  % show a legend for the graph (boolean)

units = 'normalized';
ud = struct;                   % set up user data struct
ud.mark = [];

lbl = (-1000:100:1000);

director_color = [0 0 0];       % color of director background
xlim = [-1000 1000];
ylim = [-1000 1000];
zlim = [0 500];
initial_camera_pos = [200 200 250]*5;

if nargin ==0
    action = 'start director';
end

disp(action)

switch action
    
    case 'start director'
        director('set space')
        director('set ui')
        
    case 'set space'
        [~,phnd] = finddobj('figure');
        if isempty(phnd)
            phnd = figure('tag','space','color',[0 0 0],'name','director','menubar','none','numbertitle','off',...
                'keypressfcn','dkeypress','buttondownfcn','director(''buttondown'')','doublebuffer','on',...
                'units','normalized','resizefcn','director(''resize'')','position',[0.1 0.1 0.8 0.8]);
        end
        
        % create main panel (director space)
        %
        ax = axes('parent',phnd,'units',units,'position',[0 0 1 1],'dataaspectratio',[1 1 1],...
            'color',director_color,'xcolor',[0 0 0],'ycolor',[0 0 0],'zcolor',[0 0 0],'xtick',[],...
            'ytick',[],'ztick',[],'buttondownfcn','cameraman(''buttondown'');','view',[114 25],...
            'visible','on','userdata',ud,'tag','space','cameraviewanglemode','manual','xlim',xlim,...
            'ylim',ylim,'zlim',zlim,'xtickmode','auto','ytickmode','auto','xgrid','off',...
            'ygrid','off','cameraposition',initial_camera_pos,'cameratarget',[0 0 0],'xtick',lbl,...
            'ytick',lbl,'xticklabel',[],'yticklabel',[],'gridlinestyle','-','cameraviewangle',10);
        
        light('position',get(ax,'cameraposition'),'buttondownfcn','cameraman(''buttondown'')',...
            'parent',ax,'tag','camera light','style','local');
        
        xd = [lbl,lbl];
        xd(1:2:end) = lbl;
        xd(2:2:end) = lbl;
        yd = xd;
        yd(1:4:end) = max(lbl);
        yd(2:4:end) = min(lbl);
        yd(3:4:end) = min(lbl);
        yd(4:4:end) = max(lbl);
        
        nyd = [yd,fliplr(xd)];
        nxd = [xd,yd];
        
        line('parent',ax,'xdata',nxd,'ydata',nyd,'zdata',zeros(size(nyd)),'color',[0 0 0],...
            'buttondownfcn','cameraman(''buttondown'');','tag','camera grid');
        
        ax2 = axes('parent',phnd,'unit','normalized','position',[0.75 0.75 .25 .25],'cameraviewangle',...
            40,'cameraposition',[2 2 2],'cameratarget',[0 0 0],'color',[.8 .8 .8],'visible','off','tag','orientation window');
        
        [x,y,z] = arrow([0 0 0],[1 0 0],10);
        surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',xcol,'edgecolor','none','facelighting','gouraud',...
            'tag','x','buttondownfcn','director(''orientation_buttondown'')');
        
        [x,y,z] = arrow([0 0 0],[0 1 0],10);
        surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',ycol,'edgecolor','none','facelighting','gouraud',...
            'tag','y','buttondownfcn','director(''orientation buttondown'')');
        
        [x,y,z] = arrow([0 0 0],[0 0 1],10);
        surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',zcol,'edgecolor','none','facelighting','gouraud',...
            'tag','z','buttondownfcn','director (''orientation buttondown'')');
        
        light('parent',ax2,'position',[3 0 0]);
        director('units load');
        producer.mov = [];
        producer.cut = 0;
        producer.gravity = 1;
        producer.grips = struct;
        director('person','director');
        warning off;
        set(findobj('type','uicontrol'),'units','normalized');
        
    case 'set ui'
        
        [~,phnd]  = finddobj('figure');
        cm = uicontextmenu('tag','main','callback','director(''contextmenu'')');
        
        uicontrol('parent',phnd,'style','pushbutton','units','normalized','backgroundcolor',button_col,'foregroundcolor',[0 0 0],...
            'tag','load zoo','position',[x_baseline y_baseline 0.05 0.05],'string','Load File','callback','director(''open'')');
        uicontrol('parent',phnd,'style','pushbutton','units','normalized','backgroundcolor',button_col,'foregroundcolor',[0 0 0],...
            'tag','load zoo','position',[x_baseline y_baseline 0.05 0.05],'string','Close File','callback','director(''close'')','visible','off');
        uicontrol('parent',phnd,'style','pushbutton','units','normalized','backgroundcolor',button_col,'foregroundcolor',[0 0 0],...
            'tag','first position','position',[x_baseline+0.12 y_baseline 0.08 0.05],'string','First Frame','callback','director(''first position'')','visible','off');
        uicontrol('parent',phnd,'style','pushbutton','units','normalized','backgroundcolor',button_col,'foregroundcolor',[0 0 0],...
            'tag','play','position',[x_baseline+0.06 y_baseline 0.05 0.05],'string','Play','callback','director(''preview'')','visible','off');
        uicontrol('parent',phnd,'style','pushbutton','units','normalized','backgroundcolor',button_col,'foregroundcolor',[0 0 0],...
            'tag','button stop','position',[x_baseline+0.06 y_baseline 0.05 0.05],'string','Stop','callback','director(''button stop'')','visible','off');
        uicontrol('parent',phnd,'style','text','units','normalized','backgroundcolor',button_col,'foregroundcolor',[0 0 0],...
            'tag','frame','position',[x_baseline+0.68 y_baseline 0.035 0.05],'string','1','FontSize',14);
         
        % -----------------    uicontrol turned off ---------------
        uicontrol('parent',phnd,'style','togglebutton','units','normalized','backgroundcolor',button_col,...
            'foregroundcolor',[0 0 0],'tag','displacement','position',[x_baseline+0.72 y_baseline 0.05 0.05],'string','5 cm','userdata',5,...
            'callback','director(''units'')','deletefcn','director(''units delete'')','value',1,'uicontextmenu',cm,'visible','on');
        uicontrol('parent',phnd,'style','togglebutton','units','normalized','backgroundcolor',button_col,...
            'foregroundcolor',[0 0 0],'tag','angle','position',[0.6 0.1 1.2 .5],'string','1 deg','userdata',1,...
            'callback','director(''units'')','deletefcn','director(''units delete'')','uicontextmenu',cm,'visible','off');
        uicontrol('parent',phnd,'style','togglebutton','units','normalized','backgroundcolor',button_col,...
            'foregroundcolor',[0 0 0],'tag','volume','position',[0.9 0.1 1.2 .5],'string','1 cm3','userdata',1,...
            'callback','director(''units'')','deletefcn','director(''units delete'')','uicontextmenu',cm,'visible','off');
       
        % -------------
        
        % view options panel
        %
        panel_hnd =  uipanel('parent',phnd,'Title','File info','FontSize',12,'Tag','spacer',...
            'BackgroundColor',panel_col,'Position',[0 0.9 0.15 0.1]);
        
        uicontrol('parent',panel_hnd,'style','text','units','normalized','backgroundcolor',[1 1 1],'foregroundcolor',[0 0 0],...
            'tag','file info','position',[0.02 0.3 0.9 0.5],'string','none','FontSize',12);
       
        uipanel('parent',phnd,'Title','','FontSize',12,'Tag','options panel',...
            'BackgroundColor','white','Position',[0 0 0.15 0.9]);
        
%         uicontrol('parent',settings_hnd ,'style','pushbutton','units','normalized','backgroundcolor',[0.8 0.8 0.8],'foregroundcolor',[0 0 0],...
%             'tag','data','position',[0.01 0.85 0.2 0.05],'string','data','callback','director(''data tree'')');
        
%         uicontrol('parent',settings_hnd ,'style','text','units','normalized','backgroundcolor',[1 1 1],'foregroundcolor',[0.1 0.1 0.1],...
%             'position',[0.6 0.9 0.2 0.05],'string','Model');
        
%         uicontrol('parent',settings_hnd ,'style','text','units','normalized','backgroundcolor',[1 1 1],'foregroundcolor',[0.1 0.1 0.1],...
%             'position',[0.8 0.9 0.2 0.05],'string','Graph');
        
%         uicontrol('parent',settings_hnd ,'style','checkbox','units','normalized','Position', [0.93 0.97 0.28 0.03],...
%             'callback','director(''toggle settings'')','Value',1)
%         
        
        
    case 'update model'   % used by tabbed director version
        
    case 'save'
        
        switch currentobject
            case 'bargraph'
                bargraphfxn('save');
            case 'internal image'
                grips('save internal image');
            case 'accessory'
                accessoryfxn('save');
            case 'special object'
                specialobject('save');
            case 'props'
                props('save');
        end
        
    case 'clear all objects'
        ax = finddobj('axes');
        delete(findobj(ax,'type','patch'));
        delete(findobj(ax,'type','surface'));
        % director('cleanup')
        
    case 'delete graph'
        
        set(findobj('type','uicontrol','tag','data list'),'Visible','off');
        set(findobj('type','axes','tag','data display'),'Visible','off');
        ln = get(findobj('type','axes','tag','data display'),'Children');
        
        if~isempty(ln)
            delete(ln);
            delete(findobj('tag','graph legend'));
        end
        uicontrol('style','pushbutton','units','centimeters','backgroundcolor',[.1 .1 .1],'foregroundcolor',[1 1 1],...
            'tag','open graph','position',[3.5 .7 3 .5],'string','Open Graph','callback','director(''open graph'')','Visible','on');
        set(findobj('tag','delete graph'),'Visible','off');
        
    case 'open graph'
        
        set(findobj('type','uicontrol','tag','data list'),'Visible','on');
        set(findobj('type','axes','tag','data display'),'Visible','on');
        set(findobj('tag','open graph'),'Visible','off');
        set(findobj('tag','delete graph'),'Visible','on');
        
    case 'close'
        
        % find existing director figure
        %
        fig = finddobj('figure');
        
        patch_hnd = findobj(fig,'type','patch');
        delete(patch_hnd)
        
        set(findobj('tag','first position'),'visible','off')
        set(findobj('tag','play'),'visible','off')
        set(findobj('tag','load zoo','string','Load File'),'visible','on')
        set(findobj('tag','load zoo','string','Close File'),'visible','off')
        set(findobj('type','uicontrol','string',f),'string','none')
        delete(findobj('style','slider'))
        delete(findobj('style','listbox'))
        delete(findobj('tag','data display'))
        
    case 'open'
        [~,phnd] = finddobj('figure');
        director('clear all objects')
        director('load bones');       % loads the bone props
        
        [f,p] = uigetfile({'*.zoo';'*.c3d'},'Pick a file');   % default is c3d or zoo file
        cd(p);
        
        if f == 0
            return
        end
        
        ext = extension(f);
        hnd = [];
        delete(finddobj('graph'));
        
        set(findobj('tag','open graph'),'Visible','off');
        
        switch lower(ext)
            
            case {'.zoo','.c3d'}
                
                data = marker('load file',[p,f]);
             
                video_chns = data.zoosystem.Video.Channels;
                %all_chns = setdiff(fieldnames(data),'zoosystem');
                
                % Attempt to limit marker list to 'true' markers
                %
                %all = cell(size(all_chns));
                
                %for i = 1:length(all_chns)
                %    
                %    if ~isin(all_chns{i},{'star'})
                %         all{i} = all_chns{i};
                %    end
                %    
                % end
                
                % all(cellfun(@isempty,all)) = [];
                % all_chns = all;
                
                % update visibility of play buttons
                %
                set(findobj('tag','first position'),'visible','on')
                set(findobj('tag','play'),'visible','on')
                set(findobj('tag','load zoo','string','Close File'),'visible','on')
                set(findobj('tag','load zoo','string','Load File'),'visible','off')
                
                
                uicontrol('parent',phnd,'style','slider','units','normalized','position',[0.425 y_baseline 0.4 0.025],...
                    'Min',0,'Max',length(data.(video_chns{1}).line),'SliderStep',[1/length(data.(video_chns{1}).line) 10/length(data.(video_chns{1}).line)],'tag','slider','callback',...
                    'director(''slider'')','backgroundcolor',button_col,'foregroundcolor',[0.1 0.1 0.1]);
                
                
                panel_hnd = findobj('type','uipanel','Tag','options panel');

                % Create UI tree
                uitree_director(panel_hnd,data);
                
                % create graph display
                ax = axes('parent',phnd,'units','normalized','position',[0.18 0.15 0.2 0.3],'tag','data display','Color',[0.8 0.8 0.8],'XColor',lbl_col,'YColor',lbl_col);

                
            case '.bmp'
                hnd = grips('image',[p,f]);
            case '.avi'
                hnd = grips('avi',[p,f]);
            case '.ort'
                actor('load orientation',[p,f]);
            case '.body'
                [hnd,f] = actor('create',[p,f]);
            case '.dis'
                actor('load displacement',[p,f]);
            case '.cam'
                cameraman('load',[p,f]);
            case '.iim'
                grips('load internal image',[p,f])
            case '.acs'
                accessoryfxn('load',[p,f]);
            case '.spo'
                costume('load special',[p,f]);
            case '.cos'
                costume('load',[p,f]);
            case '.tool'
                sculpttool('load',[p,f]);
            case '.cdata'
                actor('load cdata',[p,f]);
            case '.grip'
                grips('load',[p,f]);
            case '.light'
                lightman('load',[p,f]);
            case '.prop'
                props('load',[p,f]);
            case '.z3d'
                marker('load z3d',[p,f]);
        end
        
        if ~isempty(hnd)
            set(finddobj('current object'),'string',f);
        end
        %set(gcf,'name',f);
        
        cameraman('new film');
        %director('first position');
        mark('goto',1);
        
        % add name to spacer 
        %
        shnd = findobj('tag','file info');
        set(shnd,'String',f)
        
    case 'data display'        
        %data_list = get(findobj('tag','data list'),'String');
        %ch = data_list{get(findobj('tag','data list'),'Value')};
      
        display_director_graph(data,ch)
      
    case 'resize'
        
        fig = finddobj('figure');
        ax = finddobj('orientation window');
        fpos = get(fig,'position');
        apos = get(ax,'position');
        
        if isempty(apos)
            apos(1) = fpos(3);
            apos(2) = fpos(4);
        else
            apos(1) = fpos(3)-apos(3);
            apos(2) = fpos(4)-apos(4);
        end
        
        set(ax,'position',apos);
        
    case 'reload markers'
        
        marker('load zoo',[p,f])
        
    case 'load bones'
        s = filesep;    % determine slash direction based on computer type
        
        d = which('director'); % returns path to ensemlber
        path = pathname(d) ;  % local folder where director resides
        
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openall(bones);
        
        % director('first position');
        
    case 'multi open'
        
        fld = uigetfolder;
        if isempty(fld)
            return
        end
        cd(fld)
        multiopen(fld)
        
    case 'units'
        
        [unt,all] = finddobj('units');
        set(all,'value',0,'backgroundcolor',[.8 .8 .8]);
        set(gcbo,'value',1,'backgroundcolor',[.9 .9 .9]);
        figure(gcf);
        
    case 'change units'
        
        unt = get(gco,'string');
        indx = findstr(unt,' ');
        unt = unt(indx:end);
        answer = inputdlg(unt,get(gco,'tag'));
        if isempty(answer)
            return
        elseif isempty(answer{1})
            return
        end
        num = str2num(answer{1});
        if isempty(num)
            return
        end
        set(gco,'userdata',num,'string',[num2str(num),unt]);
        
    case 'units delete'
        
        global unitvar
        [~,all] = finddobj('units');
        lvar = length(unitvar)+1;
        
        unitvar(lvar).tag = get(gcbo,'tag');
        unitvar(lvar).userdata = get(gcbo,'userdata');
        unitvar(lvar).string = get(gcbo,'string');
        
        if length(all) == 1
            fl = which('unitmenu.prf');
            save(fl,'unitvar');
            clear global unitvar
        end
        
    case 'units load'
        
        fl = which('unitmenu.prf');
        
        if isempty(fl)
            error('missing unitmenu.prf file')
        end
        
        t = load(fl,'-mat');
        [~,all] = finddobj('units');
        for i = 1:length(t.unitvar)
            obj = findobj(all,'tag',t.unitvar(i).tag);
            set(obj,'userdata',t.unitvar(i).userdata,'string',t.unitvar(i).string);
        end
        
    case 'person'
        
        pt = finddobj('person menu');
        if nargin == 1
            cblb = get(gcbo,'label');
        else
            cblb = varargin{1};
        end
        
        set(pt,'label',cblb);
        menu(cblb);
        
    case 'contextmenu'
        
        delete(get(gcbo,'children'));
        [~,all] = finddobj('units');
        if actor('verify',gco)
            uimenu(gcbo,'label','next','callback','actor(''next sequence'')');
            uimenu(gcbo,'label','prev','callback','actor(''prev sequence'')');
            uimenu(gcbo,'label','load sequence','callback','actor(''load sequence'')');
        elseif ~isempty(intersect(gco,all))
            uimenu(gcbo,'label','change','callback','director(''change units'')');
        end
        
    case 'colorpallete'
        
        if ~isempty(finddobj('colorpallete'))
            delete(finddobj('colorpallete'));
            return
        end
        [tp,hnd] = currentobject;
        
        switch tp
            case 'actor'
                clr = get(hnd(1),'facecolor');
            case 'bargraph'
                clr = get(hnd,'facecolor');
            otherwise
                clr = [.8 .8 .8];
        end
        uicontrol('style','pushbutton','tag','color','units','centimeters','position',[.1 .7 1.5 .5],'backgroundcolor',clr,'callback','director(''color callback'')');
        
    case 'color callback'
        
        clr = colorpallete(get(gcbo,'backgroundcolor'));
        set(finddobj('colorpallete'),'backgroundcolor',clr);
        
    case 'preview'
        
        producer.cut = 0;
        tp = finddobj('top menu');
        set(tp,'enable','off');
        cameraman('new film');
        index = finddobj('frame','number');
        hnd = finddobj('frame');
        
        flength = length(data.zoosystem.Video.Indx);
        av_ratio = data.zoosystem.AVR;
        
        set(findobj('type','uicontrol','tag','button stop'),'visible','on');
        
        %stop_state = false;
        while producer.cut == 0
            
            index = index+1;  % increase step length to speed up
            mark('next',flength,av_ratio);
            set(gcf,'name',['preview: frame ',num2str(index)]);
            set(hnd,'string',num2str(index));
            set(findobj('type','uicontrol','tag','slider'),'Value',index);
            if index >= flength
                producer.cut = 1;
                set(findobj('tag','button stop'),'visible','off');
            end
            pause(0.01)  % needed to allow button stop to stop animation
        end
        
        set(finddobj('top menu'),'enable','on');
        set(gcf,'name','director');
        
    case 'preview cut'
        %set(gcbo,'label','practice','callback','director(''preview'')');
        producer.cut = 1;
        
    case 'button stop'
        set(findobj('type','uicontrol','tag','button stop'),'visible','off');
        producer.cut = 1;
        
    case 'slider'
        index = get(findobj('tag','slider'),'Value');
        
        index = round(index);
        hnd = finddobj('frame');
        set(hnd,'string',num2str(index));
        flength = length(data.zoosystem.Video.Indx);
        av_ratio = data.zoosystem.AVR;
        mark('goto',index,av_ratio,flength);
        
    case 'action'
        producer.cut = 0;
        set(finddobj('top menu'),'enable','off');
        set(gcbo,'label',' cut  ','callback','director(''cut'')','enable','on');
        cameraman('new film');
        uic = findobj(gcf,'type','uicontrol','visible','on');
        set(uic,'visible','off');
        cameraman('record');
        index = 1;
        hnd = finddobj('frame');
        
        while ~producer.cut
            index = index+1;
            mark('next');
            cameraman('record');
            set(gcf,'name',['preview: frame ',num2str(index)]);
            set(hnd,'string',num2str(index));
        end
        
        set(uic,'visible','on');
        set(finddobj('top menu'),'enable','on');
        
    case 'cut'
        set(gcbo,'label','action','callback','director(''action'')');
        producer.cut = 1;
             
    case 'first position'
        cameraman('new film');
        mark('goto',1);
        delete(findobj(finddobj('axes'),'tag','trace'));
        
        if ~isempty(findobj('tag','slider'))
            set(findobj('tag','slider'),'Value',1);
        end
        
    case 'goto'
        mark('goto',varargin{1});
        
    case 'next frame'
        mark('next');
        
    case 'prev frame'
        mark('prev');
        
    case 'cleanup'
        set(gcf,'windowbuttondownfcn','');
        uic = findobj(gcf,'type','uicontextmenu');
        uic = setdiff(uic,finddobj('contextmenu'));
        for i = 1:length(uic)
            set(findobj('uicontextmenu',uic(i)),'uicontextmenu',[]);
            delete(uic(i));
        end
        delete(finddobj('garbage'));
        set(finddobj('actor'),'buttondownfcn','actor(''buttondown'')');
        
    case 'next person'
        nextperson(varargin{1});
        
    case 'next mark'
        mark('next');
        
    case 'prev mark'
        mark('prev');
        
    case 'refresh'
        mark('refresh');
        
    case 'clean object'
        [tp,hnd] = currentobject;
        switch tp
            case 'costume'
                costume('clean',hnd);
        end
        
    case 'gravity'
        
        switch get(gcbo,'checked')
            case 'on'
                set(gcbo,'checked','off');
                producer.gravity = 0;
            case 'off'
                set(gcbo,'checked','on');
                producer.gravity = 1;
        end
        
    case 'orientation buttondown'
        
        tg = get(gcbo,'tag');
        switch get(gcf,'selectiontype')
            case 'alt'
                move(tg,'neg');
            case 'normal'
                move(tg);
        end
        
    case 'goto callback'
        
        frm = inputdlg({'goto frame'},'goto');
        director('goto',str2num(frm{1}));
        delete(findobj(finddobj('axes'),'tag','trace'));
        
end


%===EMBEDDED FUNCTIONS==================================================


function menu(action)

fig = finddobj('figure');
mn = finddobj('person menu');
delete(setdiff(findobj('type','uimenu','parent',fig),mn));
delete(finddobj('controls'));
delete(finddobj('bomb'));
delete(finddobj('costume pointer'));
set(finddobj('actor'),'facealpha',1,'edgecolor','none');
controls(action);

switch action
    case 'director'
        
        if isgravity
            chk = 'on';
        else
            chk = 'off';
        end
        
    case 'cameraman'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','save','callback','cameraman(''save'')');
        mn = uimenu(fig,'label','tools');
        uimenu(mn,'label','make first position','callback','cameraman(''make first position'')');
        uimenu(mn,'label','clear','callback','cameraman(''clear'')');
        uimenu(fig,'label','practice','callback','director(''preview'')');
        uimenu(fig,'label','first position','callback','director(''first position'')');
        set(gcf,'name','cameraman');
        
    case 'actor'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','save displacement','callback','actor(''save displacement'')');
        uimenu(mn,'label','save orientation','callback','actor(''save orientation'')');
        uimenu(mn,'label','save color data','callback','actor(''save cdata'')');
        
        mn = uimenu(fig,'label','filter','callback','filtermenu(''start'')');
        uimenu(mn,'label','orientation','callback','actor(''filter orientation'')');
        uimenu(mn,'label','displacement','callback','actor(''filter displacement'')');
        
        mn = uimenu(fig,'label','rotate');
        mn2 = uimenu(mn,'label','body');
        uimenu(mn2,'label','90','callback','actor(''rotate body'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','180','callback','actor(''rotate body'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','270','callback','actor(''rotate body'',str2num(get(gcbo,''label'')))');
        
        mn2 = uimenu(mn,'label','orientation');
        uimenu(mn2,'label','90','callback','actor(''rotate ort'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','180','callback','actor(''rotate ort'',str2num(get(gcbo,''label'')))');
        uimenu(mn2,'label','270','callback','actor(''rotate ort'',str2num(get(gcbo,''label'')))');
        
        mn2 = uimenu(mn,'label','flip orientation');
        uimenu(mn2,'label','x','callback','actor(''flip ort'',get(gcbo,''label''))');
        uimenu(mn2,'label','y','callback','actor(''flip ort'',get(gcbo,''label''))');
        uimenu(mn2,'label','z','callback','actor(''flip ort'',get(gcbo,''label''))');
        
        mn = uimenu(fig,'label','special object');
        uimenu(mn,'label','create','callback','specialobject(''setup'')');
        uimenu(mn,'label','copy','callback','specialobject(''copy'')');
        uimenu(mn,'label','copy all','callback','specialobject(''copy all'')');
        uimenu(mn,'label','edit bargraph','callback','specialobject(''edit bargraph'')');
        uimenu(mn,'label','ramp speed','callback','actor(''ramp speed'')')
        
    case 'lighting'
        uimenu(fig,'label','create','callback','lightman(''create'')');
        uimenu(fig,'label','save','callback','lightman(''save'')');
        set(gcf,'name','lighting');
        
    case 'costume'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','open all','callback','costume(''quick load'')');
        uimenu(mn,'label','save','callback','costume(''save'')');
        mn = uimenu(fig,'label','object');
        uimenu(mn,'label','fabric','callback','costume(''fabric'')');
        uimenu(mn,'label','clean','callback','director(''clean object'')');
        uimenu(mn,'label','delete','callback','costume(''delete'')','separator','on');
        
        mn = uimenu(fig,'label','tool');
        uimenu(mn,'label','rasp','callback','sculpttool(''rasp'')');
        uimenu(mn,'label','plane','callback','sculpttool(''plane'')');
        
    case 'grips'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','save','callback','grips(''save'')');
        uimenu('parent',fig,'label','bind','callback','grips(''bind'')');
        
    case 'props'
        mn = uimenu(fig,'label','file');
        uimenu(mn,'label','open','callback','director(''open'')');
        uimenu(mn,'label','open with markers','callback','props(''load with markers'')');
        uimenu(mn,'label','save','callback','props(''save'')');
        
        mn = uimenu(fig,'label','tools');
        uimenu(mn,'label','associate markers','callback','props(''associate marker'')');
        uimenu(mn,'label','puck trajectory','callback','props(''puck trajectory'')');
end
director('cleanup');
set(gcf,'name',action);

function nextperson(action)

ordr = {'director','cameraman','actor','lighting','costume'};
cindx = find(strcmp(ordr,{currentperson}));

switch action
    case 'next'
        cindx = cindx+1;
    case 'prev'
        cindx = cindx-1;
end

if cindx >length(ordr)
    cindx = 1;
elseif cindx <1
    cindx = length(ordr);
end
director('person',ordr{cindx});





function move(d,varargin)
val = get(finddobj('units','displacement'),'userdata');
if nargin == 2
    val = -val;
end
[tp,hnd] = currentobject;
switch tp
    case 'props'
        switch currentunits
            case 'displacement'
                switch d
                    case 'x'
                        vec = [val 0 0];
                    case 'y'
                        vec = [0 val 0];
                    case 'z'
                        vec = [0 0 val];
                end
                props('displace',vec)
            case 'rotation'
                val = get(finddobj('units','rotation'),'userdata');
                if nargin == 2
                    val = -val;
                end
                props('rotate',hnd,val,d);
        end
        
    case 'marker'
        switch d
            case 'x'
                vec = [val 0 0];
            case 'y'
                vec = [0 val 0];
            case 'z'
                vec = [0 0 val];
        end
        vr = get(hnd,'vertices');
        vr = displace(vr,vec);
        set(hnd,'vertices',vr);
    case 'prop marker'
        switch d
            case 'x'
                vec = [val 0 0];
            case 'y'
                vec = [0 val 0];
            case 'z'
                vec = [0 0 val];
        end
        target = get(hnd,'userdata');
        tg = get(hnd,'tag');
        ud = get(target,'userdata');
        indx = find(strcmp(tg,ud.mname));
        %gunit = [1 0 0;0 1 0;0 0 1];
        ud.mvertices(indx,:) = ud.mvertices(indx,:)+vec;
        set(target,'userdata',ud);
        props('goto',finddobj('frame','number'));
        
end

function multiopen(fld)

fl = engine('path',fld,'extension','c3d');

for i = 1:length(fl)
    marker('load c3d',fl{i});
    puck = findobj(finddobj('axes'),'tag','puck');
    pud = get(puck,'userdata');
    mxfrm = length(pud.dis(:,1));
    for j = 1:mxfrm
        mark('goto',j);
    end
end

% function distributedata(fl,type)  % possibly obsolete
%
% t = load(fl,'-mat');
%
% switch type
%
%     case 'zoo'
%
%         data = t.data;
%         fld = setdiff(fieldnames(data),'zoosystem');
%         cos = finddobj('costume');
%         hd = findpart('all','head');
%         for i = 1:length(fld)
%             hnd = findobj(cos,'tag',fld{i});
%             if ~isempty(hnd)
%                 hud = get(hnd,'userdata');
%                 if isfield(hud,'ydata')
%                     hud.ydata = data.(fld{i}).line;
%                     set(hnd,'userdata',hud);
%                 end
%             end
%             insertcdata(hd,fld{i},data.(fld{i}).line);
%         end
% end

% function insertcdata(hd,fld,yd)
%
% for i = 1:length(hd)
%     hud = get(hd(i),'userdata');
%     if isfield(hud,'cdata');
%         if isfield(hud.cdata,fld);
%             hud.cdata.(fld).cdata = yd/max(yd);
%         end
%     end
%     set(hd(i),'userdata',hud);
% end


