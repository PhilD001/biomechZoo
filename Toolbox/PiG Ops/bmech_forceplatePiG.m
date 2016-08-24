function bmech_processGRF(fld,ch,filt)

% BMECH_FORCEPLATEPIG(fld,ch,filt) processess raw force plate data in a manner similar
% to the Vicon Plug-in Gait (PiG) modeller


% Set defaults

if nargin ==2
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
    batchdisplay(fl{i},'PiG modeller force plate processing')
    
    data = filter_data(data,ch,filt);
    data = massnormalize_data(data,ch);
    data = resample_data(data,ch);
    data = forceplate2limbside_data(data);
    
    zsave(fl{i},data,'(filter, massnormalize, resample, plate2limb');
end



