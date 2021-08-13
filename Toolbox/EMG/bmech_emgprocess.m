function bmech_emgprocess(fld,ch,lp_cut, hp_cut,order, span)

% BMECH_EMGPROCES(fld,ch,lp_cut) will perform basic processing for EMG signals
%  1- High pass filter @ 20Hz
%  2- Low-pass filter  @ 500 Hz
%  3- Rectify signal
%  4- Root mean square
%
% ARGUMENTS
%  fld      ... string, folder to operate on
%  ch       ... cell array of strings, name of emg channels to process
%  lp_cut   ... int, low-pass filter cutoff. Default 500
%  hp_cut   ... int, high pass filter cutoff. Default 20
%  order    ... Int, filter order. Default 4
%  span     ... Int, number of frames for RMS average. Default 50
%
% NOTES
% - Data should be collected at 1000 Hz minimum (Nyquist problem)
%
% See also bmech_emgprocess_example, emgprocess_data

% Revision History
%
% Created by Philippe C. Dixon Dec 2012
% - based on code from KU Leuven
%
% Updated by Philippe C. Dixon Feb 2017
% - clean up, more comments
%
% Updated by Vishnu Deep Chandran July 2021
% - added choice of low pass cut off frequency


% set defaults/check inputs
if nargin == 2
    lp_cut = 500;               % default low-pass filter cutoff
    hp_cut = 20;                % default for high pass cutoff
    order = 4;
    span = 50;
end

if nargin == 3
    hp_cut = 20;
    order = 4;
    span = 50;
end

if nargin ==4
    order = 4;
    span = 50;
end

if nargin ==5
    span = 50;
end

% extract all trials
%
cd(fld)
fl = engine('path',fld,'extension','zoo');
for i = 1:length(fl)
    batchdisp(fl{i},'processing emg signals')
    data = zload(fl{i});
    data = emgprocess_data(data,ch,lp_cut,hp_cut,order,span);
    zsave(fl{i},data);
end


