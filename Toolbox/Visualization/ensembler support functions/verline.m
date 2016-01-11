function verline(pos,style)

if nargin==0
    
    prompt={'Line position: ', 'line style'};
    defaultanswer = {'0','k:'};
    a = inputdlg(prompt,'axis title',1,defaultanswer);
    pos = str2double(a{1});
    style = a{2};
end



ax = findobj('type','axes');

for i = 1:length(ax)
    if ~isempty(get(ax(i),'UserData'))
        axes(ax(i))
        h= vline(pos,style);
        set(h,'HandleVisibility', 'on');
        set(h,'LineWidth',0.51);
    end
end

