function bmech_centreofpressure(fld)

% BMECH_CENTREOFPRESSURE(fld) 




% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'computing centre of pressure')
    
    data = centreofpressure_data(data);
   
    zsave(fl{i},data);
end


