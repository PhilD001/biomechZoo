function ensembler_axis_highlight(off)

% ENSEMBLER_AXIS_HIGHLIGHT sets the color of current axis to red, all
% others go black
%
% Created by Philippe C. Dixon May 2017

if nargin==0
    off = false;
end

highlightAx   = [ 1 0 0];
highlightBack = [1 0.8 0.8];
regularAx     = [0.15 0.15 0.15];
regularBack   = [1 1 1];


if off
    
    curAx = gca;
    otherAx = findobj('type','axes');
    otherAx = setdiff(otherAx,curAx);
    
    % set current axes to red
    %
    set(curAx,'YColor',highlightAx,'XColor',highlightAx,'color',highlightBack)
    
    % set other axes tp black
    %
    set(otherAx,'YColor',regularAx,'XColor',regularAx,'color',regularBack)
    
else
    ax = findobj('type','axes');
    set(ax,'YColor',regularAx,'XColor',regularAx,'color',regularBack)
    
    
end
