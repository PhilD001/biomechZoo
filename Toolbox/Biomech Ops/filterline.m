function fdata = filterline(data,fsamp,filt)

% fdata = FILTERLINE(data,fsamp,filt) filters line data
%
% ARGUMENTS
%  data   ...   n x m matrix of data to be filtered
%  filt   ...   filter properties as struct
%
% RETURNS
%  fdata  ...   filtered data
%
% NOTES
% - this is a standalone function used by bmech_filter


% Revision History
%
% Created by Philippe C. Dixon May 2015
% - based on code from JJ Lo 


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



% error checking
%
filt.ftype = lower(filt.ftype); % remove any caps in name

%---Set myfilt struct--------
cutoff = filt.cutoff;

myfilt.type = filt.ftype;
myfilt.order = filt.forder;
myfilt.pass = filt.pass;
myfilt.smprate = fsamp;


%----check cutoff frequency---

if ~isnumeric(cutoff)  % the program will try to automatically assess utoff rom fft
    indx = ~isnan(data);
    [~,~,cutoff] = bmech_fft(data(indx),fsamp,5,'yes');
end

myfilt.cut1 = cutoff(1);
if length(cutoff) ==2
    myfilt.cut2 = cutoff(2);
end

if strcmp(myfilt.pass,'bandpass')|| strcmp(myfilt.pass,'notch')
    coff = [min([myfilt.cut1;myfilt.cut2]),max([myfilt.cut1;myfilt.cut2])];
    
else
    coff = myfilt.cut1;
end

coff = coff/(myfilt.smprate/2);

if coff ==1
    disp(['check cutoff frequency ',num2str(coff*myfilt.smprate/2)])
    coff=0.99;
end

st = 'stop';
hi = 'high';

switch myfilt.type
       
    case 'butterworth'
        switch myfilt.pass
            case {'low','lowpass'}
                [b,a] = butter(myfilt.order,coff);
            case 'bandpass'
                [b,a] = butter(myfilt.order,coff);
            case 'notch'
                [b,a] = butter(myfilt.order,coff,st);
            case {'high','highpass'}
                [b,a] = butter(myfilt.order,coff,hi);
        end
        
    case 'chebychev I'
        switch myfilt.pass
            case 'lowpass'
                [b,a] = cheby1(myfilt.order,myfilt.srip,coff);
            case 'bandpass'
                [b,a] = cheby1(myfilt.order,myfilt.srip,coff);
            case 'notch'
                [b,a] = cheby1(myfilt.order,myfilt.srip,coff,st);
            case 'highpass'
                [b,a] = cheby1(myfilt.order,myfilt.srip,coff,hi);
        end
        
    case 'chebychev II'
        switch myfilt.pass
            case 'lowpass'
                [b,a] = cheby2(myfilt.order,myfilt.srip,coff);
            case 'bandpass'
                [b,a] = cheby2(myfilt.order,myfilt.srip,coff);
            case 'notch'
                [b,a] = cheby2(myfilt.order,myfilt.srip,coff,st);
            case 'highpass'
                [b,a] = cheby2(myfilt.order,myfilt.srip,coff,hi);
        end
    case 'eliptic'
        switch myfilt.pass
            case 'lowpass'
                [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff);
            case 'bandpass'
                [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff);
            case 'notch'
                [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff,st);
            case 'highpass'
                [b,a] = ellip(myfilt.order,myfilt.prip,myfilt.sripple,coff,hi);
        end
    case 'bessel'
        switch myfilt.pass
            case 'lowpass'
                [b,a] = besself(myfilt.order,coff);
            case 'bandpass'
                [b,a] = besself(myfilt.order,coff);
            case 'notch'
                [b,a] = besself(myfilt.order,coff,st);
            case 'highpass'
                [b,a] = besself(myfilt.order,coff,hi);
        end
end

rindx = find(~isnan(data));
%rindx = find(~isnan(data(:,1)));   % bug fix by Phil July 2009. Look at first column only. indx was wrong for matrix data

lim = [min(rindx),max(rindx)];
if isempty(lim)
    fdata = data;
    return
end
if lim(1)+myfilt.order*3 >= lim(2)
    fdata = data;
else
    chunk = data(lim(1):lim(2));  % bug fix by Phil July 2009. Look at first column only. indx was wrong for matrix data
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
    fdata = zeros(size(data))*NaN;
    fdata(lim(1):lim(2)) = filtfilt(b,a,chunk);
end

