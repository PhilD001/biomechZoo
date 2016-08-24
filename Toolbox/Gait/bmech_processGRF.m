function bmech_processGRF(fld,filt)

% BMECH_FORCEPLATEPIG(fld,ch,filt) processess raw force plate data in a manner similar
% to the Vicon Plug-in Gait (PiG) modeller


% Set defaults

if nargin ==1
    filt.cutoff = 20;                                                            % filter settings
    filt.type   = 'butterworth';                                                 % see function
    filt.order  = 4;                                                             % for list of all
    filt.pass   = 'low';
end

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'processing GRF data')
    
    data = processGRF_data(data,filt);

    zsave(fl{i},data);
end



