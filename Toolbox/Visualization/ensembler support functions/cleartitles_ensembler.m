function cleartitles_ensembler

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