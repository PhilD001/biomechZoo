function stop_load = createlines(fig,data,fl,settings,color)

% stop_load = CREATELINES(fig,data,fl,settings) used by ensembler GUI to 
% plot lines in each axis


% Revision history
%
% Updated by Philippe C. Dixon July 2016
% - commented code using Video Indx to draw lines
%
% Updated by Philippe C. Dixon Nov 2016
% - code is more efficient (faster)
%
% Updated by Philippe C. Dixon Dec 2016
% - improved handling of empty axes
%
% Updated by Philippe C. Dixon August 2017
% - Changes to work with new message box feature at the bottom of main
%   ensembler window

% Set Defaults for ensembler events
%
stop_load = false;

if nargin==3
    settings = ensembler_settings;
end

axs = findobj(fig,'type','axes');

% get current working directory from msg box
%
mbox = findobj('tag','messagebox');
string = get(mbox,'string');
fld = strrep(string{2},'working directory: ','');

for j = 1:length(axs)
    ch = get(axs(j),'tag');
    
    if ~isempty(ch) && isempty(strfind(ch,' '))
            
        if ~isfield(data,ch)             
            mbox = findobj('tag','messagebox');
            string = get(mbox,'string');
            fld = strrep(string{2},'working directory: ','');
            msg = ['channel ''',ch,''' does not exist in file'];  
            ensembler_msgbox(fld,msg);
            pause(1e-6)
            continue
        end
        
        ax = findobj(fig,'type','axes','tag',ch);
        
        ydata = data.(ch).line;       
        xdata = (0:length(data.(ch).line)-1);
        
        offset = 0;
        
        xdata = makecolumn(xdata);
       
        [~,c] = size(ydata);
        
        if isempty(c)
            error('no line data available')
        elseif c==3
             msg = ['n x 3 channels must be separated (exploded) into n x 1 channels. ',...
                    'Select Processing --> explode channels'];  
            ensembler_msgbox(fld,msg) 
            stop_load = true;
            return
        end

        set(ax,'XLim',[-inf inf]);
        set(ax,'YLim',[-inf inf]);
    
        if isempty(color)
            color = settings.regularLineColor;
        end

        ln = line('parent',ax,'ydata',ydata,'xdata',xdata,'userdata',fl,...
            'buttondownfcn',get(ax,'buttondownfcn'),'LineWidth',settings.regularLineWidth,...
             'color',color);
      
        evt = fieldnames(data.(ch).event);
        for e = 1:length(evt)
            text('parent',ax,'position',[data.(ch).event.(evt{e})(1)+offset data.(ch).event.(evt{e})(2)],...
                'tag',evt{e},'string',settings.string,'verticalalignment',settings.verticalalignment,...
                'horizontalalignment',settings.horizontalalignment,'color',settings.color,...
                'FontSize',settings.FontSize,'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
        end
        
    else
        ensembler_msgbox(fld,'Current channel not found in zoo files')
    end
end

% OLD CODE (SLOW)
%
% for j = 1:length(ch)
%     ax = findobj(fig,'type','axes','tag',ch{j});
%     if isempty(ax)
%         continue
%     end
%
%     ydata = data.(ch{j}).line;
%     xdata = (0:length(data.(ch{j}).line)-1);
%     offset = 0;
%
%     xdata = makecolumn(xdata);
%
%     [~,c] = size(ydata);
%
%     if c~=1
%         error('data must be n x 1 for graphing, explode first')
%     end
%
%     ln = line('parent',ax,'ydata',ydata,'xdata',xdata,'userdata',fl,...
%         'buttondownfcn',get(ax,'buttondownfcn'));
%
%     evt = fieldnames(data.(ch{j}).event);
%     for e = 1:length(evt)
%         text('parent',ax,'position',[data.(ch{j}).event.(evt{e})(1)+offset data.(ch{j}).event.(evt{e})(2)],...
%             'tag',evt{e},'string',settings.string,'verticalalignment',settings.verticalalignment,...
%             'horizontalalignment',settings.horizontalalignment,'color',settings.color,...
%             'FontSize',settings.FontSize,'buttondownfcn',get(ax,'buttondownfcn'),'userdata',ln);
%     end
%
% end