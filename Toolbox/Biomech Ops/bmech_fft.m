function [mean_freq,max_freq,cut] = bmech_fft(data,fsamp,thresh,graph)

% runs FFT algorithm. To change the viewing window of frequencies,
% please update the EDIT section of this m-file 
%
% bmech_fft(data, fsamp)
%
% ARGUMENTS
%   data       ...   data as column vector
%   fsamp      ...   sampling rate of signal
%   thresh     ...   threshold value to choose cutoff frequency. Default 10
%   graph      ...   produces plot of data. default 'yes'. Can be set to 'no'
%                    to supress plotting function
%
% RETURNS
%   mean_freq  ...   the weighted mean frequency of signal
%   max_freq   ...   frequency with maximum amplitude
%   cut        ...   estimated cutof frequency
%
% EXAMPLE
%
% here is a signal sampled at 1000Hz with a frequency of 10Hz. The
% fourier transform clearly shows a spike at 10Hz
% t = (0:0.001:1);   
% x = sin(20*pi*t);  
% bmech_fft(x,1000)

  
% Revision History
%
% created by Phil Dixon. Nov 2006
%   
% Updated by Phil and Zubair Oct 2009
%   -improved FFT algorithm
%
% Updated by Phil Dixon June 2010
%   -ability to calculate mean signal frequency included
%   -ability to calculate frequency of max amplitude
%
% Updated by Phil Dixon June 2012
% - added estimation of cut off frequency


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the 
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement 
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of 
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.



%-------DEFAULTS-----
if nargin ==2
    graph = 'yes';
    thresh = 10;
end

%----NO BATCH PROCESSING------

if nargin~=0
    disp('running in single vector mode')
    [mean_freq,max_freq,cut] = bmechfft(data, fsamp,thresh,graph);
end


%----FOR BATCH PROCESSING-----

if nargin==0
    
    disp('running in batch processing mode')
    
    fld = uigetfolder;
    cd(fld)
    fl = engine('path',fld,'extension','zoo');
    
    data = load(fl{1},'-mat');
    data = data.data;
    fsamp = data.zoosystem.Freq;
    ch = setdiff(fieldnames(data),'zoosystem');
    
    for l = 1:length(fl);
        data = load(fl{l},'-mat');
        data = data.data;
        disp(['calculating mean signal frequency: ',fl{l}]);
        
        for i =1:length(ch)
            [mean_freq,max_freq,cut] = bmechfft(data.(ch{i}).line, fsamp,thresh,'no');
            data.(ch{i}).event.meanfreq = [1 mean_freq 0];
            data.(ch{i}).event.maxfreq = [1 max_freq 0];
        end
        
        save(fl{l},'data');
    end
end


function [mean_freq,max_freq,cut]=bmechfft(data,fsamp,thresh,graph)


%-------FFT ALGORITHM--------

L = length(data);
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(data,NFFT)/L;
f = fsamp/2*linspace(0,1,NFFT/2+1);

yd = 2*abs(Y(1:NFFT/2+1));  %  single-sided amplitude spectrum



%----CALCULATE SIGNAL QUANTITIES---

num = zeros(size(f));
den = zeros(size(f));

for i =1:length(f)
    num(i) = yd(i)*f(i);
    den(i) = yd(i);
end

mean_freq = sum(num)/sum(den);

[maxval,maxindx]=max(yd);  % avoid spike at zero

last = (thresh/100)*maxval;
cutval = find(yd>last,1,'last');
cut = f(cutval);
max_freq = f(maxindx+1);


%--------------PLOT RESULTS---------
if strcmp(graph,'yes')
    
    figure, hold;
    
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
  %   axes('position',[0,0,1,1],'visible','off');
    hold on
    plot(cut,yd(cutval),'r*')
    
    
    text(0.5,0.4,['estimated cut-off frequency: ',num2str(cut),' Hz' ])
    
    set(gco,'XLim',[0,50])
    
end

