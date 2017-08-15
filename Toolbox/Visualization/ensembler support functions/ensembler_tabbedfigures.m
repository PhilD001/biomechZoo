function ensembler_tabbedfigures

% work in progress to make ensembler use tabbed figures

% if nargin==0
%     close all
%     figure
%     plot(randn(100,1))
%     figure
%     plot(randn(100,1),'k')
% end

figs = findobj('type','figure');

phnd = figure('name','ensembler GUI');
tg = uitabgroup('parent',phnd);
for i = 1:length(figs)
    name = get(figs(i),'name');
    thistab = uitab(tg,'title',name); % build iith tab
    copyobj(figs(i),thistab);
end

% Matlab example
%
h = uitabgroup();
t1 = uitab(h, 'title', 'Panel 1');
a = axes('parent', t1); surf(peaks);
t2 = uitab(h, 'title', 'Panel 2');
closeb = uicontrol(t2, 'String', 'Close Me', ...
    'Position', [180 200 200 60], 'Call', 'close(gcbf)');

