function filt = setFilt

% filt = SETFILT returns a structured array of standard filter for kinetics

filt = struct;

filt.type = 'butterworth';                                  % Simple Butterworth
filt.order = 4;                                             % 4th order standard
filt.pass = 'lowpass';                                      % filter high freq
filt.cutoff = 18;      

% See also bmech_kinetics, kinetics_data