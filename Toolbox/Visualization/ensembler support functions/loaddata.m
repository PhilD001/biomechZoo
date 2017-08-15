function loaddata(fld,figs,settings)

% LOADDATA(fld,figs,settings) loads line and event data into ensembler


% Updated by Philippe C. Dixon Sept 2016
% - edited for faster reading
%
% Updated by Philippe C. Dixon Nov 2016
% - outliers are automatically cleared
%
% Updated by Philippe C. Dixon August 2017
% - Changes to work with new message box feature at the bottom of main
%   ensembler window


fl = engine('path',fld,'extension','zoo');

if isempty(fl)
    ensembler_msgbox(fld,'No zoo files found')
end

for i = 1:length(fl)
    data = zload(fl{i});                             % load zoo data
    fig = findfigure(fl{i},figs);                    % find in which figure it belongs
    batchdisp(fl{i},'loading')                       % keep old version also
    stop_load = createlines(fig,data,fl{i},settings);           % draw line
    
    if stop_load
        break
    end
end

%ensembler('clear outliers')
%ensembler_prompt(fld,true)

