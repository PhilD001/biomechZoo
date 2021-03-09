function bmech_freetorque(fld)

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing free torque')
    data= freetorque_data(data);
    zsave(fl{i},data);
end