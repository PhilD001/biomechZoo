function sigdiff(x,y,FontName,FontSize)

% SIGDIFF(x,y,FontName,FontSize) displays a beautiful significant difference 'star' 
% in graphs based on latex style code
%
% ARGUMENTS
%  x        ... x coordinate of star (double). Default midpoint of axis
%  y        ... y coordinate of star. Default midpoint of axis
%  FontName ... Name of font (string). Default 'Arial'
%  FontSize ... Size of font (integer).Default 18


% Check arguments/set defaults
%
if nargin==0
    x = mean(get(gca,'XLim'));
    y = mean(get(gca,'YLim'));
    FontName = 'Arial';
    FontSize = 18;
end

% add star
%
set(gcf,'defaulttextinterpreter','latex');
text(x,y,'$\vdash \star \dashv $','FontName',FontName,'FontSize',FontSize,'interpreter','latex')
set(gcf,'defaulttextinterpreter','none');
