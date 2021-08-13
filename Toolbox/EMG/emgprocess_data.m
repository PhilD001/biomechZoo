function data = emgprocess_data(data,emg_ch,lp_cut,hp_cut,order,span)

% EMGPROCESS_DATA(data,emg_ch,lp_cut,hp_cut,order,span) performs EMG processing
%
% ARGUMENTS
%  data     ... struct, zoo data
%  emg_ch   ... cell array of strings, name of emg channels to process
%  lp_cut   ... int, low-pass filter cutoff. Default 500
%  hp_cut   ... int, high pass filter cutoff. Default 20
%  order    ... Int, filter order. Default 4
%  span     ... Int, number of frames for RMS average. Default 50
%
% RETURNS
%  data     ...  struct, zoo data appended with processed EMG channels


SR=data.zoosystem.Analog.Freq;                   % EMG sampling rate                                         % sample frequency

if SR < 1000
    error('sampling rate must be at least 1000 Hz')
end

% filter high pass
%
fnyq = SR/2;                                       % Nyquist frequency
fcut = hp_cut;                                     % cutoff frequency
[B,A]=butter(order,fcut/fnyq,'high');
for i = 1:length(emg_ch)
    r = data.(emg_ch{i}).line;
    filt_r = filtfilt(B,A,r);                       %
    data = addchannel_data(data,[emg_ch{i},'_filthigh'],filt_r,'Analog');
end

% filter low pass
%
fcut = lp_cut;                                     % cutoff
if fcut/fnyq >=1
    error(['select a cutoff frequency lower than ', num2str(fnyq), ' Hz'])
end
[B,A]=butter(order,fcut/fnyq,'low');
for i = 1:length(emg_ch)
    filt_r = data.([emg_ch{i},'_filthigh']).line;
    filt_filt_r = filtfilt(B,A,filt_r);
    data = addchannel_data(data,[emg_ch{i},'_filthigh_filtlow'],filt_filt_r,'Analog');
end

% rectify
%
for i = 1:length(emg_ch)
    filt_filt_r = data.([emg_ch{i},'_filthigh_filtlow']).line;
    rect_r = filt_filt_r.*filt_filt_r;
    data = addchannel_data(data,[emg_ch{i},'_filthigh_filtlow_rect'],rect_r,'Analog');
end

% RMS
%
window = ones(span,1)/span;
for i = 1:length(emg_ch)
    rect_r = data.([emg_ch{i},'_filthigh_filtlow_rect']).line;
    mean_temp=convn(rect_r,window,'same');
    RMS_r=sqrt(mean_temp);
    data = addchannel_data(data,[emg_ch{i},'_filthigh_filtlow_rect_RMS'],RMS_r,'Analog');
end

