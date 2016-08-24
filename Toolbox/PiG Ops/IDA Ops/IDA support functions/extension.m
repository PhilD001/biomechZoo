function varargout = extension(f,ext)

% updated by Philippe C. Dixon August 2013
% - changed to strfind from findstr at line 6

indx = strfind(f,'.');

if nargin == 2
    ext = strrep(ext,'.','');
    if isempty(ext)
        if isempty(indx)
            varargout{1} = f;
        else
            varargout{1} = f(1:max(indx)-1);
        end        
    elseif isempty(indx)
        varargout{1} = [f,'.',ext];
    else
        varargout{1} = [f(1:max(indx)),ext];
    end
else    
    if isempty(indx)
        varargout{1} = [];
        varargout{2} = f;
    else
        varargout{1} = f(max(indx):end);
        varargout{2} = f(1:max(indx)-1);
    end
    
end