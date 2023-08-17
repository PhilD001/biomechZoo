function loaddatabox_whisker(fld,figs,settings)

% LOADDATABOX_WHISKER(fld,figs,settings) loads box and whisker data into ensembler

fl = engine('path',fld,'extension','zoo');

if isempty(fl)
    ensembler_msgbox(fld,'No zoo files found')
end

for i = 1:length(fl)
    data = zload(fl{i});                                       % load zoo data
    fig = findfigure(fl{i},figs);                              % find in which figure it belongs
    batchdisp(fl{i},'loading')                                 % keep old version also
    stop_load = createbox_whisker(fig,data,fl{i},settings);    % draw box whisker
    
    if stop_load
        break
    end
end