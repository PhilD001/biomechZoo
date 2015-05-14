function r= isin(str,a)

% r = isin(str,a) verifies is substring 'a' is in string or cell array of
% strings 'str'
%
% ARGUMENTS
% str ...  string or cell array of strings
% a   ...  substrignt
%
% RETURN
% r   ...  logical 0 or 1 
%
%
%
% Updated Oct 2013
% - imporved help function
%
% Updated February 2014
% - can accept cell array of srings for multiple comparisons


if iscell(a)
    
    rstk = NaN*ones(size(a));
    
    for i = 1:length(a)
        rstk(i) = ~isempty(strfind(str,a{i}));
    end
    
    if sum(rstk)==0
        r=0;
    else
        r=1;
    end
    
    
else
    r = ~isempty(strfind(str,a));
end