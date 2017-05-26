function bmech_emgprocess(fld,ch)

% BMECH_EMGPROCES(fld,ch) will perform basic processing for EMG signals
%  1- High pass filter @ 20Hz
%  2- Low-pass filter  @ 500 Hz
%  3 - Rectify signal
%  4 - Root mean square
%
% ARGUMENTS
%  fld    ... folder to operate on
%  ch     ... name of emg channels to process (cel array of strings)
%
% NOTES
% - Data should be collected at 1000 Hz minimum (Nyquist problem)


% Revision History
% 
% Created at KU Leuven
%
% Last updated by Philippe C. Dixon Feb 2017
% - clean up, more comments

cd(fld)

% extract all non static files
%
fl_all = engine('path',fld,'extension','zoo');
fl_tmp = engine('path',fld,'extension','zoo','search file','Cal');
fl = setdiff(fl_all,fl_tmp);

for i = 1:length(fl)    
    batchdisplay(fl{i},'emg process')
    data = zload(fl{i});
    data = emgprocess_data(data,ch);
    zsave(fl{i},data);
end


function data = emgprocess_data(data,emg_ch)


SR=data.zoosystem.Analog.Freq;                   % EMG sampling rate                                         % sample frequency

if SR < 1000
    error('sampling rate must be at least 1000 Hz')
end


% filter high pass 
%
fnyq = SR/2;                                       % Nyquist frequency
fcut = 20;                                         % cutoff frequency
nord = 4;                                          % Filter order
[B,A]=butter(nord,fcut/fnyq,'high');


for i = 1:length(emg_ch)
    r = data.(emg_ch{i}).line;
    filt_r = filtfilt(B,A,r);                       %        
    data = addchannel_data(data,[emg_ch{i},'_filthigh'],filt_r,'Analog');
end


    
% filter low pass
%
fcut = 500;                                        % cutoff
nord = 4;
[B,A]=butter(nord,fcut/fnyq,'low');
	
for i = 1:length(emg_ch)
    filt_r = data.([emg_ch{i},'_filthigh']).line;
    filt_filt_r = filtfilt(B,A,filt_r);
    data = addchannel_data(data,[emg_ch{i},'_filthigh_filtlow'],filt_filt_r,'Analog');
end


% rectify + RMS
%
span=50;
window = ones(span,1)/span;

for i = 1:length(emg_ch)
    filt_filt_r = data.([emg_ch{i},'_filthigh_filtlow']).line;
    rect_r = filt_filt_r.*filt_filt_r;                      
    mean_temp=convn(rect_r,window,'same');
    RMS_r=sqrt(mean_temp);
    data = addchannel_data(data,[emg_ch{i},'_rect_RMS'],RMS_r,'Analog');
end
 



 


      