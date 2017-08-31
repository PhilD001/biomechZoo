function list = colorlist(col)

% list = colorlist(col) is a function used my ensembler to provide a list of
% colors in the associate color menus of the GUI
%
% ARGUMENTS
%  col    ...    color name. 
%
% RETURNS
%  list   ...   list of color codes or individual color code associated
%               with color name col
%
% NOTES
% - A great guide to optimal colors, options might be implemented in future: 
%  http://ksrowell.com/blog-visualizing-data/2012/02/02/optimal-colors-for-graphs/


% Updated by Philippe C. Dixon August 22nd 2017
% - can be used with input argument to return color code



list = {'red', [204 37 41]/255;                % red
    'blue', [0 0 1];                   % blue
    'green', [0 1 0];                  % green
    'yellow', [1 1 0];                 % yellow
    'magenta', [1 0 1];                % magenta
    'cyan', [0 1 1];                   % cyan
    'black', [0 0 0];                  % black
    'dark red',[1 0 0.2];              % dark red
    'light red',[1 0.4 0.4];           % light red
    'dark blue',[0     0     0.70];    % dark blue
    'light blue',[0.20  0.60  1.00];   % ligh blue
    'dark green',[0.11  0.31  0.21];   % dark green
    'light green',[0.76  0.87  0.78];  % light green
    'purple',[0.42  0.25  0.39];       % purple
    'brown',[0.45  0.26  0.26]};       % brown


% list = {'red', [1 0 0];                % red
%     'blue', [0 0 1];                   % blue
%     'green', [0 1 0];                  % green
%     'yellow', [1 1 0];                 % yellow
%     'magenta', [1 0 1];                % magenta
%     'cyan', [0 1 1];                   % cyan
%     'black', [0 0 0];                  % black
%     'dark red',[1 0 0.2];              % dark red
%     'light red',[1 0.4 0.4];           % light red
%     'dark blue',[0     0     0.70];    % dark blue
%     'light blue',[0.20  0.60  1.00];   % ligh blue
%     'dark green',[0.11  0.31  0.21];   % dark green
%     'light green',[0.76  0.87  0.78];  % light green
%     'purple',[0.42  0.25  0.39];       % purple
%     'brown',[0.45  0.26  0.26]};       % brown


if nargin==1
    indx = ismember(list(:,1),col);
    if ~isempty(indx)
        indx = find(indx==1);
        colcode = list(indx,2); %#ok<FNDSB>
        list = colcode{1};
    else
        list = '';
    end
    
end