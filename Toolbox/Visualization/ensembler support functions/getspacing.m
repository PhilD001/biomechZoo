

function vec = getspacing(num,axwid,sp,figlength)

if ischar(sp)
    s = (figlength-(num*axwid))/(num+1);
    vec = zeros(1,num);
    vec(:) = s;
else
    lsp = length(sp);
    if num < lsp
        vec = sp(1:num);
    elseif num == lsp
        vec = sp;
    else
        vec = zeros(1,num);
        vec(1:lsp) = sp;
        vec(lsp+1:end) = sp(lsp);
    end
end
