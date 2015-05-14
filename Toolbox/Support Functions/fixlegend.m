function fixlegend

% This function reorders legend entries in a given .fig file. To reorder
% change line 16

% Fix legend entries in a figure


% get the figure handle
h = gcf; % or whatever fig
% get the axes handle
a = get(h, 'CurrentAxes')
% get the handles for children of the axes -- these are the data series handles
c = get(a, 'Children')
% generate a legend command using these "children"
legend(c([4 2 3 1]), 'IRU', 'IRD', 'LR','SD of LR') 