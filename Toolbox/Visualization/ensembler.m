function ensembler(action)
%
% ENSEMBLER is the main graphical user interface (GUI) for the zoosystem
% Time-series data can be graphed by group/channel.
%
% QUICK GUIDE
% - The user can change groupings by entering appropriate fields in the 'name'
%   section of the dialog box. These names should correspond to folder names
%   in the user's databa
% - Individual axes must be tagged to list a given channel before accepting line data
%
%
% EXAMPLES
%   e.g.1 There are two groups: 'elite' and 'rec' performing a task. Typing 'elite rec'
%   in the 'name' section at startup will create two windows allowing the user to graph
%   all files in 'elite' folder together and all files in 'rec' together. A space must
%   separate input strings.
%
%   e.g.2 There are two groups 'elite' and 'rec' performing two conditions
%   'slap' and 'wrist' (ice hockey shot styles). Typing 'elite+slap elite+wrist rec+slap rec+wrist'
%   will create 4 windows. Each window will collect all files containing both input strings.
%
% NOTES
% - Ensembler can also ensemble event data. Ensembled events may not "sit" on the mean
%   line due to standard deviation of their respective indices, i.e. different trials may
%   have different index for a common event
% - There are known functionality issues graphing patches (e.g. standard deviation cloud)
%   on Mac OSX platforms
% - There are known functionality issues with errorbars on Matlab version 2014a and up
% - Functions tested on v2012a on MAC OS 10.8.6 and Windows 7
% - Users wishing to use the exact version described in the biomechZoo
%   manuscript can download the original code on github

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
% - improved handling of bar graphs
% - changed interpreter for title to 'none' to display underscore character
% - bar graphs can be reordered (see case 'reorder bars')
%
% Updated by Philippe C. Dixon Nov 2015
% - fixed bug in resize function for use with non-normalized data
%
% Updated by Philippe C. Dixon Dec 2015
% - fixed bug with 'coupling angles' function
% - improved 'clear all' function
% - Moved all embedded functions in main ensembler code to stand-alone
%   functions now found in ~\Visualization\ensembler support functions
% - removed relative phase functionality
%
% Updated by Philippe C. Dixon March 2016
% - new GUI controls for font size (increase or decrease), editing of figure name
% - improved buttondown behavior
% - improved associate dialog box
%
% Updated by Philippe C. Dixon June 2016
% - Small bug fix to ylabel code for support of color bars in ensembler
%
% Updated by Philippe C. Dixon Feb 2017
% - possibility to set font type and size from original ensembler prompt
%   (saved in 'default_ensembler_values.mat')
%
% Updated by Philippe C. Dixon August 2017
% - Changes to work with new message box feature at the bottom of main
%   ensembler window
%
% Updated by Philippe C. Dixon November 2017
% - bug fix for turning on/off SD visibility on all open figures
%
% Updated by Philippe C. Dixon December 2017
% - bug fix which caused emsembler exit to exit all figures including
% director

% ================= BEGIN SETUP ======================================
%
% - Initiates ensembler
% - set up global variables

if nargin == 0
    action = 'start';
end

global fld                              % give every case access to fld
global f p                              % give every case acces to [p,f]
global combine chartType chartColor

% default settings look for ensembler objects
settings = ensembler_settings; 

curAx = ensembler_axis_highlight(false);       % reset axis highlight

ensembler_msgbox(fld)                 % print message to user

% ensembler_processing(fld)           % record processing steps to txt file

% get(curAx,'title')

%================== BEGIN CASE STATEMENTS ============================
%
% - Each 'icon' in the ensembler menu bar calls one of the case
%   statements listed below

switch action
    
    case 'start'
        start_ensembler
        
    case 'restart'
        close all
        start_ensembler
    
    case {'save process record','load process record','run process record'}
         %ensembler_msgbox(fld,['Figure exported to: ',concatEnsPrompt(filename)])
         ensembler_msgbox('feature not yet supported')

    case 'add gait events'
        if isempty(fld)
            ensembler('set working directory')
        end
        
        bmech_gaitevents(fld)
        update_ensembler_lines(p,f,fld,settings)
        
    case 'add manual event'
        ch = get(get(curAx,'Title'),'String');
        add_manualevent(ch)
        update_ensembler_lines(p,f,fld,settings)
        
    case {'add min event','add max event','add ROM event'}
        ch = get(get(curAx,'Title'),'String');
        evt = strrep(action,'add ','');
        evt = strrep(evt,' event','');
        
        lines = findobj('type','line','LineWidth',0.5);
        nlines = length(lines);
        
        if nlines ==1
            fl= get(lines,'userdata');           % this is the line handle
            data = zload(fl);
            data = addevent_data(data,ch,evt,evt);
            zsave(fl,data);
        else
            bmech_addevent(fld,ch,evt,evt)
        end
        
        update_ensembler_lines(p,f,fld,settings)
        
    case 'add start trial event'
        ch = get(get(curAx,'Title'),'String');
        add_manualevent(ch,'start')
        update_ensembler_lines(p,f,fld,settings)
        
    case 'add end trial event'
        ch = get(get(curAx,'Title'),'String');
        add_manualevent(ch,'end')
        update_ensembler_lines(p,f,fld,settings)
        
    case 'add other channel event'
        addotherchannelevent(fld,settings)
        
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
        
    case 'color'
        ax = findobj(gcf,'type','axes');
        lg = findobj(gcf,'type','axes','tag','legend');
        ax = setdiff(ax,lg);
        
        if verLessThan('matlab','8.4.0')    % execute code for R2014a or earlier
            tg = get(findobj(ax,'type','hggroup'),'tag');
        else
            if contains(chartType, 'whisker')
                % tg = get(findobj('type','rectangle'),'tag');
                tg = {'BarChart'};
            elseif contains(chartType, 'violin')
                tg = get(findobj('type','patch'),'tag');
            elseif contains(chartType, 'bar')
                tg = get(findobj('type','bar'),'tag');
            end
        end
        
        tg = setdiff(tg,'ebar');
        
        col = colorlist;
        a = associatedlg(tg,col(:,1)');
        
        for i = 1:length(a(:,1)) 
            indx = ismember(col(:,1),a{i,2})==1;
            ccol = col(indx,2);
            ccol = ccol{1};
            chartColor = ccol;
        end
        
        if combine
            uncombineData();
            combine = 1;
            updatedatabar_charts(fld,settings,combine, chartType, chartColor)
            combineData();
        else
            updatedatabar_charts(fld,settings,combine, chartType, chartColor)
        end
        
    case 'buttondown'
        buttondown(settings)
        
    case 'check continuous stats'
        continuousstats(fld,'check')
        
    case 'clear outliers'
        clear999outliers(settings)
        resize_ensembler
        ensembler_msgbox(fld,'Outliers cleared')
        
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
        
        % remove existing legend
        %
        if verLessThan('matlab','8.4.0')
            lhnd = findobj(gcf,'type','axes','tag','legend');
        else
            lhnd = findobj(gcf,'type','legend');
        end
        
        if ~isempty(lhnd)
            delete(lhnd)
            return
        end
        
        % reset xaxis label
        for i = 1:length(ax)
            set(ax(i), 'XAxis', matlab.graphics.axis.decorator.NumericRuler)
            set(ax(i),'XTick',[0 0.5 1])
            set(ax(i),'XTickLabel',[0 0.5 1]')
            set(ax(i),'XLim',[0 1])
            set(ax(i),'XTickLabelMode','auto')
            set(ax(i),'XLimMode','auto')
            set(ax(i),'XTickMode','auto')
            set(get(ax(i),'XLabel'),'String','')
            set(get(ax(i),'YLabel'),'String','')
        end
        
        ensembler_msgbox(fld,'Data cleared')
        
    case 'clear colorbars'
        clearcolorbars
        
    case 'clear all events'
        delete(findobj('string',settings.string));
        ensembler_msgbox(fld,'All events cleared')
        
    case 'clear event by type'
        evthnd = findobj('string',settings.string);
        evts =unique(get(evthnd,'Tag'));
        indx = listdlg('promptstring','choose your event type to clear','liststring',evts);
        
        evt = evts(indx);
        for i = 1:length(evthnd)
            ename = get(evthnd(i),'Tag');
            if ismember(ename,evt)
                delete(evthnd(i))
            end
        end
        
    case 'clear prompt'
        prmt = findobj('Tag','prompt');
        
        if ~isempty(prmt)
            set(prmt,'string','')
        end
    
        
     case {'bar graph (SD)', 'bar graph (CI)', 'violin graph', 'box whisker'}
        chartType = action;        
        
        if combine
            uncombineData();
            combine = 1;
            updatedatabar_charts(fld, settings, combine, chartType, chartColor)
            combineData();
        else
            updatedatabar_charts(fld, settings, combine, chartType, chartColor)
        end
        ensembler_msgbox(fld,[chartType, ' created'])    
        
    case 'uncombine'
        combine = 0;
        uncombineData();
        if ~strcmp(chartType, 'line')
            updatedatabar_charts(fld, settings, combine, chartType, chartColor)
        end
        
    case 'combine'
        if strcmp(chartType, 'line')
            
            % error check for combining without ensembling first
            if isempty(findobj('LineWidth', settings.ensembledLineWidth))
                ensembler_msgbox(fld, 'ERROR: Ensemble lines before combining')
                error('Ensemble lines before combining')
            else
                combine = 1;
                combineDataForLine(settings);
                combineData();
            end
        else
            uncombineData();
            combine = 1;
            updatedatabar_charts(fld, settings, combine, chartType, chartColor)
            combineData();
        end
        ensembler_msgbox(fld,'Data combined')
        
    case 'combine all'
        combine_all
        ensembler_msgbox(fld,'Data combined')
        
    case 'combine within'
        combine_within(settings)
        ensembler_msgbox(fld,'Data combined')
        
    case 'counttrials'
        counttrials
        
    case 'continuous stats'
        continuousstats(fld,[])
        
    case 'convert to zoo'
        
        if isempty(fld)
            c3d2zoo
        else
            c3d2zoo(fld)
        end
        
    case 'coupling angles'
        coupling_angles(fld)
        
    case 'custom'
        prompt={'Enter the name of your processing m-file: '};
        defaultanswer = {'bmech_'};
        custom_function = inputdlg(prompt,'axis title',1,defaultanswer);
        custom_function = custom_function{1};
        run(custom_function)
        if isin(custom_function,'bmech_')
            update_ensembler_lines(p,f,fld,settings)
        end
        
    case 'datacursormode off'
        datacursormode off
        
    case 'clear titles'
        cleartitles_ensembler
        ensembler_msgbox(fld,'Titles cleared')
        
    case 'clear all empty axes'
        clearallaxes
        ensembler_msgbox(fld,'Empty axes cleared')
        
    case 'delete single axis'
        disp('select axes to delete')
        delete(curAx)
        ensembler_msgbox(fld,'Axis deleted')
        
    case 'delete all events'
        ch = get(get(curAx,'Title'),'String');
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
            bmech_removeevent(fld,'all')
        end
        
        update_ensembler_lines(p,f,fld,settings)
        
    case 'delete event by type'
        ch = get(get(curAx,'Title'),'String');
        lines = findobj('type','line','LineWidth',0.5);
        nlines = length(lines);
        evthnd = findobj('string',settings.string);
        evts =unique(get(evthnd,'Tag'));
        indx = listdlg('promptstring','choose your event type to delete','liststring',evts);
        
        if nlines ==1
            a={evts(indx)};
            
            fl= get(lines,'userdata');           % this is the line handle
            data = zload(fl);
            for e = 1:length(a)
                data = removeevent_data(data,a{e},ch);
            end
            save(fl,data);
        else
            a=evts(indx);
            bmech_removeevent(fld,a,ch)
        end
        
        update_ensembler_lines(p,f,fld,settings)
        
    case 'delete single event'
        ch = get(get(curAx,'Title'),'String');
        evthnd = gco;
        evt = get(evthnd,'Tag');
        lnhnd = get(evthnd,'userdata');           % this is the line handle
        fl = get(lnhnd,'UserData');
        
        data = zload(fl);
        data = removeevent_data(data,evt,ch);
        zsave(fl,data);
        
        update_ensembler_lines(p,f,fld,settings)
        
    case 'ensemble data (SD)'
        ensembledata('SD',settings)
        ensembler_prompt(fld,true)
        ensembler_msgbox(fld,'Data ensembled with standard deviations')
        
    case 'ensemble data (CI)'
        ensembledata('CI',settings)
        ensembler_prompt(fld,true)
        ensembler_msgbox(fld,'Data ensembled with confidence intervals')
        
    case 'ensemble data (CB)'
        ensembledata('CB',settings)
        ensembler_prompt(fld,true)
        ensembler_msgbox(fld,'Data ensembled with confidence bands')
        
    case 'ensemble (subject x conditon) (SD)'
        ensembledatabysubject('SD',settings)
        ensembler_prompt(fld,true)
        ensembler_msgbox(fld,'Data ensembled')
        
    case 'ensemble (subject x conditon) (CI)'
        ensembledatabysubject('CI',settings);
        ensembler_prompt(fld,true)
        ensembler_msgbox(fld,'Data ensembled')
        
    case 'exit'
        delete(findensobj('figure','KeyPressFcn','ensembler(''keypress'')'))
        disp('ensembler GUI closed')
        
    case 'explode channels'
        
        if fld==0
            ensembler('set working directory')
        end
        ax = findobj(gcf,'type','axes');
        ch = cell(size(ax));
        for i = 1:length(ax)
            ch{i} = get(ax(i),'tag');
        end
        bmech_explode(fld,ch)
        ensembler_msgbox(fld,'Channels exploded, retag ensembler axes with exploded axes')
        
    case {'export','export figure'}
        prmt = findobj('tag','prompt');
        msg = findobj('tag','messagebox');
        
        set(prmt,'string','')
        set(msg,'string','','backgroundcolor',get(gcf,'color'));
        filename = exportfig;
        set(msg,'backgroundcolor',[0.5 0.5 0.5])
        ensembler_msgbox(fld,['Figure exported to: ',concatPrompt(filename)])
        
    case 'export event data'
        ensembler_eventval(fld,settings)
       
        
    case 'filter'
        ax = findobj('type','axes');
        ch = cell(size(ax));
        for i = 1:length(ax)
            ch{i} = get(ax(i),'tag');
        end
        ch = unique(ch);
        
        prompt={'type','pass','freq','order'} ;
        name='Filter settings';
        numlines=1;
        defaultanswer={'butterworth','lowpass','10','4'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        
        filt = struct;
        filt.type = answer{1};
        filt.pass = answer{2};
        filt.cutoff = str2double(answer{3});
        filt.order = str2double(answer{4});
        
        bmech_filter(fld,ch,filt)
        update_ensembler_lines(p,f,fld,settings)
        
    case 'fixcolorbar'
        fixcolorbar
        
    case 'gait ylabels'
        gaitylabels
        
    case 'gc labels'
        gclabels
        
    case 'horizontal line'
        horline
        
    case 'increase fonts'
        font_change('increase')
        
    case 'decrease fonts'
        font_change('decrease')
        
    case 'vertical line'
        verline
        
    case 'keypress'
        keypress_ensembler(fld,settings);
        
    case 'legend'
        prmt = findobj('Tag','prompt');
        
        if ~isempty(prmt)
            delete(prmt)
        end
        
        % remove existing legend
        %
        if verLessThan('matlab','8.4.0')
            lhnd = findobj(gcf,'type','axes','tag','legend');
        else
            lhnd = findobj(gcf,'type','legend');
        end
        
        if ~isempty(lhnd)
            delete(lhnd)
            return
        end
        
        ax = findobj(gcf,'type','axes');% find existing axes
        lnOther = findobj(ax(1),'type','line','UserData',[]);  % get lines
        
        if verLessThan('matlab','8.4.0')
            lnAll =  findobj(ax(1),'type','line');
            ln = setdiff(lnAll,lnOther);
            barr = flipud(findobj(ax(1),'type','hggroup','ShowBaseLine','on'));
        else
            lnAll =  findobj(ax(1),'type','line');
            ln = setdiff(lnAll,lnOther);
            barr = flipud(findobj(ax(1),'type','bar'));
        end
        
        if ~isempty(ln)
            tg = cell(size(ln));
            for i = 1:length(ln)
                tg{i} = get(ln(i),'Tag');
            end
            
        else
            tg = cell(size(barr));
            for i = 1:length(barr)
                tg{i} = get(barr(i),'Tag');
            end
        end
        
        rg = 1:1:length(tg);
        a = associatedlg(tg,{rg});
        val = a(:,1);
        
        hnd = zeros(length(val),1);
        for i = 1:length(val)
            if ~isempty(barr)
                hnd(i) = findobj(ax(1),'tag',val{i});
            else
                hnd(i) = findobj(ax(1),'tag',val{i},'type','line');
            end
        end
        
        % display order
        indx = zeros(length(a),1);
        
        for i = 1:length(val)
            indx(i) = str2double(a{i,2});
        end
        
        val = val(indx);
        hnd = hnd(indx);
        
        legend(hnd,val,'interpreter','none','units','inches');
        ensembler_msgbox(fld,'Legend added to figure')
        
    case 'legend within'
        prmt = findobj('Tag','prompt');
        
        if ~isempty(prmt)
            delete(prmt)
        end
        
        % remove existing legend
        %
        if verLessThan('matlab','8.4.0')
            lhnd = findobj(gcf,'type','axes','tag','legend');
        else
            lhnd = findobj(gcf,'type','legend');
        end
        
        if ~isempty(lhnd)
            delete(lhnd)
            return
        end
        
        % find existing axes
        ax = findobj(gcf,'type','axes');
        
        % find lines
        ln = findobj(ax(1),'type','line');
        badln = findobj(ax(1),'type','line','tag','hline');
        ln = setdiff(ln,badln);
        userData = get(ln(1),'UserData');
        
        if ~isempty(strfind(userData,'average_line'))
            tg = cell(length(ln),1);
            for i = 1:length(ln)
                ud = get(ln(i),'UserData');
                ud = strrep(ud,'average_line ','');
                tg{i} = ud;
            end
        end
        
        pch = findobj(ax(1),'type','patch');
        for i = 1:length(pch)
            ud = get(pch(i),'UserData');
            ud = strrep(ud,'average_','');
            tg{end+i} = ud;
        end
        
        rg = 1:1:length(tg);
        a = associatedlg(tg,{rg});
        val = a(:,1);
        
        hnd = zeros(length(val),1);
        
        for i = 1:length(val)
            if strfind(val{i},'SD')
                hnd(i) = findobj(ax(1),'userdata',['average_',val{i}],'type','patch');
            else
                hnd(i) = findobj(ax(1),'userdata',['average_line ',val{i}],'type','line');
            end
        end
        
        % display order
        indx = zeros(length(a),1);
        
        for i = 1:length(val)
            indx(i) = str2double(a{i,2});
        end
        
        val = val(indx);
        hnd = hnd(indx);
        
        legend(hnd,val,'interpreter','none','units','inches')
        
    case 'line graph'
        chartType = 'line';
        LineColor = settings.regularLineColor;
         if combine
            uncombineData();
            combine = 1;
            update_ensembler_lines(p,f,fld,settings, LineColor)
            combineDataForLine(settings);
        else
            update_ensembler_lines(p,f,fld,settings, LineColor)
         end
        ensembler_msgbox(fld,'Line chart updated')

    case 'line style'
        tg = get(findobj(gcf,'type','line'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'-','--',':','-.','none'});
        for i = 1:length(a(:,1))
            ln = findobj('type','line','tag',a{i,1});
            set(ln,'linestyle',a{i,2});
        end
        ensembler_msgbox(fld,'Line properties updated')
        
    case 'line style within'
        tg = get(findobj(gcf,'type','axes'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'-','--',':','-.','none'});
        for i = 1:length(a(:,1))
            ax = findobj('type','axes','tag',a{i,1});
            ln = findobj(ax,'type','line');
            set(ln,'linestyle',a{i,2});
        end
        ensembler_msgbox(fld,'Line properties updated')
        
    case 'line width'
        tg = get(findobj(gcf,'type','line'),'tag');
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'.5','1','1.5','2','2.5','3'});
        for i = 1:length(a(:,1))
            ln = findobj('type','line','tag',a{i,1});
            set(ln,'linewidth',str2double(a{i,2}));
        end
        ensembler_msgbox(fld,'Line properties updated')
        
    case 'line color'
        tg = get(findobj(gcf,'type','line'),'tag');
        tg = setdiff(tg,{''});
        col = colorlist;
        a = associatedlg(tg,col(:,1));
        for i = 1:length(a(:,1))
            ln = findobj('type','line','tag',a{i,1});
            [~,indx] = ismember(a{i,2},col(:,1));
            set(ln,'color',col{indx,2});
            chartColor = col{indx, 2};
        end
        ensembler_msgbox(fld,'Line properties updated')
        
    case 'line color within'
        tg = get(findobj(gcf,'type','axes'),'tag');
        tg = setdiff(tg,{''});
        col = colorlist;
        a = associatedlg(tg,col(:,1)');
        for i = 1:length(a(:,1))
            ax = findobj('type','axes','tag',a{i,1});
            ln = findobj(ax,'type','line');
            [~,indx] = ismember(a{i,2},col(:,1));
            set(ln,'color',col{indx,2});
        end
        ensembler_msgbox(fld,'Line properties updated')
        
    case 'load data'
        if fld==0
            ensembler('set working directory')
        elseif isempty(fld)
            ensembler('set working directory')
        end
        chartType = 'line';
        update_ensembler_lines(p,f,fld,settings,chartColor)
        zoom out
        resize_ensembler
        
    case 'load single file'
        %         delete(findobj('type','line'));
        %         delete(findobj('type','patch'));
        %         delete(findobj('string',settings.textstring));
        
        [f,p] = uigetfile('*.zoo','select zoo file');
        loadfile(f,p,findobj('type','figure'));
        ensembler_msgbox(fld,[f,' loaded'])
        
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
        defaultanswer = {'101'};
        datalength = str2double(inputdlg(prompt,'axis title',1,defaultanswer));
        ax = findobj('type','axes');
        ch = cell(size(ax));
        for i = 1:length(ax)
            ch{i} =  get(ax(i),'tag');
            set(ax(i),'XLim',[0 datalength])
        end
        ch(cellfun(@isempty,ch)) = [];
        ch = unique(ch);
        bmech_normalize(fld,ch,datalength)
        
        update_ensembler_lines(p,f,fld,settings)
        
    case 'partition'
        prompt={'Enter name of start event: ', 'Enter name of end event'};
        evt = inputdlg(prompt,'axis title',1);
        bmech_partition(fld,evt(1),evt(2))
        update_ensembler_lines(p,f,fld,settings)
        
        
    case 'property editor on'
        propertyeditor('on')
        set(gcf,'resize','on')
        
    case 'property editor off'
        propertyeditor('off')
       
    case 'resize'
        set(gcf,'resize','on')

    case 'quickedit'
        quickedit(fld)
        
    case 'quick style'
        quickstyle
        
    case 'relative phase'
        disp('this process is not currently available')
        %relative_phase('load')
        
    case 'retag'
        fig = gcf;
        ax = findobj(fig,'type','axes');
        tg = get(ax,'tag');
        if ~iscell(tg)
            tg = {tg};
        end
        [f,p] = uigetfile({'*.zoo';'*.c3d'},'choose your zoo channels');
        
        if strfind(f,'.c3d')
            msg = ['files must be converted to .zoo for use in ensembler, ',...
                'select Processing-->convert to zoo and retry'];
            ensembler_msgbox(fld,msg)
            return
        end
        
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
        resize_ensembler
        
    case 'resize subfigure'
        resizesub
        
    case 'reorder bars'
        reorder_bars
        
    case 'set working directory'
        fld = uigetfolder;
        if fld==0
            ensembler_msgbox('','no folder selected')
        else
            cd(fld)
            ensembler_msgbox(fld)
        end
       
    case 'save fig'
        filemenufcn(gcbf,'FileSaveAs')
        
    case 'sig diff star'
        sigdiff
        
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
        for i = 1:length(a(:,1))
            ax = findobj('type','axes','tag',a{i,1});
            pch = findobj(ax,'type','patch');
            set(pch,'FaceColor',a{i,2},'FaceAlpha',0.1);
        end
        
    case 'stdline'
        tg = get(findobj(gcf,'type','patch'),'tag');
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
        tg = setdiff(tg,{''});
        a = associatedlg(tg,{'.1','.2','.3','.4','.5','.6','.7','.8','.9','1'});
        for i = 1:length(a(:,1))
            pch = findobj('type','patch','tag',a{i,1});
            set(pch,'facealpha',str2double(a{i,2}));
        end
        
    case 'std on off'
        tg = get(findobj('type','patch'),'tag');
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
        set(get(curAx,'Title'),'String',a)
        set(curAx,'Tag',a{1})
        
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
            set(get(curAx,'XLabel'),'String',a)
        end
        
        if r==2
            set(get(curAx,'XLabel'),'String',a)
        end
        
    case 'xlim'
        setaxes('xlim');
        
    case 'xticks'
        prompt={'Enter the tick width'};
        a = inputdlg(prompt,'axis ticks',1);
        tick = str2double((a{1}));
        
        xlim = get(curAx,'XLim');
        xticks = xlim(1):tick:xlim(2);
        
        ax = findobj('type','axes');
        for i = 1:length(ax)
            set(ax(i),'XTick',xticks);
        end
        
    case 'yticks'
        prompt={'Enter the tick width'};
        a = inputdlg(prompt,'axis ticks',1);
        tick = str2double((a{1}));
        
        xlim = get(curAx,'YLim');
        xticks = xlim(1):tick:xlim(2);
        
        set(curAx,'YTick',xticks)
        
    case 'xlimit'
        prompt={'Enter the lower limit of the axis: ',...
            'Enter the upper limit of the axis): '};
        
        default = get(curAx,'YLim');
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
            
            if ~isempty(get(ax(i),'YLabel')) && ~isin(get(get(ax(i),'Title'),'Units'),'data')
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
            set(get(curAx,'YLabel'),'String',a)
        end
        
        if r==2
            set(get(curAx,'YLabel'),'String',a)
        end
        
    case 'ylim'
        setaxes('ylim');
        
    case 'ylimit'
        
        
        prompt={'Enter the lower limit of the axis: ',...
            'Enter the upper limit of the axis): '};
        
        default = get(curAx,'YLim');
        defaultstr = {num2str(default(1)),num2str(default(2))};
        a = inputdlg(prompt,'axis limits',1,defaultstr);
        
        lower = str2double(a{1});
        upper = str2double(a{2});
        set(curAx,'YLim',[lower upper])
        
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
        defaultanswer = strjoin(get(findobj('type','figure'),'name'),' ');
        sstr=inputdlg(prompt,name,numline,{defaultanswer});
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
        
        a{1} = sstr; %#ok<NASGU>
        
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




