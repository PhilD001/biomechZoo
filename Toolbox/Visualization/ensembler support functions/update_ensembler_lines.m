function update_ensembler_lines(p,f,fld)

line = findobj('type','line');

if length(line)==1
    updatefile([p,f])
else
    updatedata(fld)
end