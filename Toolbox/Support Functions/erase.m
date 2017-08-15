function erase(style)

%erases std lines in figures


if nargin ==0
    style = 'none';
end


pch = findobj('type','patch');
set(pch,'facecolor','none','edgecolor',[0 0 0],'linestyle',style);