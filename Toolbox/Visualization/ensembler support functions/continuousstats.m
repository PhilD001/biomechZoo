function continuousstats(fld,check)

% CONTINUOUSSTATS is a standalong function to perform Bootstrap analysis
% on curve data within ensembler

% Updated by Philippe C. Dixon March 2016
% - fixed compatibility issues with r2014b and above (ln 65-76)
%
% Updated by Philippe C. Dixon June 2016
% - fixed further compatibility isses with r2014b and above
% - patch visualization problems on mac platform (<r2014b) persist
% - code functions without any bugs on windows platform using <r2014b 

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
            [maxvalstk(i),temp,multstk(i)] = getMaxVal(fld,ch,alpha,ax(i),nboots,check);
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
    
    colormap(jet(256));  %uses the jet color map with 256 smooth color changes
    dummyax = axes('units','inches','position',[10,1,1,1],'Visible','off');
    
    if verLessThan('matlab','8.4.0')    % execute code for R2014a or earlier
        colorbar('peer',dummyax,'location','EastOutside');
    else
        colorbar('location','EastOutside');
    end
    caxis([0 maxval])

    %--textbox containing info----
    
    tx = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N'};
    
    %stk = [];
    stk = cell(length(compcons),1);
    
    for i = 1:length(compcons)
        comp = compcons{i};
        comp = strrep(comp,'_',' ');
        stk{i} = [tx{i},': ',comp];
        %stk = [stk; plate];
    end
    
    %thnd = text(0,0.4,{stk});
    % Set current axes to colorbar to make sure text appears close to
    % where you might want it
    
    g_ax = findobj('type','line');
    g_ax = get(g_ax(1),'Parent');
    
    axes(g_ax)
    
    thnd = text(0,0.4,stk);
    set(thnd,'Tag','cstatsbox')
    
end