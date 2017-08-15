function r = currentperson

% Updated Sept 2016
% - r returns as empty if hnd is empty

hnd = finddobj('person menu');

if ~isempty(hnd)
    r = get(hnd,'label');
else
    r = '';
end