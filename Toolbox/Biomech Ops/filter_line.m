function r = filter_line(r,filt,fsamp)

% fdata = FILTER_LINE(r,filt,fsamp) filtering via different filter options
%
% ARGUMENTS
%  r        ...  Column vector data (n x 1)
%  filt     ...  Filter options (struct). Default: 4th order butterworth low-pass filter
%                with 10Hz cutoff. 
%                filt can contain the following fields: 
%                filt.type   = 'butterworth','chebychev I/II','eliptic','bessel'
%                filt.cutoff =  integer cutoff frequency.
%                filt.order  =  interger filter order
%                filt.pass   = 'lowpass','highpass'
%                filt.srip   =  stopband ripple (see 'cheby1,cheby2,ellip)
%                filt.prip   =  peak-to-peak ripple (see 'ellip')
%  fsamp    ...  Sampling rate of signal
%
% RETURNS
%  r        ...  Filtered column vector data  
%
% See also bmech_filt, filter_data, filtfilt, butter, cheby1, cheby2, ellip,besself

% Revision History
%
% Created by Philippe C. Dixon July 2016
% - based on code from JJ Lo 


% error checking
%
if strcmp(filt.pass,'low') || strcmp(filt.pass,'high') || strcmp(filt.pass,'band')
    filt.pass = [filt.pass,'pass'];
end


% add sampling rate to filt struct
%
filt.smprate = fsamp;
[b,a] = get_filter_coeffs(filt);



rindx = find(~isnan(r));
%rindx = find(~isnan(data(:,1)));   % bug fix by Phil July 2009. Look at first column only. indx was wrong for matrix data

lim = [min(rindx),max(rindx)];
if isempty(lim)
    return
end

if lim(1)+filt.order*3 < lim(2)
    chunk = r(lim(1):lim(2));  % bug fix by Phil July 2009. Look at first column only. indx was wrong for matrix data
    %  chunk = data(lim(1):lim(2),:);
    nindx = find(isnan(chunk));
    if ~isempty(nindx);
        xd = (1:length(chunk));
        rindx = find(~isnan(chunk));
        ixd = xd(nindx);
        xd = xd(rindx);
        yd = chunk(rindx);
        nyd = interp1(xd,yd,ixd,'spline');
        chunk(nindx) = nyd;
    end
    r = zeros(size(r))*NaN;
    r(lim(1):lim(2)) = filtfilt(b,a,chunk);
end



function [b,a] = get_filter_coeffs(filt)


filt.cut1 = filt.cutoff(1);
if length(filt.cutoff) ==2
    filt.cut2 = filt.cutoff(2);
end

if strcmp(filt.pass,'bandpass')|| strcmp(filt.pass,'notch')
    coff = [min([filt.cut1;filt.cut2]),max([filt.cut1;filt.cut2])];
else
    coff = filt.cut1;
end

coff = coff/(filt.smprate/2);

if coff ==1
    disp(['check cutoff frequency ',num2str(coff*filt.smprate/2)])
    coff=0.99;
end

st = 'stop';
hi = 'high';

switch filt.type
       
    case 'butterworth'
        switch filt.pass
            case 'lowpass'
                [b,a] = butter(filt.order,coff);
            case 'bandpass'
                [b,a] = butter(filt.order,coff);
            case 'notch'
                [b,a] = butter(filt.order,coff,st);
            case 'highpass'
                [b,a] = butter(filt.order,coff,hi);
        end
        
    case 'chebychev I'
        switch filt.pass
            case 'lowpass'
                [b,a] = cheby1(filt.order,filt.srip,coff);
            case 'bandpass'
                [b,a] = cheby1(filt.order,filt.srip,coff);
            case 'notch'
                [b,a] = cheby1(filt.order,filt.srip,coff,st);
            case 'highpass'
                [b,a] = cheby1(filt.order,filt.srip,coff,hi);
        end
        
    case 'chebychev II'
        switch filt.pass
            case 'lowpass'
                [b,a] = cheby2(filt.order,filt.srip,coff);
            case 'bandpass'
                [b,a] = cheby2(filt.order,filt.srip,coff);
            case 'notch'
                [b,a] = cheby2(filt.order,filt.srip,coff,st);
            case 'highpass'
                [b,a] = cheby2(filt.order,filt.srip,coff,hi);
        end
        
    case 'eliptic'
        switch filt.pass
            case 'lowpass'
                [b,a] = ellip(filt.order,filt.prip,filt.srip,coff);
            case 'bandpass'
                [b,a] = ellip(filt.order,filt.prip,filt.srip,coff);
            case 'notch'
                [b,a] = ellip(filt.order,filt.prip,filt.srip,coff,st);
            case 'highpass'
                [b,a] = ellip(filt.order,filt.prip,filt.srip,coff,hi);
        end
        
    case 'bessel'
        switch filt.pass
            case 'lowpass'
                [b,a] = besself(filt.order,coff);
            case 'bandpass'
                [b,a] = besself(filt.order,coff);
            case 'notch'
                [b,a] = besself(filt.order,coff,st);
            case 'highpass'
                [b,a] = besself(filt.order,coff,hi);
        end
end
