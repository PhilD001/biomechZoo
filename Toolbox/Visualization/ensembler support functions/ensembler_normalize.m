function ensembler_normalize(fld,datalength)

fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    disp(['normalizing:',fl{i}]);
    data = zload(fl{i});
    data = normalizedata(data,datalength);
    save(fl{i},'data');
end

