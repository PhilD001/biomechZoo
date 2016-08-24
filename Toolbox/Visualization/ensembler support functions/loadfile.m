function loadfile(f,p,figs)

fl = [p,f];
t = load(fl,'-mat');
fig = findfigure(fl,figs);
disp(fl)

createlines(fig,t.data,fl);
