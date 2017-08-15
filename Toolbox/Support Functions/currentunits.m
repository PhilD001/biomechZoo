function varargout = currentunits

unt = finddobj('units');
str = get(unt,'string');
if ~isempty(findstr(str,'cm3'))
    varargout{1} = 'volume';
elseif ~isempty(findstr(str,'deg'))
    varargout{1} = 'rotation';
else
    varargout{1} = 'displacement';    
end
varargout{2} = get(unt,'userdata');