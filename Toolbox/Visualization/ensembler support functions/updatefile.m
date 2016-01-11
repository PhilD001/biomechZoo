function updatefile(fl)

delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('string','\diamondsuit'))

t = load(fl,'-mat');
fig = gcf;
createlines(fig,t.data,fl);