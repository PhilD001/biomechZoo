

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

