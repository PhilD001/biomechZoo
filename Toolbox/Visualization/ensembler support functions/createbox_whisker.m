function stop_load = createbox_whisker(fig,data,fl,settings)

% stop_load = CREATEBOX_WHISKER(fig,data,fl,settings) used by ensembler GUI to 
% plot box and whiskers in each axis

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
ydata = [];

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
        
        ydata = cat(1, ydata, data.(ch).line); 
       
        offset = 0;

        
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
        
        hold(ax,'on')
        box_whisker = boxchart(ax, ydata);
        hold(ax,'off')
        
        evt = fieldnames(data.(ch).event);
        for e = 1:length(evt)
            text('parent',ax,'position',[data.(ch).event.(evt{e})(1)+offset data.(ch).event.(evt{e})(2)],...
                'tag',evt{e},'string',settings.string,'verticalalignment',settings.verticalalignment,...
                'horizontalalignment',settings.horizontalalignment,'color',settings.color,...
                'FontSize',settings.FontSize,'buttondownfcn',get(ax,'buttondownfcn'),'userdata',box_whisker);
        end
        
    else
        ensembler_msgbox(fld,'Current channel not found in zoo files')
    end
end
