function tempprint(calculation);

for i = 1:length(calculation)
    tl = calculation(i).title;
    [f,p] = uiputfile('*.txt',tl);
    cd(p);
    f = extension(f,'.txt');
    fid = fopen([p,f],'w');
    m = calculation(i).ydata;
    for j = 1:length(m)
        fprintf(fid,'%5.5f',m(j));
        fprintf(fid,'\n');
    end
    fclose(fid);
end
    
