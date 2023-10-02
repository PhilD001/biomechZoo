function update_ensembler_lines(p,f,fld,settings, color)

line = findobj('type','line');

if length(line)==1
    updatefile([p,f],settings,color)
else
    updatedata(fld,settings,color)
end