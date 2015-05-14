function r = concatfile(varargin)


% Updated by Phil Dixon Oct 2011
% - works on mac platform

s = slash;

r = [];



for i = 1:nargin
    f = varargin{i};
    if i == 1
        if strcmp(f(end),s);
            f(end) = '';
        end
    else
        if ~strcmp(f(1),s)
            f = [s,f];
        end
    end
    r = [r,f];
end
    