function update_ensembler_lines(p,f,fld,settings)

line = findobj('type','line');

if length(line)==1
    updatefile([p,f],settings)
else
    updatedata(fld,settings)
end