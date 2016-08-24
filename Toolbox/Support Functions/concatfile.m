function r = concatfile(varargin)


% Updated by Phil Dixon Oct 2011
% - works on mac platform
%
% Updated by Philippe C. Dixon Jan 2016
% - replaced call to function 'slash' with Matlab embedded 
%   function 'filesep'


s = filesep;
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
    