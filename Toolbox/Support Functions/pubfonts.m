function pubfonts(FontSize,FontWeight,FontName)

% changes fonts to good fonts for publication or latex
%
% The default weight and name are probably best. The size might be changed. For consistency all parts of figure
% should have similar font style
%
%
%
%
%
% Created November 2013 by Philippe C. Dixon


%--Prompt for settings
%

if nargin==0
    prompt={'FontSize','FontWeight','FontName'};
    
    defaultanswer = {'14','normal','Arial'};
    
    a = inputdlg(prompt,'axis title',1,defaultanswer);
    
    FontSize = str2double(a{1});
    FontWeight = a{2};
    FontName = a{3};
    
end

figs = findobj('type','figure');


for i = 1:length(figs)
    
    ax = findobj(figs(i),'type','axes');
    txt = findobj(figs(i),'type','text');
    
    for j = 1:length(txt)
        
        
        if  isin(get(get(txt(j),'Parent'),'Tag'),'legend')          % Legend entries
            set(txt(j),'FontSize',FontSize-2)
            
        elseif isin(get(txt(j),'String'),':')                       % Condition comparison box
            set(txt(j),'FontSize',FontSize-2)
            
            
        else                      % Figure ids a),b),c)
            set(txt(j),'FontSize',14)
            
        end
        
        set(txt(j),'FontWeight',FontWeight)
        set(txt(j),'FontName',FontName)
        
        
    end
    
    
    
    
    
    for k = 1:length(ax)
        
        if length(get(get(ax(k),'YLabel'),'String')) ==1    % these are colar bar labels A, B, C
            
            set(get(ax(k),'YLabel'),'FontSize',FontSize-2)
            
        else
            
            set(get(ax(k),'YLabel'),'FontSize',FontSize)
            
        end
        
        set(get(ax(k),'YLabel'),'FontWeight',FontWeight)
        set(get(ax(k),'YLabel'),'FontName',FontName)
        set(get(ax(k),'Title'),'FontSize',FontSize)
        set(get(ax(k),'Title'),'FontWeight',FontWeight)
        
    end
    
    
    
end