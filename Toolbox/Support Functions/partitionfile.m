function varargout = partitionfile(filename)

% updated Jan 2013
% - works with MAC OS

for i = 1:2:nargout
    [p1,p2] = parse(filename);
    varargout{i} = p2;
    if nargout > i+1;
        [filename,tmp] = parse(p1);
        varargout{i+1} = tmp;
    end
end
if mod(nargout,2)
    varargout{nargout} = [p1,p2];
else
    varargout{nargout} = p1;
end

function [p1,p2] = parse(filename)

s = filesep;    % determine slash direction based on computer type

indx = strfind(filename,s);
if isempty(indx)
    p1 = '';
    p2 = filename;
elseif max(indx)==length(filename);
    indx = max(setdiff(indx,max(indx)));
    if isempty(indx) %only one \ in the string
        p1 = '';
        p2 = filename;
    else
        p1 = filename(1:indx);
        p2 = filename(indx+1:end);
    end    
else
    indx = max(indx);
    p1 = filename(1:indx);
    p2 = filename(indx+1:end);
end

    