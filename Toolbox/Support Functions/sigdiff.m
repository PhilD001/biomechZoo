function sigdiff

% SIGDIFF displays a beautiful significant difference 'star' in graphs
% based on latex code


x = mean(get(gca,'XLim'));
y = mean(get(gca,'YLim'));

set(gcf,'defaulttextinterpreter','latex');
text(x,y,'$\vdash \star \dashv $','FontName','Arial','FontSize',18)