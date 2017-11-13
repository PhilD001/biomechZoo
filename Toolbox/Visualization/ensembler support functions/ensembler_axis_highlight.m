function curAx = ensembler_axis_highlight(bool)

% curAx = ENSEMBLER_AXIS_HIGHLIGHT(bool) sets the color of current axis to red, all
% others go black
%
% Created by Philippe C. Dixon May 2017

if nargin==0
    bool = false;
end

highlightAx   = [ 1 0 0];
highlightBack = [1 0.8 0.8];
regularAx     = [0.15 0.15 0.15];
regularBack   = [1 1 1];


curAx = gca;

if bool    
    otherAx = findobj('type','axes');
    otherAx = setdiff(otherAx,curAx);
    
    % set current axes to red
    %
    set(curAx,'YColor',highlightAx,'XColor',highlightAx,'color',highlightBack)
    
    % set other axes tp black
    %
    set(otherAx,'YColor',regularAx,'XColor',regularAx,'color',regularBack)
    
else
      curAx = findobj('type','axes','YColor',highlightAx,'XColor',highlightAx,'color',highlightBack);
% 
%     if ~isempty(curAx)
%         curFig = get(curAx,'parent');
%         set(curFig, 'currentaxes', curAx);
%     end
    
    ax = findobj('type','axes');
    set(ax,'YColor',regularAx,'XColor',regularAx,'color',regularBack)
    
    
end

% make sure current axes stays current
%
if isempty(curAx)
    curAx = gca;
end

