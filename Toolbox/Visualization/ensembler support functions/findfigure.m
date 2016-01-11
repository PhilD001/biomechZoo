
function r = findfigure(fl,fig)
r = [];
for i = 1:length(fig)
    nm = get(fig(i),'name');
    if isgoodfile(fl,nm)
        r = [r;fig(i)];
    end
end