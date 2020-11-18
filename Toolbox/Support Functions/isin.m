function r= isin(str,substr)

% r = isin(str,a) verifies is substring 'substr' is in string or cell array of
% strings 'str'
%
% ARGUMENTS
% str ...  string or cell array of strings
% substr   ...  substring
%
% RETURN
% r   ...  logical 0 or 1 
%
%
% Updated Oct 2013
% - imporved help function
%
% Updated February 2014
% - can accept cell array of srings for multiple comparisons
%
% Updated Oct 2020
% - added deprecation warning. 
%
% Updated Nov 2020
% - removed depreciation to maintain support for older versions 

if iscell(substr)
    
    rstk = NaN*ones(size(substr));
    
    for i = 1:length(substr)
        rstk(i) = ~isempty(strfind(str,substr{i}));
    end
    
    if sum(rstk)==0
        r=0;
    else
        r=1;
    end
    
    
else
    r = ~isempty(strfind(str,substr));
end