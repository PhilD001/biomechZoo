function hnd = findensobj(action,varargin)

% hnd = FINDENSOBJ(action,varargin) searches for objects in ensembler using
% special properties

switch action
    case 'figure'
        hnd = findobj('type','figure');
    case 'axes'
        if nargin == 2
            hnd = setdiff(findobj(varargin{1},'type','axes'),...
                          findobj(varargin{1},'type','axes','tag','legend'),'stable');
        else
            hnd = setdiff(findobj(findensobj('figure'),'type','axes'),...
                          findobj(findensobj('figure'),'type','axes','tag','legend'),'stable');
        end
    case 'prompt'
        hnd = findobj(varargin{1},'tag','prompt','style','text');
    case 'highlight'
        hnd = findobj('type','line','color',[0 0 .98]);
end