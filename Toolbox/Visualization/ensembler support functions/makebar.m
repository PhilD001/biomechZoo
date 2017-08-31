function makebar

% MAKEBAR creates bar graphs from ensembler figures


% Revision History
%
% Updated by Philippe C. Dixon March 2016
% - compatible with r2014b +
%
% Updated by Philippe C. Dixon Jan 2017
% - updated to work with the new resize_ensembler
%
% Updated by Philippe C. Dixon May 2017
% - updated to work with improved GUI settings


figs = findobj('type','axes');

for f = 1:length(figs)
    
    ax = findobj(figs(f),'type','axes');
    
    lg=0; %don't draw legend
    
    for i = 1:length(ax)
        
        if verLessThan('matlab','8.4.0')
            ebar = findobj(ax(i),'type','line','linewidth',1.12);
        else
            ebar = findobj(ax(i),'LineWidth',1.12);
        end
        
        if isempty(ebar)
            continue
        else
            ehnd = findobj(ax(i),'type','text');
            
            lns = findobj(ax(i),'type','line');
            ln = [];
            
            for j = 1:length(lns)
                if isin(get(lns(j),'UserData'), 'average_line')
                    ln = [ln; lns(j)];
                end
            end
            
            barvaluestk = ones(size(ehnd));
            groupnames = cell(size(ehnd));
            
            for j = 1:length(ehnd)
                barvalue = get(ehnd(j),'Position');
                barvaluestk(j) = barvalue(2);
                groupnames{j} = get(ehnd(j),'Tag');
            end
            
            errorstk =[];
            if verLessThan('matlab','8.4.0')
                for m=1:length(ebar)
                    errors = get(ebar(m),'YData');
                    if length(errors)~=1
                        errorstk = [errorstk; abs(errors(1)-errors(2))/2];
                    end
                end
                
            else
                for m=1:length(ebar)
                    errorstk = [errorstk;  get(ebar(m),'LData')];
                end
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
        resize_ensembler(ax(i)) % make a first attempt at resizing
        delete(hnd)
        
    end
    
end

