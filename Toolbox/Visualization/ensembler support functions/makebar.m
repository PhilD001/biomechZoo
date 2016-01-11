
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
        resize_ensembler % make a first attempt at resizing
        delete(hnd)
        
    end
  
end

