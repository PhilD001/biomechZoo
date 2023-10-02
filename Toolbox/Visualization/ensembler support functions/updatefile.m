function updatefile(fl,settings,color)

delete(findobj('type','line'));
delete(findobj('type','patch'));
delete(findobj('type','rectangle'));
delete(findobj('type','legend'));
delete(findobj('type','bar'));
delete(findobj('type','ErrorBar'));
delete(findobj('string','\bullet'));

t = load(fl,'-mat');
fig = gcf;
createlines(fig,t.data,fl,settings,color);