function varargout = extension(f,ext)

% varargout = extension(f,ext) returns file extension. File extension can be changed if
% second argument is provided
%
%
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