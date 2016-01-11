function r = stack_ensembler(a,b)

% STACK_ENSEMBLER is a standalone function for ensembler

% Updated Dec 1 2015
% - added '~' as output to size (not compatible with older Matlab versions)

if isempty(a)
    r = b;
    return
elseif isempty(b)
    r=a;
    return
end

[~,ca] = size(a);
[~,cb] = size(b);
if ca > cb
    b(:,cb+1:ca) = NaN;
elseif cb > ca
    a(:,ca+1:cb) = NaN;
end
r = [a;b];
