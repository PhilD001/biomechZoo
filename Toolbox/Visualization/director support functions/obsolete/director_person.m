function director_person(varargin)

pt = finddobj('person menu');
if nargin == 1
    cblb = get(gcbo,'label');
else
    cblb = varargin{1};
end

set(pt,'label',cblb);
menu(cblb);