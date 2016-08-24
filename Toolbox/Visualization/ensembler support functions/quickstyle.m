function quickstyle

% QUICKSTYLE quickly sets line style to some defaults. Useful if running
% many graphs. Default styles can be modified to suit user preferences


% NOTES
% - code currently works with designs where there are at most three conditions with
% at most three levels:
% e.g. 'down+pro', down+old','down+young','up+pro','up+old','up+young',
%       'straight+pro', straight+old','straight+young'
% - the '1st' condition will see different line colors, while the '2nd'
%   condition will have the line style changed

% Settings
%
LineWidth = 1.5;
Colors = {'b','r','k'};
Styles = {'-','-.',':'};


% Get lines
%
ln = findobj('type','line');
lnstk = zeros(length(ln),1);

for i = 1:length(ln)
    if isin(get(ln(i),'UserData'),'average_line')
        lnstk(i) = ln(i);
    end
end

zindx = find(lnstk~=0);
lnstk = lnstk(zindx);


% modify line width
%
set(lnstk,'linewidth',LineWidth);            % set linewidth


% Modify colors and styles
%
tg = get(findobj(gcf,'type','line'),'tag');
tg = unique(tg);


if isin(tg{1},'+')
    
    con1 = {};
    con2 = {};
    
    for i = 1:length(tg)
        tag = tg{i};
        indx = strfind(tag,'+');
        con1{i} = tag(1:indx-1);
        con2{i} = tag(indx+1:end);
    end
    
    con1 = unique(con1);
    con2 = unique(con2);
    
    
    for i = 1:length(con1)
        
        for j = 1:length(lnstk)
            
            if isin(get(lnstk(j),'tag'),con1{i})
                set(lnstk(j),'LineStyle',Styles{i})
                
            end
        end
        
    end
    
    
    for i = 1:length(con2)
        
        for j = 1:length(lnstk)
            
            if isin(get(lnstk(j),'tag'),con2{i})
                set(lnstk(j),'Color',Colors{i})
                
            end
        end
        
    end
    
    
    
    
    
else
    
    con = {};
    
    for i = 1:length(tg)
        con = tg{i};
    end
    
    con = unique(con);
    
    for j = 1:length(lnstk)
        
        if isin(get(lnstk(j),'tag'),con{i})
            set(lnstk(j),'Color',Colors{i})
            
        end
    end
    
end


