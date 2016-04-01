function continuousstats(fld,check)

% CONTINUOUSSTATS is a standalong function to perform Bootstrap analysis
% on curve data within ensembler

% Updated by Philippe C. Dixn March 2016
% - fixed compatibility issues with r2014b and above (ln 65-76)


resize_ensembler   % if there are blank 'x' data continuous stats will fail

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
    
     if verLessThan('matlab','8.4.0')    % execute code for R2014a or earlier
        cbar = colorbar('peer',dummyax,'location','NorthOutside');
        set(cbar,'XTickLabel',[])
        set(cbar,'YTickLabel',[])
    else
        cbar = colorbar('location','NorthOutside');
        set(cbar,'YTickLabel',[])
        set(cbar,'TickLabels',[])
    end
    
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