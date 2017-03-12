function font_change(mode)

% FONT_CHANGE(mode) increases or decreases current font size of ensembler figure
%
% ARGUMENTS
%  mode       ....   flag to 'increase' or 'decrease' font size


inc = 2; % increment for next font size
figs = findobj('type','figure');
a = findall(figs,'-property','FontSize');
currentFont = get(a(1),'FontSize');


switch mode
    
    case 'increase'
        newFont = currentFont + inc;
        
    case 'decrease'
        newFont = currentFont - inc;

        
end

set(findall(figs,'-property','FontSize'),'FontSize',newFont) 
