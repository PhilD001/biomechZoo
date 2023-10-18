function update_ensembler_lines(p,f,fld,settings, c)

% update line display after implementing changes 

line = findobj('type','line');

if nargin == 4
    c = get(line(1), 'color');
end

if length(line)==1
    updatefile([p,f],settings, c)
else
    updatedata(fld,settings, c)
end