function zplot(r)

% ZPLOT(r) plots zoo channel data along with event markers
%
% ARGUMENTS
%  r   ... struct containing line and event branches  e.g. zplot(data.vforce)
%


% Revision History
%
% Created by Philippe C. Dixon Dec 2009
%
% Updated by Philippe C. Dixon Feb 2010
% - better user interface
% - zplot made more generic e.g. can be used in subplots
%
% Updated by Philippe C. Dixon Feb 17th 2013
% - uses buttowndown function for more fun
%
% Updated by Philippe C. Dixon May 2015
% - improved user interface



% Set Defaults
%
MarkerStyle = 'o';
MarkerFaceColor = 'r';
MarkerEdgeColor = 'k';
MarkerSize = 6;


% Choose action
%

if isfield(r,'line')
    action = 'start';
    
elseif isstruct(r)
    chnames = setdiff(fieldnames(r),'zoosystem');
    indx = listdlg('liststring',chnames);
    
    for i = 1:length(indx)
        zplot(r.(chnames{indx(i)}))
        hold on
    end
    
else
    action = 'buttondown';
end

switch action
    
    case 'start'
        
        line('ydata',r.line,'xdata',(0:length(r.line)-1));
        evt = fieldnames(r.event);
        
        for e = 1:length(evt)
            hold on
            line('XData',r.event.(evt{e})(1)-1,'YData', r.event.(evt{e})(2),...
                'Marker',MarkerStyle,'MarkerFaceColor',MarkerFaceColor,'MarkerEdgecolor',MarkerEdgeColor,...
                'MarkerSize',MarkerSize,'buttondownfcn','zplot(''buttondown'')','userdata',evt{e});        
        end
        
    case 'buttondown'
        
        ehnds = findobj('type','line','Marker',MarkerStyle);
        
        for i = 1:length(ehnds)
            set(ehnds(i),'MarkerFaceColor',MarkerFaceColor)
        end
        
        ehnd = findobj(gcbo);
        mstyle = get(ehnd,'Marker');
        
        if isin(mstyle,MarkerStyle)
            
            if ~isempty(ehnd)
                set(ehnd,'MarkerFaceColor','b')
                tag = get(gcbo,'UserData');
                
                TextBox = uicontrol('style','text','String',['Event: ',tag]);
                P = get(TextBox,'Position');
                set(TextBox,'Position',[0 400 P(3)*3 P(4)]);
            end
        end
end