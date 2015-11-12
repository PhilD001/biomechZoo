function ensembler(action)
%
% ENSEMBLER graphs zoo channels by group. The user can change groupings by entering 
% appropriate fields in the 'name' section of the dialog box. Individual
% axes must be tagged before accepting line data
%
% EXAMPLES
%   e.g.1 There are two groups: 'elite' and 'rec' performing a task. Typing 'elite rec'
%   in the 'name' section will graph all files in 'elite' folder together and all files
%   in 'rec' together. A space must separate input strings.
%
%   e.g.2 There are two groups 'elite' and 'rec' performing two conditions 
%   'slap' and 'wrist' (ice hockey shot styles). typing 'elite+slap elite+wrist rec+slap rec+wrist'
%   will ensemble all files containing both input strings.
%
% - ensembled events may not "sit" on the mean line due to standard deviation of their
%   respective indices, i.e. different trials may have different index for a common event
%
% NOTES
% - There are known functionality issues graphing patches (e.g. standard deviation cloud)
%   on Mac OSX platforms
% - There are known functionality issues with errorbars on Matlab version 2014a and up
% - Functions tested on v2012a


% Revision History
%
% Created by JJ Loh Sept 2007
%
% Updated by Philippe C. Dixon Sept 28th 2007
%  - to search for multiple string enter command '+' between strings
%
% Updated by Yannick Paquette January 2009
%  - to combine multiple graphs from the same sub set
%    e.g. use combine within to plot the ankle, knee and hip angles into one graph for the elite group
%
% Updated by Philippe C. Dixon March 2009
%  - User has the option to delete an entire file or a single channel when
%    pressing the delete key. When deleting a single channel data inside the
%    channel is turned to value 999
%  - events are shown in graph, but can be removed by choosing line-->clear events
%  - User can now have axes titles spread over two lines
%  - menu rearranged
%
% Updated by Philippe C. Dixon July 2009
%  - a number of events can be added directly in ensembler. Choose from
%    standard event or manually select your own
%  - choose 'export' from file menu to export figures to a publication ready resolution
%    and format (.png). This option may fail in MACOSX. Instead choose 'save fig'
%  - zoom capabilities added
%  - emsembler can now do basic processing: filtering, partitioning, normlizing
%  - data can be ensembled by subject (within a condition)
%  - simplified manual event adding process
%  - you can automatically resize axes using 'resize axes'
%
% Updated by Philippe C. Dixon March 2010
% - ensembler now remembers last user default input values. Values are stored in a mat
%   file called 'default_ensembler_values.mat' in the same folder as ensembler
%
% Updated by Philippe C. Dixon and Ashley Hannon May 2010
% - Improved graphing/ensembling  of event data
%
% Updated by Yannick Paquette August 2010
%  - you can select pairs of variables to analyse in the coupling angle analysis program
%
% Updated by Philippe C. Dixon April 21 2012
% - Improvements to MACOSX functionality
% - added error checking.
%
% Updated by Philippe C. Dixon November 2013
% - Improved bar graph capabilities
%
% Updated by Philippe C. Dixon april 2014
% - improved use of ensemble subject x condition
% - improved bargraph handling
%
% Updated by Philippe C. Dixon June 2015
% - improved clearing of old data
% - improved selection of events and line
% - imrpoved handling of bar graphs
% - changed interpreter for title to 'none' to display underscore character
% - bar graphs can be reordered (see case 'reorder bars')


% Part of the Zoosystem Biomechanics Toolbox 
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 

if nargin == 0
    action = 'start';
end


global fld          % give every case access to fld

global f p            % give access to [p,f] for an individual trial, comes from 'load single file'



%===================BEGIN CASE STATEMENTS====================

switch action
    
    case 'start'
        start
        
    case 'restart'
        close all
        start
        
    case 'add manual event'
        ch = get(get(gca,'Title'),'String');
        add_manualevent(ch)
        update(p,f,fld)
        
    case 'add max event'
        ch = get(get(gca,'Title'),'String');
        lines = findobj('type','line','LineWidth',0.5);
        nlines = length(lines);
        
        if nlines ==1
            fl= get(lines,'userdata');           % this is the line handle
            data = load(fl,'-mat');
            data = data.data;
            [mmax,indx] = max(data.(ch).line);
            data.(ch).event.max = [indx mmax 1];
            save(fl,'data');
        else
            bmech_addevent(fld, ch,'max','max')
        end
        
        update(p,f,fld)
        
    case 'add min event'
        ch = get(get(gca,'Title'),'String');
        lines = findobj('type','line','LineWidth',0.5);
        nlines = length(lines);
        
        if nlines ==1
            fl= get(lines,'userdata');           % this is the line handle
            data = load(fl,'-mat');
            data = data.data;
            [mmin,indx] = min(data.(ch).line);
            data.(ch).event.min = [indx mmin 1];
            save(fl,'data');
        else
            bmech_addevent(fld,ch,'min','min')
        end
        
        update(p,f,fld)
        
    case 'add start trial event'
        ch = get(get(gca,'Title'),'String');
        add_manualevent(ch,'start')
        update(p,f,fld)
        
    case 'add end trial event'
        ch = get(get(gca,'Title'),'String');
        add_manualevent(ch,'end')
        update(p,f,fld)
        
    case 'add other channel event'
        addotherchannelevent(fld)
        
    case 'axis font size'
        prompt={'Enter the axis font size'};
        a = inputdlg(prompt,'axis font size',1,{'10'});
        sze = str2double((a{1}));
        
        ax = findobj('type','axes');
        for i = 1:length(ax)
            set(ax(i),'FontSize',sze);
        end
        
    case 'axisid'
        axisid
                
    case 'buttondown'
        buttondown
        
    case 'check continuous stats'
        continuousstats(fld,'check')
        
    case 'clear outliers'
        clear999outliers
        
    case 'clear all'
        
        lg = findobj('type','axes','tag','legend');
        
        if ~isempty(lg)
            delete(lg)
        end
        
        ax = findobj('type','axes');
        
       % delete all objects in graph
        for i = 1:length(ax)
            chnd = get(ax(i),'Children');
            
            if ~isempty(chnd)
                delete(chnd)
            end           
        end
                
        % clear prompt bar     
        pmt = findobj('tag','prompt');
        set(pmt,'String','')
        
        % reset xaxis label
        %
        for i = 1:length(ax)
            set(ax(i),'XTick',[0 0.5 1])
            set(ax(i),'XTickLabel',[0 0.5 1]')
            set(ax(i),'XLim',[0 1])
            set(ax(i),'XTickLabelMode','auto')
            set(ax(i),'XLimMode','auto')
            set(ax(i),'XTickMode','auto')
        end
        
    case 'clear colorbars'
        clearcolorbars
        
    case 'clear all events'
        delete(findobj('string','\diamondsuit'));
        
    case 'clear event by type'
        evthnd = findobj('string','\diamondsuit');
        evts =unique(get(evthnd,'Tag'));
        indx = listdlg('promptstring','choose your event type to clear','liststring',evts);
        
        evt = evts(indx);
        
        for i = 1:length(evthnd)
            
            ename = get(evthnd(i),'Tag');
            
            if ismember(ename,evt)
                delete(evthnd(i))
            end
        end
        
    case 'combine'
        combine;
        
    case 'combine_within'
        combine_within
        
    case 'combine custom'
        combine_custom
        
    case 'counttrials'
        counttrials
        
    case 'continuous stats'
        continuousstats(fld,[])
        
    case 'coupling angles'
        coupling_angles(fld)
        
    case 'datacursormode off'
        datacursormode off
        
    case 'clear titles'
        cleartitles
        
    case 'clear all empty axes'
        clearallaxes
        
    case 'delete single axis'
        disp('select axes to delete')
        delete(gca)
        
    case 'delete all events'
        ch = get(get(gca,'Title'),'String');
        lines = findobj('type','line','LineWidth',0.5);
        nlines = length(lines);
        if nlines ==1
            fl= get(lines,'userdata');           % this is the line handle
            data = load(fl,'-mat');
            data = data.data;
            evts = fieldnames(data.(ch).event);
            for e = 1:length(evts)
                data.(ch).event = rmfield(data.(ch).event,evts{e});
            end
            save(fl,'data');
        else
            bmech_removeevent('all',fld)
        end
        
        update(p,f,fld)
        
    case 'delete event by type'
        ch = get(get(gca,'Title'),'String');
        lines = findobj('type','line','LineWidth',0.5);
        nlines = length(lines);
        evthnd = findobj('string','\diamondsuit');
        evts =unique(get(evthnd,'Tag'));
        indx = listdlg('promptstring','choose your event type to delete','liststring',evts);
        
        if nlines ==1
            a={evts(indx)};
            
            fl= get(lines,'userdata');           % this is the line handle
            data = load(fl,'-mat');
            data = data.data;
            for e = 1:length(a)
                data.(ch).event = rmfield(data.(ch).event,a{e});
            end
            save(fl,'data');
        else
            a=evts(indx);
            
            bmech_removeevent(a,fld)
        end
        
        update(p,f,fld)
        
    case 'delete single event'
        ch = get(get(gca,'Title'),'String');
        evthnd = gco;
        evt = get(evthnd,'Tag');
        lnhnd = get(evthnd,'userdata');           % this is the line handle
        fl = get(lnhnd,'UserData');
        
        data = load(fl,'-mat');
        data = data.data;
        data.(ch).event = rmfield(data.(ch).event,evt);
        save(fl,'data');
        
        update(p,f,fld)
        
    case 'ensemble data (SD)'
        ensembledata('SD')
        
    case 'ensemble data (CI)'
        ensembledata('CI')
        
    case 'ensemble data (CB)'
        ensembledata('CB')
        
    case 'ensemble (subject x conditon) (SD)'
        ensembledatabysubject('SD')
        
    case 'ensemble (subject x conditon) (CI)'
        ensembledatabysubject('CI');
        
        
    case 'exit'
        delete(findensobj('figure'));
        
    case 'export'
        exportfig
        
    case 'filter'
        fl = engine('path',fld,'extension','zoo');
        ch = get(gca,'Tag');
        
        data = load(fl{1},'-mat');
        data = data.data;
        
        prompt={'Enter your desired cut-off frequency: '};
        cut = str2double(inputdlg(prompt,'axis title',1));
        
        if isfield(data.zoosystem,'Freq')
            fsamp = data.zoosystem.Freq;
            
        elseif isfield(data.zoosystem,'Fsamp')
            fsamp = data.zoosystem.Fsamp;
        else
            prompt={'Enter the sampling rate of your signal: '};
            fsamp = str2double(inputdlg(prompt,'axis title',1));
        end
        
        for i=1:length(fl)
            data = load(fl{i},'-mat');
            data = data.data;
            bmech_filter('vector',data.(ch).line,'fsamp',fsamp,'cutoff',cut);
        end
        
        update(p,f,fld)
        
    case 'fixcolorbar'
        fixcolorbar
        
    case 'gait ylabels'
        gaitylabels
        
    case 'gc labels'
        gclabels
        
    case 'horizontal line'
        horline
        
    case 'vertical line'
        verline
        
    case 'keypress'
        keypress;
        
    case 'legend'
        
        % remove existing legend
        %
        lhnd = findobj(gcf,'type','axes','tag','legend');
        if ~isempty(lhnd)
            delete(lhnd)
            return
        end
        
        % find existing axes
        %
        ax = findobj(gcf,'type','axes');
        
        % determine if we have lines or bar graphs
        %      
        ln = findobj(ax(1),'type','line','UserData','average_line');
        bar = flipud(findobj(ax(1),'type','hggroup','ShowBaseLine','on'));
                
        if ~isempty(ln)
            tg = cell(size(ln));
            
            for i = 1:length(ln)
                tg{i} = get(ln(i),'Tag');
            end
            
            hnd = ln;
        
        else
            tg = cell(size(bar));
            
            for i = 1:length(bar)
                tg{i} = get(bar(i),'Tag');
            end
                        
             hnd = bar;
        end
        
        rg = 1:1:length(tg);

        a = associatedlg(tg,{rg});
        val = a(:,1);
        
        hnd = zeros(length(val),1);
        for i = 1:length(val)
            
            if ~isempty(bar)        
                hnd(i) = findobj(ax(1),'tag',val{i});
                
            else
                hnd(i) = findobj(ax(1),'tag',val{i},'type','line');
            end
            
        end
        
        
        % display order
        indx = zeros(length(a),1);
        
        for i = 1:length(val)
           indx(i) = str2num(a{i,2});
        end

        val = val(indx);
        hnd = hnd(indx);
                
        legend(hnd,val,'interpreter','none');
        
       
        
    case 'linestyle'
        tg = get(findobj(gcf,'type','line'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'-','--',':','-.','none'});
        for i = 1:length(a(:,1))
            ln = findobj('type','line','tag',a{i,1});
            set(ln,'linestyle',a{i,2});
        end
        
        
    case 'linestyle_within'
        tg = get(findobj(gcf,'type','axes'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'-','--',':','-.','none'});
        for i = 1:length(a(:,1));
            ax = findobj('type','axes','tag',a{i,1});
            ln = findobj(ax,'type','line');
            set(ln,'linestyle',a{i,2});
        end
        
    case 'linewidth'
        tg = get(findobj(gcf,'type','line'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'.5','1','1.5','2','2.5','3'});
        for i = 1:length(a(:,1))
            ln = findobj('type','line','tag',a{i,1});
            set(ln,'linewidth',str2double(a{i,2}));
        end
        
    case 'bar color'
        
        ax = findobj(gcf,'type','axes');
        lg = findobj(gcf,'type','axes','tag','legend');
        ax = setdiff(ax,lg);
        
        tg = get(findobj(ax,'type','hggroup'),'tag');
        tg = setdiff(tg,'ebar');
     
        a = associatedlg(tg,{'b','r','g','c','m','k','y','dg','pu','db','lb'});
        
        for i = 1:length(a(:,1))
            br = findobj(ax,'type','hggroup','tag',a{i,1});
            
            if length(a{i,2})==1
                set(br,'FaceColor',a{i,2});
            else
                if isin(a{i,2},'dg')
                    set(br,'FaceColor', [0.1059  0.3098  0.2078]);          % dark green
                
                elseif isin(a{i,2},'pu')
                    set(br,'FaceColor', [0.4235  0.2510  0.3922]);          % purple
                    
                elseif isin(a{i,2},'br')
                    set(br,'FaceColor', [0.4510  0.2627  0.2627]);          % brown
                    
                elseif isin(a{i,2},'db')
                    set(br,'FaceColor', [0       0       0.7000]);          % dark blue
                    
                elseif isin(a{i,2},'lb')
                    set(br,'FaceColor', [ 0.2000    0.6000    1.0000]);     % ligh blue
                    
                    
                    
                else
                    
                end
                
            end
        end
        
    case 'linecolor'
        tg = get(findobj(gcf,'type','line'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'b','r','g','c','m','k','y','dg','pu','db','lb'});
        for i = 1:length(a(:,1))
            ln = findobj('type','line','tag',a{i,1});
            
            if length(a{i,2})==1
                set(ln,'color',a{i,2});
            else
                if isin(a{i,2},'dg')
                    set(ln,'color', [0.1059  0.3098  0.2078]);          % dark green
                elseif isin(a{i,2},'pu')
                    set(ln,'color', [0.4235  0.2510  0.3922]);          % purple
                    
                elseif isin(a{i,2},'br')
                    set(ln,'color', [0.4510  0.2627  0.2627]);          % brown
                    
                elseif isin(a{i,2},'db')
                    set(ln,'color', [0       0       0.7000]);          % dark blue
                    
                elseif isin(a{i,2},'lb')
                    set(ln,'color', [ 0.2000    0.6000    1.0000]);     % ligh blue
                    
                    
                    
                else
                    
                end
                
            end
        end
        
    case 'linecolor_within'
        tg = get(findobj(gcf,'type','axes'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'b','r','g','c','m','k'});
        for i = 1:length(a(:,1));
            ax = findobj('type','axes','tag',a{i,1});
            ln = findobj(ax,'type','line');
            set(ln,'color',a{i,2});
        end
        
    case 'load data'
        fld = uigetfolder;
        cd(fld);
        loaddata(fld,findobj('type','figure'));
        zoom out
        resize
        
    case 'load single file'
        delete(findobj('type','line'));
        delete(findobj('type','patch'));
        delete(findobj('string','\diamondsuit'));
        
        [f,p] = uigetfile('*.zoo','select zoo file');
        loadfile(f,p,findobj('type','figure'));
        zoom out
        cd(p)
                
    case 'makebar'
        makebar
        
    case 'normative PiG Kinematics'
        normdata('Schwartz Kinematics');
        
    case 'normative PiG Kinetics'
        normdata('Schwartz Kinetics');
        
    case 'normative EMG'
        normdata('Schwartz EMG');
        
    case 'normative OFM Kinematics'
        normdata('OFM Kinematics');
        
    case 'normalize'
        prompt={'Enter your desired data length: '};
        defaultanswer = {'100'};
        datalength = str2double(inputdlg(prompt,'axis title',1,defaultanswer));
        ensembler_normalize(fld,datalength)
        
        update(p,f,fld)
        
    case 'partition'
        prompt={'Enter name of start event: ', 'Enter name of end event'};
        evt = inputdlg(prompt,'axis title',1);
        bmech_partition(evt(1),evt(2),fld)
        update(p,f,fld)
        
    case 'property editor on'
        propertyeditor('on')
        
    case 'property editor off'
        propertyeditor('off')
        
        
    case 'relative phase'
        relative_phase('load')
        
    case 'retag'
        fig = gcf;
        ax = findobj(fig,'type','axes');
        tg = get(ax,'tag');
        if ~iscell(tg)
            tg = {tg};
        end
        [f,p] = uigetfile('*.zoo','choose your zoo channels');
        cd(p)
        t = load([p,f],'-mat');
        a = associatedlg(unique(tg),setdiff(fieldnames(t.data),{'zoosystem'}));
        for i = 1:length(a(:,1))
            ax = findobj('type','axes','tag',a{i,1});
            if isempty(ax)
                continue
            end
            for aindx = 1:length(ax)
                txt = get(ax(aindx),'title');
                set(ax(aindx),'tag',a{i,2});
                set(txt,'string',a{i,2},'interpreter','none') % interpreter set to none to show underscore
            end
        end
        
    case 'resize axis'
        resize
        
    case 'resize subfigure'
        resizesub
        
    case 'reorder bars'
        reorder_bars
        
    case 'save fig'
        filemenufcn(gcbf,'FileSaveAs')
        
    case 'stdcolor'
        tg = get(findobj(gcf,'type','patch'),'tag');
        tg = setdiff(tg,{''});
        
        a = associatedlg(tg,{'b','r','g','c','m','k'});
        for i = 1:length(a(:,1))
            pch = findobj('type','patch','tag',a{i,1});
            set(pch,'FaceColor',a{i,2});
        end
        
    case 'stdcolor within'
        tg = get(findobj(gcf,'type','axes'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'b','r','g','c','m','k'});
        for i = 1:length(a(:,1));
            ax = findobj('type','axes','tag',a{i,1});
            pch = findobj(ax,'type','patch');
            set(pch,'FaceColor',a{i,2},'FaceAlpha',0.1);
        end
        
        
    case 'stdline'
        tg = get(findobj(gcf,'type','patch'),'tag');
        %         tg = setdiff(unique(tg),{''});
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'b','r','g','c','m','k'});
        for i = 1:length(a(:,1))
            pch = findobj('type','patch','tag',a{i,1});
            set(pch,'FaceColor','w')
            set(pch,'EdgeColor',a{i,2});
        end
        
        b = associatedlg(tg,{'-','--',':','-.','none'});
        for i = 1:length(b(:,1))
            set(pch,'LineStyle',b{i,2});
        end
        
        
    case 'std shade'
        tg = get(findobj(gcf,'type','patch'),'tag');
        %         tg = unique(tg)
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'.1','.2','.3','.4','.5','.6','.7','.8','.9','1'});
        for i = 1:length(a(:,1))
            pch = findobj('type','patch','tag',a{i,1});
            set(pch,'facealpha',str2double(a{i,2}));
        end
        
    case 'std on off'
        tg = get(findobj(gcf,'type','patch'),'tag');
        %         tg = unique(tg);
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'on','off'});
        for i = 1:length(a(:,1))
            pch = findobj('type','patch','tag',a{i,1});
            set(pch,'visible',a{i,2});
        end
        
    case 'title'
        prompt={'Enter the figure title'};
        a = inputdlg(prompt,'axis title',1);
        a = [a;' '];
        set(get(gca,'Title'),'String',a)
        set(gca,'Tag',a{1})
        
    case 'xlabel'
        
        ax = findobj('type','axes');
        defaultanswer = {'',''};
        
        for i = 1:length(ax)
            
            if ~isempty(get(ax(i),'XLabel'))
                val = get(get(ax(i),'XLabel'),'String');
                
                if ~isempty(val)
                    
                    if length(val)==1
                        defaultanswer{1} = val(1);
                    else
                        defaultanswer= val;
                    end
                end
            end
            
        end
        
        
        prompt={'Enter the axis title (1st line): ',...
            'Enter the axis title (2nd line): '};
        
        a = inputdlg(prompt,'axis title',1,defaultanswer);
        [r,~]  = size(a);
        
        if r==1
            set(get(gca,'XLabel'),'String',a)
        end
        
        if r==2
            set(get(gca,'XLabel'),'String',a)
        end
        
    case 'xlim'
        setaxes('xlim');
        
    case 'xticks'
        prompt={'Enter the tick width'};
        a = inputdlg(prompt,'axis ticks',1);
        tick = str2double((a{1}));
        
        xlim = get(gca,'XLim');
        xticks = xlim(1):tick:xlim(2);
        
        ax = findobj('type','axes');
        for i = 1:length(ax)
            set(ax(i),'XTick',xticks);
        end
        
    case 'yticks'
        prompt={'Enter the tick width'};
        a = inputdlg(prompt,'axis ticks',1);
        tick = str2double((a{1}));
        
        xlim = get(gca,'YLim');
        xticks = xlim(1):tick:xlim(2);
        
        set(gca,'YTick',xticks)
        
    case 'xlimit'
        prompt={'Enter the lower limit of the axis: ',...
            'Enter the upper limit of the axis): '};
                
        default = get(gca,'YLim');
        defaultstr = {num2str(default(1)),num2str(default(2))};
        
        a = inputdlg(prompt,'axis limits',1,defaultstr);
        lower = str2double(a{1});
        upper = str2double(a{2});
        
        ax = findobj('type','axes');
        
        for i = 1:length(ax)
            
            if ~isempty(get(ax(i),'Tag')) && ~isin(get(ax(i),'Tag'),'legend')
                set(ax(i),'XLim',[lower upper])
            end
            
        end
        
    case 'xlimmode'
        setaxes('xlimmode');
        
    case 'xtickmode'
        setaxes('ytickmode');
        
    case 'ylabel'
        
        ax = findobj('type','axes');
        defaultanswer = {'',''};
        
        for i = 1:length(ax)
            
            if ~isempty(get(ax(i),'YLabel'))
                val = get(get(ax(i),'YLabel'),'String');
                
                if ~isempty(val)
                    
                    if length(val)==1
                        defaultanswer(1) = val(1);
                    else
                        defaultanswer= val;
                    end
                end
            end
            
        end
        
        prompt={'Enter the axis title (1st line): ',...
            'Enter the axis title (2nd line): '};
        
        a = inputdlg(prompt,'axis title',1,defaultanswer);
        [r,~]  = size(a);
        
        if r==1
            set(get(gca,'YLabel'),'String',a)
        end
        
        if r==2
            set(get(gca,'YLabel'),'String',a)
        end
        
    case 'ylim'
        setaxes('ylim');
        
    case 'ylimit'
        prompt={'Enter the lower limit of the axis: ',...
            'Enter the upper limit of the axis): '};
        
        default = get(gca,'YLim');
        defaultstr = {num2str(default(1)),num2str(default(2))};
        a = inputdlg(prompt,'axis limits',1,defaultstr);
        
        lower = str2double(a{1});
        upper = str2double(a{2});
        set(gca,'YLim',[lower upper])
        
    case 'zoom on'
        zoom on
        
    case 'zoom off'
        zoom off
        
    case 'zoom restore'
        zoom out
        
    case 'edit fig names'
        
        prompt = {'Enter new search string'};
        name = 'Search string';
        numline = 1;
        defaultanswer = {get(gcf,'name')};
        sstr=inputdlg(prompt,name,numline,defaultanswer);
        sstr = cell2mat(sstr);
        sstr_cell = partitionname(sstr);  % PD update
        
        ensembler('clear')
        
        figs = findobj('type','figure');
        
        for i = 1:length(figs)
            
            set(figs(i),'name',sstr_cell{i});
            
        end
        
        e=which('ensembler'); % returns path to ensemlber
        path = pathname(e) ;  % local folder where ensembler resides
        defaultvalfile = [path,'default_ensembler_values.mat'];
        
        a = load(defaultvalfile,'-mat');
        a= a.a;
        
        a{1} = sstr;
        
        
        save(defaultvalfile,'a')
        
        
        
        
    case 'zero'
        
        ax = findobj('type','axes');
        tg = cell(1,length(ax));
        
        for i=1:length(ax)
            r = get(ax(i),'tag');
            tg{i}=r;
        end
        
        ch = unique(tg);
        
        bmech_datazero('folder',fld,'channels',ch);
        updatedata(fld)
end


%===================BEGIN GUI SETUP====================


function startup(nm,nrows,ncols,xwid,ywid,xspace,yspace,fw,fh,i,nfigs)

if nargin < 10
    i = 1;
    nfigs = 1;
end

fig = figure('name',nm,'units','inches','position',[0 0 fw fh],'menubar','none','numbertitle','off','keypressfcn','ensembler(''keypress'')');
% ,  th = uitoolbar(fig)

if i == nfigs % only the master gets uimenu
    
    mn = uimenu(gcf,'label','File');
    uimenu(mn,'label','restart','callback','ensembler(''restart'')');
    uimenu(mn,'label','load data','callback','ensembler(''load data'')','separator','on');
    uimenu(mn,'label','load single file','callback','ensembler(''load single file'')');
    uimenu(mn,'label','save fig','callback','ensembler(''save fig'')','separator','on');
    uimenu(mn,'label','export','callback','ensembler(''export'')');
    uimenu(mn,'label','exit','callback','ensembler(''exit'')','separator','on');
    
    mn = uimenu(gcf,'label','Edit');
    % uimenu(mn,'label','edit fig names','callback','ensembler(''edit fig names'')');
    uimenu(mn,'label','property editor on','callback','ensembler(''property editor on'')');
    uimenu(mn,'label','property editor off','callback','ensembler(''property editor off'')');
    % uimenu(mn,'label','datacursormode off','callback','ensembler(''datacursormode off'')','separator','on');
    
    mn = uimenu(gcf,'label','Ensembler');
    uimenu(mn,'label','ensemble (SD)','callback','ensembler(''ensemble data (SD)'')');
    uimenu(mn,'label','ensemble (CI)','callback','ensembler(''ensemble data (CI)'')');
    uimenu(mn,'label','ensemble (CB)','callback','ensembler(''ensemble data (CB)'')');
    uimenu(mn,'label','ensemble (subject x conditon) (SD)','callback','ensembler(''ensemble (subject x conditon) (SD)'')','separator','on');
    uimenu(mn,'label','ensemble (subject x conditon) (CI)','callback','ensembler(''ensemble (subject x conditon) (CI)'')');
    uimenu(mn,'label','combine data','callback','ensembler(''combine'')','separator','on');
    uimenu(mn,'label','combine custom','callback','ensembler(''combine custom'')');
    uimenu(mn,'label','combine within data','callback','ensembler(''combine_within'')');
    uimenu(mn,'label','clear outliers','callback','ensembler(''clear outliers'')','separator','on');
    uimenu(mn,'label','clear all','callback','ensembler(''clear all'')');
    
    mn = uimenu(gcf,'label','Insert');
    uimenu(mn,'label','title','callback','ensembler(''title'')');
    uimenu(mn,'label','axis ids (a,b,c,...)','callback','ensembler(''axisid'')');
    uimenu(mn,'label','legend','callback','ensembler(''legend'')');
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
    
    mn = uimenu(gcf,'label','Line');
    uimenu(mn,'label','line style','callback','ensembler(''linestyle'')');
    uimenu(mn,'label','line style within','callback','ensembler(''linestyle_within'')');
    uimenu(mn,'label','line width','callback','ensembler(''linewidth'')');
    uimenu(mn,'label','line color','callback','ensembler(''linecolor'')');
    uimenu(mn,'label','line color within','callback','ensembler(''linecolor_within'')');
    
    
    mn = uimenu(gcf,'label','Bar Graph');
    uimenu(mn,'label','bar graph','callback','ensembler(''makebar'')');   
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
    
    
    mn = uimenu(gcf,'label','Zoom');
    uimenu(mn,'label','zoom on','callback','ensembler(''zoom on'')');
    uimenu(mn,'label','zoom off','callback','ensembler(''zoom off'')');
    uimenu(mn,'label','zoom restore','callback','ensembler(''zoom restore'')');
    
    
    mn = uimenu(gcf,'label','Processing');
    uimenu(mn,'label','filter','callback','ensembler(''filter'')');
    uimenu(mn,'label','partition','callback','ensembler(''partition'')','separator','on');
    uimenu(mn,'label','normalize','callback','ensembler(''normalize'')','separator','on');
    
    
    mn = uimenu(gcf,'label','Analysis');
    uimenu(mn,'label','coupling angles','callback','ensembler(''coupling angles'')','separator','on');
    uimenu(mn,'label','relative angles','callback','ensembler(''relative phase'')','separator','on');
    uimenu(mn,'label','continuous stats','callback','ensembler(''continuous stats'')','separator','on');
    uimenu(mn,'label','clear colorbars','callback','ensembler(''clear colorbars'')');
    
end

fpos = get(fig,'position');
uicontrol('units','inches','style','text','position',[0 fpos(4)-.5 fpos(3) .25],'tag','prompt','backgroundcolor',get(gcf,'color'));
fpos(4) = fpos(4)-.25;

xvec = getspacing(ncols,xwid,xspace,fpos(3));
yvec = getspacing(nrows,ywid,yspace,fpos(4));
lyvec = length(yvec);

for i = 1:length(xvec)
    for j = 1:length(yvec)
        xpos = (i-1)*xwid+sum(xvec(1:i));
        ypos = (j-1)*ywid+sum(yvec(1:j));
        %row & column number
        cnum = mod(i,length(xvec));
        rnum = mod(j,length(yvec));
        if rnum == 0
            rnum = length(yvec);
        end
        if cnum == 0
            cnum = length(xvec);
        end
        
        ax = axes('units','inches','position',[xpos,ypos,xwid,ywid],'tag',num2str([lyvec-rnum+1 cnum]),'box','on','userdata',...
            [rnum,cnum],'buttondownfcn','ensembler(''buttondown'')');
        
        hnd = title(ax,get(ax,'tag'));
        set(hnd,'units','normalized','position',[.5 1 0],'horizontalalignment','center','verticalalignment','bottom');
        
    end
end



%=========BEGIN EMBEDDED FUNCTIONS===============

function addotherchannelevent(fld)


fl = engine('path',fld,'extension','zoo');

data = load(fl{1},'-mat');
data = data.data;
ch = setdiff(fieldnames(data),'zoosystem');



evts = {};
for i = 1:length(ch)
    evt = fieldnames(data.(ch{i}).event);
    evts = [evts; evt];
end

evts = unique(evts);
indx = listdlg('promptstring','choose your event','liststring',evts);
evts =evts(indx);


figs = findobj('type','figure');

for i =1:length(figs)
    
    ax = findobj(figs(i),'type','axes');
    
    for j =1:length(ax)
        
        %         ch = get(get(ax(j),'Title'),'String');
        lines = findobj(ax(j),'type','line');
        
        for k = 1:length(lines)
            
            file = get(lines(k),'UserData');
            ln = get(lines(k),'YData');
            
            for m = 1:length(evts)
                
                data = load(file,'-mat');
                data = data.data;
                
                if isfield(data.zoosystem,'VideoSampleNum')
                    offset = abs(data.zoosystem.VideoSampleNum.Indx(1));
                else
                    offset = 0;
                end
                
                
                indx = findfield(data,evts{m});
                xpos = indx(1);
                ypos = ln(xpos);
                
                text('parent',ax(j),'position',[xpos-offset ypos ],...
                    'tag',evts{m},'string','\diamondsuit','verticalalignment',...
                    'middle','horizontalalignment','center','color',[1 0 0],...
                    'buttondownfcn',get(ax(j),'buttondownfcn'),'userdata',evts{m});
                
            end
            
        end
        
    end
    
end


function clearcolorbars


figs = findobj('type','fig');

for j = 1:length(figs)
    
    sfigs = findobj(figs(j),'type','Patch','tag','');
    back = findobj(figs(j),'type','axes','Tag','colormap');
    
    for i = 1:length(sfigs)
        delete(sfigs(i))
    end
    
    for i = 1:length(back)
        delete(back(i))
    end
    
end

cbar = findobj('type','axes','Tag','Colorbar');
delete(cbar)

ctext = findobj('type','text','Tag','');

for i = 1:length(ctext)
    delete(ctext(i))
end





function cleartitles

figs = findobj('type','fig');

for j = 1:length(figs)
    
    sfigs = findobj(figs(j),'type','axes');
    
    for i = 1:length(sfigs)
        axes(sfigs(i)) % make current
        if isempty(strfind(get(sfigs(i),'Tag'),'legend'))
            
            set(sfigs(i),'Tag','')
            set(get(sfigs(i),'Title'),'String','');
        end
    end
    
end

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


function add_skate_event(ch,num,type)

h=datacursormode;
set(h,'DisplayStyle','window','Enable','on','SnapToData','on')

hnd = gcf;
pause
% setWindowOnTop(hnd,'true')

hnd = gcf;
dcm_obj=datacursormode(hnd);
info_struct = getCursorInfo(dcm_obj);
position = info_struct.Position;
ln = info_struct.Target;


fl = get(ln,'UserData');
data = load(fl,'-mat');
data = data.data;

switch type
    
    case 'peak'
        zone = data.(ch).line(position(1)-3:position(1)+3);
        [m,indx] = max(zone);
        position =[position(1)-3+indx-2 m];
        
    case 'start'
        if position(1)>4
            zone = data.(ch).line(position(1)-3:position(1)+3);
            [m,indx] = min(zone);
            position =[position(1)-3+indx-2 m];
        else
            zone =  data.(ch).line(1:position(1)+3);
            [m,indx] = min(zone);
            position =[position(1)+indx-2 m];
        end
        
    case 'end'
        l = length(data.(ch).line);
        if position(1)<= l-3
            zone = data.(ch).line(position(1)-3:position(1)+3);
            [m,indx] = min(zone);
            position =[position(1)-3+indx-2 m];
        end
        
    case 'min'
        zone = data.(ch).line(position(1)-3:position(1)+3);
        [m,indx] = min(zone);
        position =[position(1)-3+indx-2 m];
        
end

data.(ch).event.([type(1),num2str(num)]) = [position(1) position(2) 0];
save(fl,'data');

disp('event tagged')
datacursormode off
% setWindowOnTop(hnd,'false')


function counttrials


figs = findobj('type','figure');

for i = 1:length(figs)
    
    ax =  findobj(figs(i),'type','axes');
    
    pt = get(ax(1),'parent');       %parent of axis is figure
    nm = get(pt,'name');
    
    ln = findobj(ax(1),'type','line');
    disp(['for ',nm,' n = ',num2str(length(ln))])
    
    
    
end

function coupling_angles(fld)

disp(' ')
disp('****************HINTS***************')
disp(' ')
disp(' - Data must not be ensembled or combined')
disp(' - only 2 axes can be done per session')
disp(' ')
disp('************************************')

fig = findobj('type','figure');

for i= 1:length(fig)
    
    ax = findobj(fig(i),'type','axes');
    name = get(fig(i),'Name');
    ch1 = get(ax(1),'tag');
    ch2 = get(ax(2),'tag');
    
    
    lines = findobj(fig(i),'type','line');
    delete(lines);
    
    if isin(name,'+')
        indx = strfind(name,'+');
        name1 =  engine('path',fld,'extension','zoo','search',name(1:indx-1));
        name2 =  engine('path',fld,'extension','zoo','search',name(indx+1:end));
        
        fl = intersect(name1,name2);
        
    else
        
        fl = engine('path',fld,'extension','zoo','search',name);
        
    end
    
    for j = 1:length(fl)
        
        data = load(fl{j},'-mat');
        data = data.data;
        ln = line('parent',ax(1),'xdata',data.(ch2).line,'ydata',data.(ch1).line,'userdata',fl,...
            'buttondownfcn',get(ax(1),'buttondownfcn'));
        
        evt1 = fieldnames(data.(ch1).event);
        evt2 = fieldnames(data.(ch2).event);
        
        evt = [evt1, evt2];
        
        for e = 1:length(evt)
            
            event = findfield(data,evt{e});
            
            if event~=999
                
                ch1pos = data.(ch1).line(event(1));
                ch2pos = data.(ch2).line(event(1));
                
                text('parent',ax(1),'position',[ch1pos ch2pos],...
                    'tag',evt{e},'string','\diamondsuit','verticalalignment',...
                    'middle','horizontalalignment','center','color',[1 0 0],...
                    'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
            end
        end
    end
    
    resize
end

% function coupling_angles(fld)
%
% % error('doesnt work, uncomment old version above')
%
% fig = findobj('type','figure');
% ax = findobj(fig(1),'type','axes');
% tg = get(ax,'tag');
% a = associatedlg(tg,tg);
%
% for i= 1:length(fig)
%
%     ax = findobj(fig(i),'type','axes');
%     name = get(fig(i),'Name');
%
%     for k = 1:length(a)
%
%         ch1 =a{k,1};
%         ch2 = a{k,2};
%
%         ax1 = findobj(ax,'tag',ch1);
%         ax2 = findobj(ax,'tag',ch2);
%
%         lines1 = findobj(ax1,'type','line');
%         lines2 = findobj(ax2,'type','line');
%
%         lines = [lines1; lines2];
%          delete(lines);
%
%         fl = engine('path',fld,'extension','zoo','search',name);
%
%         for j = 1:length(fl)
%
%             data = load(fl{j},'-mat');
%             data = data.data;
%             ln = line('parent',ax1,'ydata',data.(ch2).line,'xdata',data.(ch1).line,'userdata',fl,...
%                 'buttondownfcn',get(ax1,'buttondownfcn'));
%             evt1 = fieldnames(data.(ch1).event);
%             evt2 = fieldnames(data.(ch2).event);
%
%             evt = [evt1, evt2];
%
%             for e = 1:length(evt)
%
%                 event = findfield(data,evt{e});
%
%                 if event~=999
%
%                     ch1pos = data.(ch1).line(event(1));
%                     ch2pos = data.(ch2).line(event(1));
%
%                     %             ch1pos = yd(event(1));
%                     %             ch2pos = xd(event(1));
%
%                     text('parent',ax(k),'position',[ch1pos ch2pos],...
%                         'tag',evt{e},'string','\diamondsuit','verticalalignment',...
%                         'middle','horizontalalignment','center','color',[1 0 0],...
%                         'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
%                 end
%             end
%         end
%     end
%
% end
%
% resize



function createlines(fig,data,fl)

ch = fieldnames(data);

tch = unique(ch);

if length(tch) ~=length(ch)
    error('you have repeated a channel name')
end

for j = 1:length(ch)
    ax = findobj(fig,'type','axes','tag',ch{j});
    if isempty(ax)
        continue
    end
    
    ydata = data.(ch{j}).line;
    
    %     if isfield(data.zoosystem, 'VideoSampleNum') && ~isin(ch{j},'OFM')
    %         xdata = makecolumn(data.zoosystem.VideoSampleNum.Indx);
    %         offset = xdata(1);
    %     elseif isin(ch{j},'OFM') && ~isempty(isnan(ydata))
    %         xdata = makecolumn(data.zoosystem.VideoSampleNum.Indx);
    %         offset = find(~isnan(ydata),1,'first');
    %         ydata = ydata(offset:end);
    %         xdata = xdata(offset:end);
    %     else
    %         xdata = (0:length(data.(ch{j}).line)-1);
    %         offset = 0;
    %     end
    
    
    if isfield(data.zoosystem, 'VideoSampleNum')
        xdata = makecolumn(data.zoosystem.VideoSampleNum.Indx);
        offset = xdata(1);
        
    else
        xdata = (0:length(data.(ch{j}).line)-1);
        offset = 0;
    end
    
    xdata = makecolumn(xdata);
    
    [~,c] = size(ydata);
    
    if c~=1
        error('data must be n x 1 for graphing, explode first')
    end
    
    ln = line('parent',ax,'ydata',ydata,'xdata',xdata,'userdata',fl,...
        'buttondownfcn',get(ax,'buttondownfcn'));
    evt = fieldnames(data.(ch{j}).event);
    for e = 1:length(evt)
        text('parent',ax,'position',[data.(ch{j}).event.(evt{e})(1)+offset data.(ch{j}).event.(evt{e})(2)],...
            'tag',evt{e},'string','\diamondsuit','verticalalignment',...
            'middle','horizontalalignment','center','color',[1 0 0],...
            'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
    end
    
end

function combine

ax = findensobj('axes',gcf);
for i = 1:length(ax)
    tg = get(ax(i),'tag');
    axs = setdiff(findobj('type','axes','tag',tg),ax(i));
    ln = findobj(axs,'type','line');
    pch = findobj(axs,'type','patch');
    %     txt = findobj(axs,'string','\diamondsuit');
    txt = findobj(axs,'type','text');
    set(ln,'parent',ax(i));
    set(pch,'parent',ax(i));
    set(txt,'parent',ax(i));
    bottomhnd(pch);
end


function combine_custom

% used to combine different axes within a same condition

fig = findobj('type','figure');

for j = 1:length(fig)
    
    ax = findensobj('axes',fig(j));
    tg = cell(size(ax));
    
    for i = 1:length(ax)
        tg{i} = get(ax(i),'tag');
    end
    
    if j==1
        a = associatedlg(tg,tg);
    end
    
    [r,~] = size(a);
    
    if r==1
        axh = findobj(fig(j),'type','axes','tag',a{1,1});
        axm = findobj(fig(j),'type','axes','tag',a{1,2});
        
        ln = findobj(axm,'type','line');
        pch = findobj(axm,'type','patch');
        txt = findobj(axm,'string','\diamondsuit');  % line events
        mtxt = findobj(axm,'string','\bullet');   % mean event
        set(ln,'parent',axh);
        set(pch,'parent',axh);
        set(txt,'parent',axh);
        set(mtxt,'parent',axh);
        bottomhnd(pch);
        
    else
        
        for i = 1:length(a)
            
            axh = findobj(fig(j),'type','axes','tag',a{i,1});
            axm = findobj(fig(j),'type','axes','tag',a{i,2});
            
            ln = findobj(axm,'type','line');
            pch = findobj(axm,'type','patch');
            txt = findobj(axm,'string','\diamondsuit');  % line events
            mtxt = findobj(axm,'string','\bullet');   % mean event
            set(ln,'parent',axh);
            set(pch,'parent',axh);
            set(txt,'parent',axh);
            set(mtxt,'parent',axh);
            bottomhnd(pch);
            
        end
        
    end
    
    axs = setdiff(findobj('type','axes','tag',tg),ax(i));
    ln = findobj(axs,'type','line');
    pch = findobj(axs,'type','patch');
    txt = findobj(axs,'string','\diamondsuit');
    set(ln,'parent',ax(i));
    set(pch,'parent',ax(i));
    set(txt,'parent',ax(i));
    bottomhnd(pch);
    
    
end

function combine_within

figs = findobj('type','figure');

for j = 1:length(figs)
    
    name = get(figs(j),'name');
    
    ax = findensobj('axes',figs(j));
    ca=ax(1);     % goes into first figure
    
    for i = 2:length(ax)
        ln = findobj(ax(i),'type','line');
        pch = findobj(ax(i),'type','patch');
        txt = findobj(ax(i),'string','\diamondsuit');
        mtxt = findobj(ax(i),'string','\bullet');
        set(ln,'parent',ca);
        set(ln,'tag',get(ax(i),'tag'))
        set(pch,'parent',ca);
        set(txt,'parent',ca);
        set(mtxt,'parent',ca);
        bottomhnd(pch)
    end
    
    set(figs(j),'name',[name,'_combined'])
    
end


function continuousstats(fld,check)

resize   % if there are blank 'x' data continuous stats will fail


ax = findobj('type','axes');

r = struct;
maxvalstk = zeros(length(ax),1);
multstk= zeros(length(ax),1);


for i = 1:length(ax)
    
    ln = findobj(ax(i),'type','line');
    
    if ~isempty(ln)
        ch = get(ax(i),'Tag');
        
        if ~isin(ch,'legend')
            alpha = 0.05;
            nboots = 1000;
            [maxvalstk(i),temp,multstk(i)] = getmaxval(fld,ch,alpha,ax(i),nboots,check);
            r.(ch) = temp.(ch);
        end
    end
end

maxval = max(maxvalstk);
mult = max(multstk);




for i = 1:length(ax)
    
    ln = findobj(ax(i),'type','line');
    
    if ~isempty(ln)
        ch = get(ax(i),'Tag');
        
        if ~isin(ch,'legend')
            alpha = 0.05;
            nboots = 1000;
            compcons = bmech_continuous_stats_ensembler4(fld,ch,r,alpha,ax(i),nboots,maxvalstk(i),check);
            
        end
    end
end



if isempty(check)
    
    %--- add colorbar axis--
    
    colormap(jet(200));  %uses the jet color map with smooth color changes
    
    dummyax = axes('units','inches','position',[10,1,1,1],'Visible','off');
    cbar = colorbar('peer',dummyax,'location','NorthOutside');
    
    % caxis([0 maxval]); % if you want xticks
    set(cbar,'XTickLabel',[]) % for no xticks
    set(cbar,'YTickLabel',[])
    %--textbox containing info----
    
    tx = {'A','B','C','D','E','F','G','H'};
    
    stk = [];
    
    for i = 1:length(compcons)
        
        comp = compcons{i};
        comp = strrep(comp,'_',' ');
        plate = [tx{i},': ',comp];
        stk = [stk; plate]     ;
    end
    
    thnd = text(0,0.4,{stk});
    set(thnd,'Tag','cstatsbox')
    
    
    
end


function clear999

ax = findensobj('axes');

for i = 1:length(ax)
    ln = findobj(ax(i),'type','line');
    evt = findobj(ax(i),'string','\diamondsuit');
    for k = 1:length(evt)
        
        P = get(evt(k),'Position');
        if P(2) == 999
            delete(evt(k))
        end
    end
    
    for j = 1:length(ln)
        yd = get(ln(j),'ydata');
        if mean(yd)==999
            delete(ln(j))
        end
    end
end

disp('removed 999 outliers')


function clearallaxes

ax = findobj('type','axes');

for i = 1:length(ax)
    
    ln = findobj(ax(i),'type','line');
    tag = get(ax(i),'Tag');
    if isempty(ln)  && ~isin(tag,'Colorbar')
        delete(ax(i))
    end
    
    
end


function makebar


ax = findobj(gcf,'type','axes');

lg=0; %don't draw legend

for i = 1:length(ax)
    
    ebar = findobj(ax(i),'type','line','linewidth',1.12);
    
    if ~isempty(ebar)
        
        ehnd = findobj(ax(i),'type','text');
        ln = findobj(ax(i),'type','line','UserData', 'average_line');
        
        barvaluestk = ones(size(ehnd));
        groupnames = cell(size(ehnd));
        
        errorstk = [];
        
        for j = 1:length(ehnd)
            barvalue = get(ehnd(j),'Position');
            barvaluestk(j) = barvalue(2);
            groupnames{j} = get(ehnd(j),'Tag');
        end
        
        
        for m=1:length(ebar)
            errors = get(ebar(m),'YData');
            if length(errors)~=1
                errorstk = [errorstk; abs(errors(1)-errors(2))/2];
            end
        end
        
        groupcolors = [];
        for k = 1:length(ln)
            plate = get(ln(k),'Color');
            
            if plate == [0 0 0]
                plate = [ 0.3137    0.3137    0.3137];
            end
            
            groupcolors = [groupcolors; plate];
        end
        
        
        child = get(ax(i),'Children');
        
        for k = 1:length(child)
            delete(child(k));
        end
        
        axes(ax(i)); % makes ax(i) current
        
        lg= mybar(barvaluestk,errorstk,groupnames,groupcolors,ax(i),lg);
        
        hnd = xlabel('bar graph');
        resize % make a first attempt at resizing
        delete(hnd)
        
    end
  
end



function reorder_bars

ax = gca;

% get error bars
%
ehnd = sort(findobj(ax,'type','hggroup','tag','ebar'));
evals = zeros(size(ehnd));

for i = 1:length(ehnd)
   evals(i) = get(ehnd(i),'UData'); 
end


% get bar handles 
%
bhnd = sort(findobj(ax,'type','hggroup'));

for i = 1:length(bhnd)
    tag = get(bhnd(i),'tag');
    
if isempty(tag) || isin(tag,'ebar')
    bhnd(i) = 0;
end

end

indx = find(bhnd==0);
bhnd(indx) = [];


% find bar tags and values
%
btags = cell(size(bhnd)); 
bvals = zeros(length(bhnd),2);
bcols = zeros(length(bhnd),3);

cmap = colormap; % retrieve current color map

for i = 1:length(bhnd)
    btags{i} = get(bhnd(i),'Tag'); 
    bvals(i,:) = get(bhnd(i),'YData');
    bcols(i,:) = get(bhnd(i),'FaceColor');
end
bvals = bvals(:,1);


% get user choice 
%
nums = 1:1:length(btags);
a = associatedlg(btags,{nums});

indx = str2num(char(a(:,2)));


% decide if user changed left or right column
%
if isequal(indx,nums')     % user modified left column
    error('please modify number order in right column')
end


% check if user reused numbers
%
if ~isequal(sort(indx),nums')
    error('numbers reused twice, please select unique order')
end



% reoder bargraph elements
%
bvals(indx) = bvals;
evals(indx) = evals;
btags(indx) = btags;
bcols(indx,:) = bcols;

bwidth = get(bhnd(1),'BarWidth');

% delete existing bar graph
%
delete(bhnd)
delete(ehnd)

mybar(bvals,evals,btags,bcols,ax,0)




function ensembledata(vartype)

prmt = findobj('Tag','prompt');

if ~isempty(prmt)
    delete(prmt)
end

ax = findensobj('axes');

for i = 1:length(ax)
    lstk = [];
    ln = findobj(ax(i),'type','line','linewidth',.5);
    pt = get(ax(i),'parent');       %parent of axis is figure
    nm = get(pt,'name');
    ch = get(gca,'Tag');
    
    if ~isempty(ln)
        xdata = get(ln(1),'XData');
        
        if length(ln)~=1
            
            for j = 1:length(ln)
                yd = get(ln(j),'ydata');
                lstk = stack(lstk,yd);
                delete(ln(j))
            end
            
        end
        
        if isempty(lstk)
            continue
        end
        
        ehnd = findobj(ax(i),'string','\diamondsuit');
        meanehnd = findobj(ax(i),'string','\bullet');
        
        mn = nanmean(lstk);
        [r,c] = size(lstk);
        
        if isin(nm,'+') % fix for grouping conditions to get correct CI
            r = r/2;
        end
        
        switch vartype
            
            case 'SD'
                userdata = [];
                Var = nanstd(lstk);
                
            case 'CI'
                userdata = [];
                Var = 1.96*nanstd(lstk)./sqrt(r);
                
            case 'CB'
                userdata = [];
                [Cc, ~,~,~,~,~,~,~,sehat_b,sehat] = bootstrap_t(lstk,1000,0.05);
                Var = Cc*sehat_b;
                %Var = Cc*sehat;
                %                 Var = Cc*nanstd(lstk)./sqrt(r);  % original
                
            case 'CB (w stats)'
                userdata = [];
                [Cc, ~,~,~,~,~,~,~,sehat_b,sehat] = bootstrap_t(lstk,1000,0.05,[nm,' ',ch]);
                Var = Cc*sehat_b; 
        end
        
        bd = get(ax(i),'buttondownfcn');
        [vr,fc] = stdpatch(xdata,mn,Var);
        
        if ~isempty(findobj(ax(i),'type','patch','facecolor',[.81 .81,.81]))    %for data that has been ensembled by subject previously
            delete(findobj(ax(i),'type','patch'))
        end
        
        mnhnd = line('parent',ax(i),'xdata',xdata,'ydata',mn,'color',[0 0 0],'linewidth',1,'buttondownfcn',bd,'tag',...
            nm,'userdata','average_line');
        
        if isin(computer,'MAC')
            pch = patch('parent',ax(i),'vertices',vr,'faces',fc,'facecolor',[.8 .8 .8],'facealpha',1,'edgecolor','none','buttondownfcn',bd,'tag',nm,'userdata',userdata); %,'userdata',evt,'tag',nm);
            
        else
            pch = patch('parent',ax(i),'vertices',vr,'faces',fc,'facecolor',[.8 .8 .8],'facealpha',.5,'edgecolor','none','buttondownfcn',bd,'tag',nm,'userdata',userdata); %,'userdata',evt,'tag',nm);
        end
        
        
        if ~isempty(ehnd)    % averages events from each trial and displays a single mean event
            tg = get(ehnd,'tag');
            if isempty(tg)
                return
            end
            
            if ~iscell(tg)
                tg = {tg};
            end
            
            tg = unique(tg);
            
            for k = 1:length(tg)
                evt = findobj(ax(i),'string','\diamondsuit','tag',tg{k});
                estk = [];
                for e = 1:length(evt)
                    plate = get(evt(e),'position');
                    
                    if plate(2)~=999
                        estk = [estk;plate];
                    end
                    
                end
                
                mpos=  mean(estk);
                
                switch vartype
                    
                    case 'SD'
                        spos = nanstd(estk);
                        
                    case {'CI','CB'} % can't make bands out of discrete points
                        spos = 1.96*nanstd(estk)./sqrt(r);
                        
                end
                
                hold(ax(i),'on')
                
                errorbar(mpos(1),mpos(2),spos(2),'parent',ax(i),'LineWidth',1.12) % mean event has special width
                
                %--horizontal error bar---
                starthor = mpos(1) - spos(1);
                endhor = mpos(1) + spos(1);
                x = (starthor:1:endhor);
                y = mpos(2)*ones(size(x));
                line(x,y,'parent',ax(i),'LineWidth',1.1)
                
                text('parent',ax(i),'position',[round(mpos(1)) mpos(2)],...
                     'tag',[tg{k},'_av_',nm],'string','\bullet','FontSize',10,'verticalalignment','middle','horizontalalignment','center',...
                    'color',[1 0 0],'buttondownfcn',get(ax(i),'buttondownfcn'),'userdata',mnhnd);
            
            end
            
            delete(ehnd);
        end
        
        
        if ~isempty(meanehnd)   % averages each subject average event and displays a single mean event
            
            delete(findobj(ax(i),'type','line','linewidth',1.1));
            tg = unique(get(meanehnd,'tag'));
            
            for k = 1:length(tg)
                evt = findobj(ax(i),'string','\bullet','tag',tg{k});
                estk = [];
                for e = 1:length(evt)
                    plate = get(evt(e),'position');
                    estk = [estk;plate];
                end
                
                mpos=  mean(estk);
                spos = std(estk);
                
                text('parent',ax(i),'position',mpos,...
                    'tag',tg{k},'string','\bullet','FontSize',10,'verticalalignment','middle','horizontalalignment','center',...
                    'color',[1 0 0],'buttondownfcn',get(ax(i),'buttondownfcn'),'userdata',mnhnd); %[0.2 0.6 0.2]
                hold(ax(i),'on')
                errorbar(mpos(1),mpos(2),spos(2),'parent',ax(i),'LineWidth',1.1)
                
                
                %--horizontal error bar---
                starthor = mpos(1) - spos(1);
                endhor = mpos(1) + spos(1);
                x = (starthor:1:endhor);
                y = mpos(2)*ones(size(x));
                line(x,y,'parent',ax(i),'LineWidth',1.1)
                
                
            end
            
            delete(meanehnd);
            
        end
        
    end
    
end


function ensembledatabysubject(vartype)

s = slash;
ax = findensobj('axes');


% try to find subject name prefix
%
ln = findobj(ax(1),'type','line','linewidth',.5);

t = get(ln(1),'UserData');
if isin(t,'subject')
    str = 'subject';
    add = 7;
elseif isin(t,'P')
    str = 'P';
    add = 1;
else
    prompt={'Enter the subject prefix:'};
    name='subject prefix';
    numlines=1;
    defaultanswer={'subject'};
    
    str=inputdlg(prompt,name,numlines,defaultanswer);
    str = str{1};
    add = length(str);
end


for i = 1:length(ax)
   
    ln = findobj(ax(i),'type','line','linewidth',.5);

    
    % Extract all subject names
    %
    stk = zeros(length(ln),1);
    ecell = cell(1,length(ln));
    
    for a = 1:length(ln)  % figure out number of subjects
        fl = get(ln(a),'UserData');
        
        [pth,file] = fileparts(fl);
        subindx = strfind(pth,str);
        
        if length(subindx) > 1  % probably the last one is best
            subindx = subindx(end);
        end
        
        slashindx = strfind(fl(subindx:end),s);
        stk(a) = str2double(fl(subindx+add:subindx+slashindx(1)-2));
        ecell{a} = fl(subindx+add:subindx+slashindx(1)-2);
    end
    
    subjectnums = unique(ecell) ;
    
    pt = get(ax(i),'parent');       %parent of axis is figure
    nm = get(pt,'name');
    
    ehnd = findobj(ax(i),'string','\diamondsuit');   % find all events
    ln = findobj(ax(i),'type','line','linewidth',.5); % find all lines
    
    mnstk =[];
    ststk = [];
    
    for k = 1:length(subjectnums)    %-------------ensemble lines----------------
        
        dstk = [];
        
        for j = 1:length(ln)
            if ~isempty(strfind(get(ln(j),'UserData'),[str,subjectnums{k}]))
                indx =strfind(get(ln(j),'UserData'),[str,subjectnums{k}]);
                flnm = get(ln(j),'UserData');
                disp(['stacking ', flnm(indx:end)])
                %                 disp(['stacking ', get(ln(j),'UserData')])
                yd = get(ln(j),'ydata');
                dstk = stack(dstk,yd);
            end
        end
        disp('--------')
        
        if isempty(dstk)
            continue
        end
        
        [r,c] = size(dstk);
        
        if r ~=1
            mn = nanmean(dstk);
            
            switch vartype
                
                case 'SD'
                    st = nanstd(dstk);
                    
                case 'CI'
                    st = nanstd(dstk)./sqrt(r);
                    
                case 'CB'
                    [~, ~, Cc] = bootstrap_lenhoff(dstk,1000,0.05);
                    st = Cc*nanstd(lstk)./sqrt(r);
                    
                case 'SCI'
                    st = nanstd(dstk)./sqrt(r);
            end
            
        else
            mn = dstk;
            st = zeros(r,c);
        end
        
        mnstk = stack(mnstk, mn);              %mean data for each subject
        ststk = stack(ststk, st);
        
    end
    
    ehnd = findobj(ax(i),'string','\diamondsuit');
    ehndcopy = ehnd;
    
    if ~isempty(ehnd)
        tg = unique(get(ehnd,'tag'));
        
        all_msub_xstk = [];
        all_stdsub_xstk = [];
        all_msub_ystk = [];
        all_stdsub_ystk = [];
        
        for k = 1:length(subjectnums)   % ensemble events vents
            
            subxstk=[];
            subystk=[];
            
            for m = 1:length(tg)
                xstk = [];
                ystk =[];
                
                for c=1:length(ehnd)
                    if  strcmp(get(ehnd(c),'tag'),tg{m})==1 % is event of the right type
                        
                        if ~isempty(strfind(get(get(ehnd(c),'UserData'),'UserData'),[str,subjectnums{k}])); % if correct subject
                            disp(['for file:', get(get(ehnd(c),'UserData'),'UserData')])
                            disp('event')
                            pos = get(ehnd(c),'position');
                            xstk = [xstk ; pos(1)];
                            ystk = [ystk ; pos(2)];
                        end
                    end
                end
                subxstk = [subxstk xstk]; % stacks all events of a single subject: columns events, rows trials
                subystk = [subystk ystk]; % stacks all events of a single subject: columns events, rows trials
            end
            
            msubxstk = mean(subxstk,1);
            stdsubxstk = std(subxstk,1);
            
            msubystk = mean(subystk,1);
            stdsubystk = std(subystk,1);
            
            all_msub_xstk = [all_msub_xstk; msubxstk];          %stack of all means of xdata for each subject
            all_stdsub_xstk = [all_stdsub_xstk; stdsubxstk];
            all_msub_ystk = [all_msub_ystk; msubystk];
            all_stdsub_ystk = [all_stdsub_ystk; stdsubystk];
        end
        
    end
    
    delete(ln)      %delete once all lines have been collected
    delete(ehnd)
    
    %----------plot average lines and standard deviation-------------------
    
    for b = 1:length(subjectnums)
        bd = get(ax(i),'buttondownfcn');
        [vr,fc] = stdpatch(mnstk(b,:),ststk(b,:));
        pch = patch('parent',ax(i),'vertices',vr,'faces',fc,'facecolor',[.81 .81,.81],'facealpha',.5,'edgecolor','none','buttondownfcn',bd,'userdata',[],'tag',['subject',subjectnums{b},'/',nm,'std']);
    end
    
    for c = 1:length(subjectnums)
        mnhnd=line('parent',ax(i),'xdata',(0:length(mnstk(c,:))-1),'ydata',mnstk(c,:),'color',[0 0 0],'linewidth',0.5,'buttondownfcn',bd,'tag',['subject',subjectnums{c},'/',nm],'userdata',[]);
        
        if ~isempty(ehndcopy)
            for e=1:length(tg)
                text('parent',ax(i),'position',[all_msub_xstk(c,e) all_msub_ystk(c,e)] ,...
                    'tag',[tg{e},'_average'],'string','\bullet','FontSize',10,'verticalalignment','middle',...
                    'horizontalalignment','center','color',[1 0 0],'buttondownfcn',get(ax(i),'buttondownfcn'),...
                    'userdata',mnhnd);
                hold(ax(i),'on')
                errorbar(all_msub_xstk(c,e), all_msub_ystk(c,e), all_stdsub_ystk(c,e),'parent',ax(i),'LineWidth',1.1,...
                    'Tag',tg{e})
                
                
                %--horizontal error bar---
                starthor = all_msub_xstk(c,e) - all_stdsub_ystk(c,e);
                endhor = all_msub_xstk(c,e) + all_stdsub_ystk(c,e);
                x = (starthor:1:endhor);
                y = all_msub_ystk(c,e)*ones(size(x));
                line(x,y,'parent',ax(i),'LineWidth',1.1,'Tag',tg{e})
                
                
            end
        end
        
    end
    
end


function axisid(id)


if nargin==0 || isempty(id)
    id = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','(h)','(i)','(j)','(k)','(l)','(m)','(n)','(o)','(p)','(q)','(r)','(s)','(t)','(u)'};
end

sfigs = findall(gcf,'type','axes');

indx = 0;
xposstk = [];
yposstk = [];

for i = 1:length(sfigs)
    
    if ~isin(get(sfigs(i),'Tag'),'legend') && ~isempty(get(sfigs(i),'UserData'))
        indx = indx+1;
        
        pos = get(sfigs(i),'Position');   % actual axes
        xpos = pos(1);
        ypos = pos(2);
        
        xposstk = [xposstk; xpos];
        yposstk = [yposstk; ypos];
        
    end
end

rows  = unique(yposstk);
rows = sort(rows,'descend');
cols = unique(xposstk);

nrows  = length(rows);
ncols = length(cols);

count = 1;

for j = 1:nrows
    
    for k=1:ncols
        
        pos = [cols(k) rows(j)];
        
        for m = 1:length(sfigs)
            
            if ~isin(get(sfigs(i),'Tag'),'legend')
                
                sfigpos = get(sfigs(m),'Position');
                sfigpos = sfigpos(1:2);
                if sfigpos == pos
                    axes(sfigs(m))
                    
                    xlim = get(sfigs(m),'Xlim');
                    ylim = get(sfigs(m),'YLim');
                    %                     xr = round(range(xlim)*0.05);
                    xr = round(range(xlim)*0.005);
                    yr = round(range(ylim)*0.08);
                    
                    text(xlim(1)+xr,ylim(2)+yr,id{count},'fontWeight','bold');
                    
                end
                
            end
            
        end
        
        count = count+1;
    end
    
end


function r = findfigure(fl,fig)
r = [];
for i = 1:length(fig)
    nm = get(fig(i),'name');
    if isgoodfile(fl,nm)
        r = [r;fig(i)];
    end
end


function vec = getspacing(num,axwid,sp,figlength)

if ischar(sp)
    s = (figlength-(num*axwid))/(num+1);
    vec = zeros(1,num);
    vec(:) = s;
else
    lsp = length(sp);
    if num < lsp
        vec = sp(1:num);
    elseif num == lsp
        vec = sp;
    else
        vec = zeros(1,num);
        vec(1:lsp) = sp;
        vec(lsp+1:end) = sp(lsp);
    end
end


function buttondown
hnd = gcbo;

switch get(gcf,'selectiontype')
    
    case 'open'
        
        allhnd = findobj('type',get(gcbo,'type'),'tag',get(gcbo,'tag'));
        switch get(hnd,'type')
            case 'axes'
                clr = get(gcbo,'color');
                nclr = colorpallete(clr);
                set(allhnd,'color',nclr);
            case 'line'
                clr = get(gcbo,'color');
                nclr = colorpallete(clr);
                set(allhnd,'color',nclr);
            case 'stdev'
                clr = get(gcbo,'facecolor');
                nclr = colorpallete(clr);
                set(allhnd,'facecolor',nclr);
        end
        
    case 'normal'
        
        if ischar(get(gcbo,'userdata'))
            txt = findensobj('prompt',gcf);
            set(txt,'string',get(gcbo,'userdata'));
            set(findobj('string','\diamondsuit'),'color',[1 0 0]); % set back to red
            set(findobj('type','line'),'color',[0 0 0]); % set back to red
            
            ax = findobj(gcf,'type','axes');
            for i = 1:length(ax)
                
                if ~isin( get(ax(i),'tag'),'legend')  
                    set(findobj(ax(i),'type','hggroup'),'LineStyle','-')
                end
                
            end
            
            if ~isin(get(hnd,'type'),'hggroup')
                set(gcbo,'color',[0 0 .98])
            else
                set(gcbo,'LineStyle',':')
            end
            
        elseif isnumeric(get(gcbo,'userdata'));
            
            if strcmp(get(gcbo,'type'),'patch') || strcmp(get(gcbo,'type'),'axes')
                return
            end
            
            txt = findensobj('prompt',gcf);
            set(txt,'string',get(gcbo,'tag'));
            %  set(findensobj('highlight'),'color',[0 0 0]);
            
            set(findobj('string','\bullet'),'color',[1 0 0]);
            set(findobj('string','\diamondsuit'),'color',[1 0 0]);
            set(findobj('type','line'),'color',[0 0 0]); % set back to red
            
            set(gcbo,'color',[0 0 .98])
            %   set(findobj('userdata',gcbo),'color',[0 0 .98]);
        end
end


function normdata(type)

%--To plot only norm data from scratch
%
axes = findobj(gcf,'type','axes');
tax = get(axes(1),'Children'); %

if isempty(tax)
    id = blanknorm(type);
end


%----find normative figure data
%
sl = slash;
root = which('ensembler');
indx = strfind(root,sl);
nroot = root(1:indx(end-1)-1);
n = [nroot,sl,'Gait',sl,'Walking norm data',sl];

col =[.8 .8 .8];

speed = 'Free'; % for Scwartz only

figs = findobj('type','figure');

for j = 1:length(figs)
    
    figure(figs(j))
    name = get(gcf,'Name');
    axes = findobj(gcf,'type','axes');
    
    switch type
        
        case 'Schwartz Kinematics'
            
            n = [n,'Schwartz',sl];
            foot_off = 59;
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'APelvicTilt_AntPost')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Sagittal Angles (deg)','Post (-)  Ant (+)'})
                    title({'Pelvis',' '})
                    
                elseif isin(tag,'AHip_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext (-)   Flex (+)')
                    title({'Hip',''})
                    
                elseif  isin(tag,'AKnee_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext (-)  Flex (+)')
                    title({'Knee',''})
                    
                elseif  isin(tag,'AAnkle_DfPf')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Pla (-) Dor(+)')
                    title({'Ankle',' '})
                    
                    
                elseif isin(tag,'APelvicObliquity_UpDn')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Coronal Angles (deg)','Down (-) Up (+)'})
                    title('')
                    
                elseif isin(tag,'APelvicRotation_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Transverse Angles (deg)','Ext Rot (-)  Int Rot (+)'})
                    title('')
                    
                    
                    
                elseif isin(tag,'AHip_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abd (-)   Add (+)')
                    title('')
                    
                elseif isin(tag,'AHip_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext Rot (-)  Int Rot (+)')
                    title('')
                    
                    
                    
                elseif  isin(tag,'AKnee_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abd (-)   Add (+)')
                    title('')
                    
                elseif  isin(tag,'AKnee_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Ext Rot (-)  Int Rot (+)')
                    title('')
                    
                    
                    
                elseif  isin(tag,'AFootProgress_IntExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Foot Progress Angle (deg)';'Ext Rot (-)  Int Rot (+)'})
                    title('')
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
            
            
        case 'Schwartz Kinetics'
            
            n = [n,'Schwartz',sl];
            foot_off = 59;
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'MHip_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Moment (Nm/kg)';'Flex (-)   Ext (+)'})
                    title({'Hip',''})
                    
                elseif  isin(tag,'MKnee_FlexExt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Flex (-)  Ext (+)')
                    title({'Knee',''})
                    
                elseif  isin(tag,'MAnkle_DfPf')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Dor (-) Pla (+)')
                    title({'Ankle',''})
                    
                elseif isin(tag,'MHip_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Moment (Nm/kg)','Add (-)   Abd (+)'})
                    title('')
                    
                elseif  isin(tag,'MKnee_AddAbd')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Add (-)   Abd (+)')
                    title('')
                    
                elseif  isin(tag,'PHip')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Power (W/kg)';'Abs (-)  Gen (+)'})
                    title(' ')
                    
                elseif  isin(tag,'PKnee')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abs (-)  Gen (+)')
                    title('')
                    
                elseif  isin(tag,'PAnk')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Abs (-)  Gen (+)')
                    title('')
                    
                    
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
            
            
        case 'Dixon GRF'
            
            n = [n,'Dixon2010GRF',sl];
            foot_off = 81;   % contralateral FS
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'F_ml')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    title('')
                    ylabel('Lat (-)   Med (+)')
                    
                elseif isin(tag,'F_ap')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    ylabel({'GRF (N/kg)';'Pos (-)   Ant(+)'})
                    
                    title('')
                    
                elseif  isin(tag,'F_v')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    ylabel('Up(+)')
                    title('')
                    
                elseif  isin(tag,'T_z')
                    p =load([n,tag]);
                    p =p.p.(tag);
                    ylabel({'Tz','Ext Rot (-)  Int Rot (+)'})
                    title('')
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
            
            
        case 'Schwartz EMG'
            
            n = [n ,'Schwartz',sl];
            foot_off = 59;
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'MRectusFem')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel({'Rect Fem (% Dyn Max)'})
                    title('')
                    
                elseif isin(tag,'MHamstringsLat')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    title('')
                    ylabel('Lat Ham (% Dyn Max)')
                    
                elseif isin(tag,'MHamstringsMed')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Med Ham (% Dyn Max)')
                    title('')
                    
                elseif isin(tag,'MGastrocnemiusMed')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Med Gas (% Dyn Max)')
                    title('')
                    
                elseif isin(tag, 'MTibialisAnt')
                    p =load([n,tag,'_',speed]);
                    p =p.p.(tag).(speed);
                    ylabel('Tib Ant (% Dyn Max)')
                    title('')
                    
                else
                    
                    continue
                    
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
            
            
        case 'PiG GC'   % old case to be updated
            
            n = [n ,'PiG',sl];
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                % PIG lower limbs
                
                if isin(tag,'HPA_x') || isin(tag, 'HipAngles_x')
                    p =load([n,'HipAngles_x']);
                    p =p.HipAngles_x;
                    ylabel({'Hip Angles (deg)';'Flexion (+)'})
                    
                elseif isin(tag,'HPA_y') || isin(tag, 'HipAngles_y')
                    p =load([n,'HipAngles_y']);
                    p =p.HipAngles_y;
                    ylabel('Adduction (+)')
                    
                    
                elseif isin(tag,'HPA_z') || isin(tag, 'HipAngles_z')
                    p =load([n,'HipAngles_z']);
                    p =p.HipAngles_z;
                    ylabel('Internal (+)')
                    
                elseif isin(tag, 'KNA_x') || isin(tag, 'KneeAngles_x')
                    p =load([n,'KneeAngles_x']);
                    p =p.KneeAngles_x;
                    ylabel({'Knee Angles (deg)';'Flexion (+)'})
                    
                    
                elseif isin(tag,'KNA_y') || isin(tag, 'KneeAngles_y')
                    p =load([n,'KneeAngles_y']);
                    p =p.KneeAngles_y;
                    ylabel('Varus (+)')
                    
                    
                elseif isin(tag, 'KNA_z') || isin(tag, 'KneeAngles_z')
                    p =load([n,'KneeAngles_z']);
                    p =p.KneeAngles_z;
                    ylabel('Internal (+)')
                    
                    
                elseif isin(tag, 'ANA_x') || isin(tag, 'AnkleAngles_x')
                    p =load([n,'AnkleAngles_x']);
                    p =p.AnkleAngles_x;
                    
                elseif isin(tag, 'ANA_y') || isin(tag, 'AnkleAngles_y')
                    disp('no normative data')
                    
                    
                elseif isin(tag, 'ANA_z') || isin(tag, 'AnkleAngles_z')
                    disp('no normative data')
                    
                    % ---PIG MOMENTS-----------------
                    
                elseif isin(tag, 'AnkleMoment_x')
                    p =load([n,'AnkleMoment_x']);
                    p =p.AnkleMoment_x;
                    
                elseif isin(tag, 'AnkleMoment_y')
                    disp('no normative data')
                    
                elseif isin(tag, 'AnkleMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'KneeMoment_x')
                    p =load([n,'KneeMoment_x']);
                    p =p.KneeMoment_x;
                    
                elseif isin(tag, 'KneeMoment_y')
                    p =load([n,'KneeMoment_y']);
                    p =p.KneeMoment_y;
                    
                elseif isin(tag, 'KneeMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'HipMoment_x')
                    p =load([n,'HipMoment_x']);
                    p =p.HipMoment_x;
                    
                elseif isin(tag, 'HipMoment_y')
                    p =load([n,'HipMoment_y']);
                    p =p.HipMoment_y;
                    
                    % PIG POWER----------
                    
                elseif isin(tag, 'AnklePower')
                    p =load([n,'AnklePower']);
                    p =p.AnklePower;
                    
                elseif isin(tag, 'KneePower')
                    p =load([n,'KneePower']);
                    p =p.KneePower;
                    
                elseif isin(tag, 'HipPower')
                    p =load([n,'HipPower']);
                    p =p.HipPower;
                    
                else
                    continue
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
            
            
        case 'OFM Kinematics'
            
            n = [n ,'OFM',sl];
            foot_off = 59; % assuming value for children from Sc
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag, 'HFTBA_x')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel({'Sagittal Angles (deg)','Pla (-)  Dor (+)'})
                    title({'HF/TB',' '})
                    
                elseif isin(tag, 'HFTBA_y')
                    p =load([n,tag]);
                    p =p.(tag);
                    title('')
                    ylabel({'Coronal Angles (deg)','Eve (-)  Inv (+)'})
                    
                elseif isin(tag, 'HFTBA_z')
                    p =load([n,tag]);
                    p =p.(tag);
                    title(' ')
                    ylabel({'Transverse Angles (deg)','Ext (-)  Int (+)'})
                    
                elseif isin(tag, 'FFHFA_x')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Pla (-)  Dor (+)')
                    title({'FF/HF',''})
                    
                elseif isin(tag, 'FFHFA_y')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Pro (-)  Sup (+)')
                    title('')
                    
                elseif isin(tag, 'FFHFA_z')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Abd (-)  Add (+)')
                    title('')
                    
                elseif isin(tag, 'HXFFA_x')
                    p =load([n,tag]);
                    p =p.(tag);
                    ylabel('Pla (-)  Dor (+)')
                    title({'HX/FF',''})
                    
                else
                    
                    continue
                    
                end
                
                p.x = normalizeline(p.x,101);
                p.y = normalizeline(p.y,101);
                patch(p.x,p.y,col)
                
            end
            
            
        case 'PIG Stance'  % old case to be updated
            
            % create x vector
            
            a= 0:3.3:100;
            b = fliplr(a);
            x = [a,b]';
            
            n = [n ,'PiG',sl];
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                % PIG lower limb angles
                
                if isin(tag,'HPA_x') || isin(tag, 'HipAngles_x')
                    p =load([n,'HipAngles_x']);
                    p =p.HipAngles_x;
                    
                elseif isin(tag,'HPA_y') || isin(tag, 'HipAngles_y')
                    p =load([n,'HipAngles_y']);
                    p =p.HipAngles_y;
                    
                elseif isin(tag,'HPA_z') || isin(tag, 'HipAngles_z')
                    p =load([n,'HipAngles_z']);
                    p =p.HipAngles_z;
                    
                elseif isin(tag, 'KNA_x') || isin(tag, 'KneeAngles_x')
                    p =load([n,'KneeAngles_x']);
                    p =p.KneeAngles_x;
                    
                elseif isin(tag,'KNA_y') || isin(tag, 'KneeAngles_y')
                    p =load([n,'KneeAngles_y']);
                    p =p.KneeAngles_y;
                    
                elseif isin(tag, 'KNA_z') || isin(tag, 'KneeAngles_z')
                    p =load([n,'KneeAngles_z']);
                    p =p.KneeAngles_z;
                    
                elseif isin(tag, 'ANA_x') || isin(tag, 'AnkleAngles_x')
                    p =load([n,'AnkleAngles_x']);
                    p =p.AnkleAngles_x;
                    
                elseif isin(tag, 'ANA_y') || isin(tag, 'AnkleAngles_y')
                    disp('no normative data')
                    
                elseif isin(tag, 'ANA_z') || isin(tag, 'AnkleAngles_z')
                    disp('no normative data')
                    
                    % PIG MOMENTS------------
                    
                elseif isin(tag, 'AnkleMoment_x')
                    p =load([n,'AnkleMoment_x']);
                    p =p.AnkleMoment_x;
                    
                elseif isin(tag, 'AnkleMoment_y')
                    disp('no normative data')
                    
                    
                elseif isin(tag, 'AnkleMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'KneeMoment_x')
                    p =load([n,'KneeMoment_x']);
                    p =p.KneeMoment_x;
                    
                elseif isin(tag, 'KneeMoment_y')
                    p =load([n,'KneeMoment_y']);
                    
                elseif isin(tag, 'KneeMoment_z')
                    disp('no normative data')
                    
                elseif isin(tag, 'HipMoment_x')
                    p =load([n,'HipMoment_x']);
                    p =p.HipMoment_x;
                    
                elseif isin(tag, 'HipMoment_y')
                    p =load([n,'HipMoment_y']);
                    p =p.HipMoment_y;
                    
                    % PIG POWER----------
                    
                elseif isin(tag, 'AnklePower')
                    p =load([n,'AnklePower']);
                    p =p.AnklePower;
                    
                elseif isin(tag, 'KneePower')
                    p =load([n,'KneePower']);
                    p =p.KneePower;
                    
                elseif isin(tag, 'HipPower')
                    p =load([n,'HipPower']);
                    p =p.HipPower;
                    
                else
                    continue
                end
                
                p.y = normalizeline(p.y,101);
                y1 = p.y(1:31);
                y2=p.y(72:end);
                y = [y1;y2];
                h= patch(x,y,col);
                set(h,'Tag','Norm Data');
                
            end
            
            
        case 'OFM Stance'   % old case to be updated
            a= 0:3.3:100;
            b = fliplr(a);
            x = [a,b]';
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                %OFM Angles
                
                if isin(tag, 'HFTBA_x')
                    p =load([n,'HFTBA_x']);
                    p =p.HFTBA_x;
                    
                elseif isin(tag, 'HFTBA_y')
                    p =load([n,'HFTBA_y']);
                    p =p.HFTBA_y;
                    
                elseif isin(tag, 'HFTBA_z')
                    p =load([n,'HFTBA_z']);
                    p =p.HFTBA_z;
                    
                elseif isin(tag, 'FFHFA_x')
                    p =load([n,'FFHFA_x']);
                    p=p.FFHFA_x;
                    
                elseif isin(tag, 'FFHFA_y')
                    p =load([n,'FFHFA_y']);
                    p =p.FFHFA_y;
                    
                elseif isin(tag, 'FFHFA_z')
                    p =load([n,'FFHFA_z']);
                    p =p.FFHFA_z;
                    
                elseif isin(tag, 'HXFFA_x')
                    
                    p =load([n,'HXFFA_x']);
                    p =p.HXFFA_x;
                    
                else
                    
                    continue
                    
                end
                
                p.y = normalizeline(p.y,101);
                y1 = p.y(1:31);
                y2=p.y(72:end);
                y = [y1;y2];
                h= patch(x,y,col);
                set(h,'Tag','Norm Data');
                
            end
            
            
        case {'Turning CB','Turning PB'}   % reads stored ensemble figures
            
            t = get(axes(1),'Tag');
            
            if isin(t,'Ipsi')
                pre = 'Ipsi';
            elseif isin(t,'Contra')
                pre= 'Contra';
            elseif isin(t,'Turn')
                pre = 'Turn';
                %             elseif isin(t,'L')
                %                 pre = 'Ipsi';
            else
                error('these may not be turning trials')
            end
            
            if isin(cycle,'turning CB')
                band = 'CB';
            else
                band = 'PB';
            end
            
            p =load([n,'TurningGait',sl,pre,band,'.mat']);
            p = p.p;
            
            names = fieldnames(p);
            
            c=1;
            w=1;
            
            while c ==1
                
                if isin(name,names{w})
                    p = p.(names{w});
                    c=0;
                else
                    w=w+1;
                end
                
            end
            
            for i=1:length(axes)
                
                tag = get(axes(i),'Tag');
                set(gcf,'CurrentAxes',axes(i))
                
                if isin(tag,'HPA_x')
                    x = p.([pre,'HPA_x']).x;
                    y = p.([pre,'HPA_x']).y;
                    
                elseif isin(tag,'HPA_y')
                    x = p.([pre,'HPA_y']).x;
                    y = p.([pre,'HPA_y']).y;
                    
                elseif isin(tag,'HPA_z')
                    x = p.([pre,'HPA_z']).x;
                    y = p.([pre,'HPA_z']).y;
                    
                elseif isin(tag,'KNA_x')
                    x = p.([pre,'KNA_x']).x;
                    y = p.([pre,'KNA_x']).y;
                    
                elseif isin(tag,'KNA_y')
                    x = p.([pre,'KNA_y']).x;
                    y = p.([pre,'KNA_y']).y;
                    
                elseif isin(tag,'KNA_z')
                    x = p.([pre,'KNA_z']).x;
                    y = p.([pre,'KNA_z']).y;
                    
                elseif isin(tag,'HFTBA_x')
                    x = p.([pre,'HFTBA_x']).x;
                    y = p.([pre,'HFTBA_x']).y;
                    
                elseif isin(tag,'HFTBA_y')
                    x = p.([pre,'HFTBA_y']).x;
                    y = p.([pre,'HFTBA_y']).y;
                    
                elseif isin(tag,'HFTBA_z')
                    x = p.([pre,'HFTBA_z']).x;
                    y = p.([pre,'HFTBA_z']).y;
                    
                elseif isin(tag,'FFHFA_x')
                    x = p.([pre,'FFHFA_x']).x;
                    y = p.([pre,'FFHFA_x']).y;
                    
                elseif isin(tag,'FFHFA_y')
                    x = p.([pre,'FFHFA_y']).x;
                    y = p.([pre,'FFHFA_y']).y;
                    
                elseif isin(tag,'FFHFA_z')
                    x = p.([pre,'FFHFA_z']).x;
                    y = p.([pre,'FFHFA_z']).y;
                    
                elseif isin(tag,'HXFFA_x')
                    x = p.([pre,'HXFFA_x']).x;
                    y = p.([pre,'HXFFA_x']).y;
                    
                elseif isin(tag,'HXFFA_y')
                    x = p.([pre,'HXFFA_y']).x;
                    y = p.([pre,'HXFFA_y']).y;
                    
                else
                    error('unidentified channel name')
                end
                
                
                y1 = y(1:length(y)/2);
                y2= y(length(y)/2+1:end);
                y = [y1;y2];
                h= patch(x,y,col);
                set(h,'Tag','Norm Data');
                
            end
    end
    
end


%-final spruce up
%
horline(0,'k')                                              % add horizontal line at 0
verline(foot_off,':k')                                            % add push off for free walking speed

pro = findobj('Tag','prompt');                              % remove prompt box

if ~isempty(pro)
    delete(pro)
end


for i = 1:length(axes)                                      % delete empty axes
    if isempty(get(get(axes(i),'YLabel'),'String'))
        delete(axes(i));
    end
end


pch = findobj('type','patch');                              % fix up patch properties

for j =1:length(pch)
    set(pch(j),'edgecolor','none','facealpha',0.9)
    
end


tick = 20;
xlim = get(gca,'XLim');                     % set xticks
xticks = xlim(1):tick:xlim(2);

ax = findobj('type','axes');
for i = 1:length(ax)
    set(ax(i),'XTick',xticks);
end


axisid(id)                                                      % add axis ids a,b,c,...


function id =blanknorm(type)

close all

if isin(computer,'MACI64')
    disp('using default settings for MacBook pro laptop')
    
    xwid =1.5;
    ywid = 1.5;
    xspace = 0.8;
    yspace = 0.8;
    fw = 12;
    fh = 10;
    
else
    disp('using default for PC')
    
    xwid =1.2;
    ywid = 1.2;
    xspace = 0.8;
    yspace = 0.5;
    fw = 8;
    fh = 8;
    
end



switch type
    
    case 'Schwartz Kinematics'
        
        startup('NormData',3,4,xwid,ywid,xspace,yspace,fw,fh)
        
        % list =  {'APelvicRotation_IntExt','AHip_IntExt','AKnee_IntExt','AFootProgress_IntExt',...
        %             'APelvicObliquity_UpDn','AHip_AddAbd','AKnee_AddAbd','',...
        %             'APelvicTilt_AntPost','AHip_FlexExt','AKnee_FlexExt','AAnkle_DfPf'};
        
        list =  {'AAnkle_DfPf', '' ,'AFootProgress_IntExt',...
            'AKnee_FlexExt','AKnee_AddAbd','AKnee_IntExt',...
            'AHip_FlexExt','AHip_AddAbd','AHip_IntExt',...
            'APelvicTilt_AntPost','APelvicObliquity_UpDn','APelvicRotation_IntExt'};
        
        id = {'(a)','(b)','(c)','(d)','(e)','(f)','(g)','','(h)','(i)','(j)','(k)','(l)'};
        
        
        
    case 'Schwartz Kinetics'
        
        startup('NormData',3,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'MAnkle_DfPf',' ','PAnkle','MKnee_FlexExt','MKnee_AddAbd','PKnee',...
            'MHip_FlexExt','MHip_AddAbd','PHip'};
        
        id = {'(a)','(b)','(c)','(d)','(e)','','(f)','(g)','(h)'};
        
        
    case 'Dixon GRF'
        
        startup('NormData',2,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'F_v',' ','F_ap',' ','F_ml','T_z'};
        
        id  = [];
        
    case 'Schwartz EMG'
        
        startup('NormData',2,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'MHamstringsLat',' ','MHamstringsMed','MGastrocnemiusMed','MRectusFem','MTibialisAnt'};
        
    case 'OFM Kinematics'
        
        startup('NormData',3,3,xwid,ywid,xspace,yspace,fw,fh)
        
        list = {'HXFFA_x','','','FFHFA_x','FFHFA_y','FFHFA_z','HFTBA_x','HFTBA_y','HFTBA_z'};
        
        id = {'(a)','(b)','(c)','(d)','(e)','','(f)','(g)'};
        
        
    case 'OFM Kinetics'
        list ={};
end




figs = findobj('type','figure');

for j = 1:length(figs)
    
    ax = findobj(figs(j),'type','axes');
    
    for i = 1:length(list)
        txt = get(ax(i),'title');
        set(ax(i),'tag',list{i});
        set(txt,'string',list{i})
    end
    
    dax = findobj(figs(j),'type','axes','tag','3 5');
    delete(dax)
    
end


function verline(pos,style)

if nargin==0
    
    prompt={'Line position: ', 'line style'};
    defaultanswer = {'0','k:'};
    a = inputdlg(prompt,'axis title',1,defaultanswer);
    pos = str2double(a{1});
    style = a{2};
end



ax = findobj('type','axes');

for i = 1:length(ax)
    if ~isempty(get(ax(i),'UserData'))
        axes(ax(i))
        h= vline(pos,style);
        set(h,'HandleVisibility', 'on');
        set(h,'LineWidth',0.51);
    end
end


function horline(pos,style)


if nargin==0
    prompt={'Line position: ', 'line style'};
    defaultanswer = {'0','k-'};
    a = inputdlg(prompt,'axis title',1,defaultanswer);
    pos = str2double(a{1});
    style = a{2};
end
ax = findobj('type','axes');



for i = 1:length(ax)
    
    if ~isempty(get(ax(i),'UserData'))
        axes(ax(i))
        %         set(gcf,'CurrentAxes',ax(i))
        h = hline(pos,style);
        set(h,'HandleVisibility', 'on');
        set(h,'LineWidth',0.51);
    end
end


function loaddata(fld,figs)

fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    t = load(fl{i},'-mat');
    fig = findfigure(fl{i},figs);
    disp(fl{i})
    for f = 1:length(fig)
        createlines(fig(f),t.data,fl{i});
    end
end


function loadfile(f,p,figs)

fl = [p,f];
t = load(fl,'-mat');
fig = findfigure(fl,figs);
disp(fl)

createlines(fig,t.data,fl);


function nm = partitionname(str)

indx = strfind(str,' ');

if isempty(indx)
    nm = {str};
    return
end

nm = {str(1:indx(1)-1)};

for i = 1:length(indx)
    if i == length(indx)
        plate = str(indx(end)+1:end);
    else
        plate = str(indx(i)+1:indx(i+1)-1);
    end
    if isempty(plate)
        continue
    end
    nm = [nm;{plate}];
end


function r = isgoodfile(fl,nm)

%indx = strfind(nm,'/');
indx = strfind(nm,'+');    %join search strings

if isempty(indx)
    str = nm;
    if isempty(strfind(fl,str))
        r = 0;
    else
        r = 1;
    end
else
    indx = [0,indx,length(nm)+1];
    r = 1;
    for i = 2:length(indx)
        str = nm(indx(i-1)+1:indx(i)-1);
        if isempty(strfind(fl,str))
            r = 0;
            return
        end
    end
end


function resize

ax = findobj('type','axes');
legend = findobj('type','axes','tag','legend');
ax = setdiff(ax,legend);

for a = 1:length(ax)
    
    xlabel = get(get(gca,'XLabel'),'String');
    
    max_ystk = [];
    min_ystk = [];
    
    max_xstk = [];
    min_xstk = [];
    
    max_sstk = [];
    min_sstk = [];
    
    
    if isin(xlabel,'bar graph') || isempty(get(gca,'Xtick'))
        
        bars  = findobj('Tag','ebar');        
        disp('resizing for bar graphs')
        
        for j = 1:length(bars)   % extract x-values
            
            x = get(bars(j),'XData');
            y = get(bars(j),'YData');
            u = get(bars(j),'UData'); % half width of error bar
            
            x = x(:,1);         
            y = y(:,1);
            
            if y > 0 
                y = y+u;
            else
                y = y-u;
            end
            
            x_max = max(x);
            x_min = min(x);
            
            y_max = max(y);
            y_min = min(y);
            
            max_xstk = [max_xstk x_max];
            max_ystk = [max_ystk y_max];
            
        end
        
        x_max = max(max_xstk);
        x_min = min(max_xstk);
        
        y_max = max(max_ystk);
        y_min = min(max_ystk);
        
        % set new limits
        %
        set(gca,'Xlim', [x_min-0.2*x_min x_max+0.2*x_max] )        

        if y_min > 0
            y_min = 0;
            set(gca,'Ylim', [y_min y_max+0.2*y_max] )
                        
        elseif y_max <0
            y_max = 0;
            set(gca,'Ylim', [y_min-0.2*y_min y_max] )
        end
        
       

    else    % ensembled lines
        
        xlim = get(gca,'XLim');
        x_min = xlim(1);
        x_max = xlim(2);
        
        ln = findobj(ax(a),'type','line');   % find all lines
        
        if ~isempty(ln)
            pch = findobj(ax(a),'type','patch','visible','on');
            
            for i = 1:length(ln)
                
                if ~isempty(get(ln(i),'UserData'))
                    
                    y_max = max(get(ln(i),'ydata'));
                    y_min = min(get(ln(i),'ydata'));
                    
                    x_max = max(get(ln(i),'xdata')); % all x mins should be the same
                    x_min = min(get(ln(i),'xdata')); % all x max should be the same
                    
                    max_ystk = [max_ystk y_max];
                    min_ystk = [min_ystk y_min];
                end
            end
            
            
            for j = 1:length(pch)
                
                p_max = max(get(pch(j),'YData'));
                p_min = min(get(pch(j),'YData'));
                
                max_sstk = [max_sstk p_max];
                min_sstk = [min_sstk p_min];
            end
            
            
            dmax = max([max_ystk max_sstk]);
            dmin = min([min_ystk min_sstk]);
            
            if ~isempty(dmin)
                set(ax(a),'Ylim',[dmin+0.05*dmin dmax+0.05*dmax]);
                
                
                if isin(computer,'MAC')
                    set(ax(a),'Xlim', [x_min-1 x_max+1] )  % mac fix for std patch overlap with axis
                else
                    set(ax(a),'Xlim', [x_min x_max] ) 
                end
                
                
                
                
            end
            
        end
        
        
    end
end

function clear999outliers
a = findobj('type','line');
b = findobj('String','\diamondsuit');

for i = 1:length(a)
    y = get(a(i),'YData');
    
    if mean(y) ==999
        delete(a(i))
    end
    
end

for i = 1:length(b)
    e = get(b(i),'Position');
    
    if e(2)==999
        delete(b(i))
    end
    
end

function r = stack(a,b)

if isempty(a)
    r = b;
    return
elseif isempty(b)
    r=a;
    return
end

[rr,ca] = size(a);
[rr,cb] = size(b);
if ca > cb
    b(:,cb+1:ca) = NaN;
elseif cb > ca
    a(:,ca+1:cb) = NaN;
end
r = [a;b];


function [vr,fc] = stdpatch(xd,yd,st)

if nargin == 2
    st = yd;
    yd = xd;
    xd = (1:length(yd));
end

indx = find(isnan(yd));
st(indx) = [];
yd(indx) = [];
xd(indx) = [];

nyd = makecolumn(yd-st);
pyd = makecolumn(yd+st);
xd = makecolumn(xd);
zd = zeros(size(xd))-.000001;
lyd = length(yd);

fc = [(1:lyd),(2*lyd:-1:lyd+1)];

if length(xd) ~= length(nyd)
    error('data lengths inconsistent. Check that data are normalized')
end

vr = [xd,nyd,zd];
vr = [vr;[xd,pyd,zd]];


function start

e=which('ensembler'); % returns path to ensemlber
path = pathname(e) ;  % local folder where ensembler resides

defaultvalfile = [path,'default_ensembler_values.mat'];

dval = load(defaultvalfile,'-mat');
dval = dval.a;

fstring = dval{1};
fwid = dval{2};
fheig = dval{3};
nrows = dval{4};
ncols = dval{5};
xwid = dval{6};
ywid = dval{7};
hspac = dval{8};
vspac = dval{9};

options.Resize = 'on';
a = inputdlg({'name','figure width (inches)','figure height (inches)','rows','columns','width (inches)','height (inches)','horizontal spacing (inches)','vertical spacing (inches)'},'axes',1,...
    {fstring,fwid,fheig,nrows,ncols,xwid,ywid,hspac,vspac},options);

if isempty(a)
    disp('exiting ensembler')
    return
end

save(defaultvalfile,'a')

fwid = str2double(a{2});
fheig = str2double(a{3});
nrows = str2double(a{4});
ncols = str2double(a{5});
xwid = str2double(a{6});
ywid = str2double(a{7});

if strcmp(a{8},'even')
    xspace = a{8};
else
    xspace = str2double(a{8});
end

if strcmp(a{9},'even')
    yspace = a{9};
else
    yspace = str2double(a{9});
end

nm = partitionname(a{1});

nfigs = length(nm);

for i = 1:length(nm)
    startup(nm{i},nrows,ncols,xwid,ywid,xspace,yspace,fwid,fheig,i,nfigs)
end


function update(p,f,fld)

line = findobj('type','line');

if length(line)==1
    updatefile([p,f])
else
    updatedata(fld)
end


function updatefile(fl)

delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('string','\diamondsuit'))

t = load(fl,'-mat');
fig = gcf;
createlines(fig,t.data,fl);


function updatedata(fld)

delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('string','\diamondsuit'));
%--reload-----
loaddata(fld,findobj('type','figure'));
clear999


function setaxes(prop)

ax = findensobj('axes',gcf);

switch prop
    
    case 'ylimmode'
        str2 = {'manual','auto'};
        
    case 'ylim'
        ylim = get(ax,'ylim');
        if ~iscell(ylim)
            ylim = {ylim};
        end
        
        m = cell2mat(ylim);
        ylim = [ylim;{[min(min(m)),max(max(m))]}];
        for i = 1:length(ylim)
            str2{i} = num2str(ylim{i});
        end
        
    case 'xlim'
        xlim = get(ax,'xlim');
        if ~iscell(xlim)
            xlim = {xlim};
        end
        
        m = cell2mat(xlim);
        xlim = [xlim;{[min(min(m)),max(max(m))]}];
        for i = 1:length(xlim)
            str2{i} = num2str(xlim{i});
        end
        
    case 'xlimmode'
        str2 = {'manual','auto'};
    case 'xtickmode'
        str2 = {'none','auto'};
    case 'ytickmode'
        str2 = {'none','auto'};
end

tg = get(ax,'tag');
if ~iscell(tg)
    tg = {tg};
end
a = associatedlg(tg,str2);

for i = 1:length(a(:,1))
    if strcmp(prop,'xtickmode') && strcmp('none',a{i,2})
        aprop = 'xtick';
        aval = [];
    elseif strcmp(prop,'ytickmode') && strcmp('none',a{i,2})
        aprop = 'ytick';
        aval = [];
    elseif strcmp(prop,'ylim') || strcmp(prop,'xlim')
        aprop = prop;
        aval = str2double(a{i,2});
    else
        aprop = prop;
        aval = a{i,2};
    end
    ax = findobj('type','axes','tag',a{i,1});
    set(ax,aprop,aval);
end


function hnd = findensobj(action,varargin)

switch action
    case 'figure'
        hnd = findobj('type','figure');
    case 'axes'
        if nargin == 2
            hnd = setdiff(findobj(varargin{1},'type','axes'),findobj(varargin{1},'type','axes','tag','legend'));
        else
            hnd = setdiff(findobj(findensobj('figure'),'type','axes'),findobj(findensobj('figure'),'type','axes','tag','legend'));
        end
    case 'prompt'
        hnd = findobj(varargin{1},'tag','prompt','style','text');
    case 'highlight'
        hnd = findobj('type','line','color',[0 0 .98]);
end


function keypress

s = slash;

switch get(gcf,'currentkey')
    
    
    
    case 'delete'
        
        %--------------choose what happens when you press delete----
        
        button = questdlg('do you want to delete the entire file, a selected channel or just clear the selected line from display', ...
            'Deletion Options',...
            'Delete File', 'Delete Channel','Clear Single Channel','Clear Single Channel');
        
        
        Tag = get(gca,'Tag');
        hnd = findensobj('prompt',gcf);
        fl = get(hnd,'string');
        indx = strfind(fl,s);
        indx = indx(end-2);
        
        
        switch button
            
            case 'Delete File'
                
                ln = findobj('type','line');
                
                for i=1:length(ln)
                    if strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                delfile(fl);    %deletes entire file
                
                evt = findobj('string','\diamondsuit');
                
                if ~isempty(evt)
                    for i = 1:length(evt)
                        if get(evt(i),'UserData')==gco
                            delete(evt(i))
                        end
                    end
                end
                
                
            case 'Delete Channel'   %delete a single channel
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if isin(get(get(ln(i),'Parent'),'Tag'),Tag) && strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                ch = get(gca,'Tag');
                disp(['deleting ch: ',ch,'from ',fl(indx+1:end)])
                
                data = zload(fl);
                data.(ch).line = 999*ones(length(data.(ch).line),1);
                
                evts = fieldnames(data.(ch).event);
                
                for j = 1:length(evts)
                    data.(ch).event.(evts{j})=[1 999 0];
                end
                
                save(fl,'data');
                
%                 updatedata(fld)
                
            case 'Clear All Channels'
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
                disp(['line cleared from display only for ',fl])
                
            case 'Clear Single Channel'
                
                ln = findobj(gcf,'type','line');
                
                for i=1:length(ln)
                    if isin(get(get(ln(i),'Parent'),'Tag'),Tag) && strcmp(get(ln(i),'UserData'),fl)==1
                        delete(ln(i));
                    end
                end
                
        end
        
end


function ensembler_normalize(fld,datalength)

fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = load(fl{i},'-mat');
    disp(['normalizing:',fl{i}]);
    data = data.data;
    data = normalizedata(data,datalength);
    save(fl{i},'data');
end





