function [mean_freq,max_freq,cut]= fft_line(data,fsamp,thresh,graph)

% [mean_freq,max_freq,cut]= FFT_LINE(data,fsamp,thresh,graph) performs calculation of
% single-sides amplitude spectrum and estimates cutoff frequency for filtering
%
% ARGUMENTS
%  r          ...   Column vector data (n x 1)
%  fsamp      ...   sampling rate of signal
%  thresh     ...   threshold value to choose cutoff frequency. Default 10
%  graph      ...   Generate plot of data (Boolean). Default true
%
% RETURNS
%  mean_freq  ...   Weighted mean frequency of signal
%  max_freq   ...   Frequency with maximum amplitude
%  cut        ...   Estimated cutof frequency
%
% EXAMPLE
%
% here is a signal sampled at 1000Hz with a frequency of 10Hz. The
% fourier transform clearly shows a spike at 10Hz
% t = (0:0.001:1);   
% x = sin(20*pi*t);  
% fft_line(x,1000)
%
% See also fft, bmech_filter, filter_data, filter_line

% Revision History
%
% created by Philippe C. Dixon July 2017
% - renamed, based on bmech_fft original code


% Set defaults/check arguments
%
if nargin==2
    thresh = 10;
    graph = true;
end

if nargin==3
    graph = true;
end


% Perform FFT algorithm
%
L = length(data);
NFFT = 2^nextpow2(L);                                   % Next power of 2 from length of y
Y = fft(data,NFFT)/L;
f = fsamp/2*linspace(0,1,NFFT/2+1);
yd = 2*abs(Y(1:NFFT/2+1));                              %  single-sided amplitude spectrum


% Calculate signal quantities
%
num = zeros(size(f));
den = zeros(size(f));

for i =1:length(f)
    num(i) = yd(i)*f(i);
    den(i) = yd(i);
end

mean_freq = sum(num)/sum(den);
[maxval,maxindx]=max(yd);                               % avoid spike at zero
last = (thresh/100)*maxval;
cutval = find(yd>last,1,'last');
cut = f(cutval);
max_freq = f(maxindx+1);


% Generate plot
%
if graph==true
    figure    
    subplot(2,1,1)
    plot(data)
    xlabel (' frames')
    ylabel ('Magnitude')
    title ('Original data (time domain)')
       
    subplot(2,1,2)
    plot(f,yd)
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    hold on
    plot(cut,yd(cutval),'r*')
    
    text(0.5,0.4,['estimated cut-off frequency: ',num2str(cut),' Hz' ])
    set(gco,'XLim',[0,50])
end