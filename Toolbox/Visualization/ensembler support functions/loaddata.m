function loaddata(fld,figs)

% LOADDATA(fld,figs) loads line and event data into ensembler

fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    t = load(fl{i},'-mat');
    fig = findfigure(fl{i},figs);
    disp(fl{i})
    for f = 1:length(fig)
        createlines(fig(f),t.data,fl{i});
    end
end