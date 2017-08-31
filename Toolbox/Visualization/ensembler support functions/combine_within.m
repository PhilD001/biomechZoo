function combine_within(settings)

% combine_within used to combine different axes with full freedom. Great for comparing
% different computations within a condition. e.g. knee angles grood suntay vs
% knee angles helical

% NOTES
% - needs to be updated to append info to moved line for use with legend_within

fig = findobj('type','figure');

prmt = findobj('Tag','prompt');

if ~isempty(prmt)
    set(prmt,'string','')
end

for j = 1:length(fig)
    
    ax = findensobj('axes',fig(j));
    tg = get(findobj(gcf,'type','axes'),'tag');
    tg = setdiff(tg,{''});
        
    if j==1
        a = associatedlg(tg,tg);
    end
    
    [r,~] = size(a);
    
    if r==1
        axh = findobj(fig(j),'type','axes','tag',a{1,1});
        axm = findobj(fig(j),'type','axes','tag',a{1,2});
        
        ln = findobj(axm,'type','line');
        pch = findobj(axm,'type','patch');                    % patches
        txt = findobj(axm,'string',settings.string);          % line events
        mtxt = findobj(axm,'string',settings.ensstring);      % mean event
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
            txt = findobj(axm,'string',settings.string);       % line events
            mtxt = findobj(axm,'string',settings.ensstring);   % mean event
            ebar = findobj(axm,'type','errorbar');              % event error bars
            set(ln,'parent',axh);
            set(pch,'parent',axh);
            set(txt,'parent',axh);
            set(mtxt,'parent',axh);
            set(ebar,'parent',axh);

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

