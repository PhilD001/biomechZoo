function deriv =walk_deriv(data,fsamp,f,cutoff)

%   MY_DERIV differentiates data with the option to filter
%
%   ARGUMENTS
%
%   data     ...  the data coming in 
%   fsamp    ...  sampling rate of data
%   f        ...  f = 1 filter data, f = 0 FDA ; otherwise do not filter. Default is 1
%
%   RETURNS  
%
%   deriv    ...  differentiated data
%
%   Notes
%
%   1) To run multiple derivaties simply run MY_DERIV the required number
%   of times.
%
%   Updated July 15th: 
%   1) FDA is fully functionnal
%   2) Use of function gradient. Gradient conserves length of input vector.
%   3) can handle vectors as columns or rows
%
% Updated May 13th 2011
% - changing defualt filtering to 10 improves ankle power estimation

if nargin == 2                      %default is diff followed by regular filtering
f = 1;
end


if nargin ~=4
    cutoff = 10;
end

rw =size(data);

if rw ==1
    data = makecolumn(data);
end

[rw cl]=size(data);
%-----------------------choose filtering method--------------------
%
%               f = 0: None 
%               f = 1: regular filtering
%               f=  2: FDA filtering

raw_deriv_stk =[];

switch f
    case 0
    
        for i =1:cl    
        raw_deriv  = gradient(data(:,i)).*fsamp;
        raw_deriv_stk = [raw_deriv_stk raw_deriv];
        deriv = raw_deriv_stk;
        end
    
    case 1
        for i = 1:cl
        raw_deriv  = gradient(data(:,i)).*fsamp;
        raw_deriv_stk = [raw_deriv_stk raw_deriv];
        deriv = my_filter(raw_deriv_stk,fsamp,cutoff);   % edit my_filter for filtering options
        end
     
    case 2
    
    deriv = fda_diff(data,fsamp);
                        
end






function fdata = my_filter(data,fsamp,cutoff)

%   Function MY_FILTER runs a number of possible filters
%
%   Notes
%   1)This is really JJs filter in standalone form


%-----------settings for current filter----------

myfilt.type = 'butterworth';
myfilt.order = 4;
myfilt.pass = 'lowpass';
myfilt.smprate = fsamp;

if nargin <3
    cutoff = 6; %default setting
end
myfilt.cut1 = cutoff;






fdata = filterline(data,myfilt);

%

function fdata = filterline(data,myfilt)

%structure of myfilt is
%myfilt.type
%myfilt.pass
%myfilt.order
%myfilt.smprate
%myfilt.cut1
%myfilt.cut2
%myfilt.srip
%myfilt.prip

% myfilt.type chooses filter type
% 'butterworth'
% 'chebychev I'
% 'chebychev II'
% 'eliptic'
% 'bessel'

% myfilt.pass chooses filter pass
% 'lowpass'
% 'highpass'
% 'bandpass'
% 'notch'


if strcmp(myfilt.pass,'bandpass')| strcmp(myfilt.pass,'notch')
    coff = [min([myfilt.cut1;myfilt.cut2]),max([myfilt.cut1;myfilt.cut2])];
else
    coff = myfilt.cut1;
end

coff = coff/(myfilt.smprate/2);
st = 'stop';
hi = 'high';

switch myfilt.type 
case 'butterworth'
    switch myfilt.pass
    case 'lowpass'
        [b,a] = butter(myfilt.order,coff);
    case 'bandpass'
        [b,a] = butter(myfilt.order,coff);
    case 'notch'
        [b,a] = butter(myfilt.order,coff,st);
    case 'highpass'
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
lim = [min(rindx),max(rindx)];
if isempty(lim)
    fdata = data;
    return
end
if lim(1)+myfilt.order*3 >= lim(2)
    fdata = data;
else
    chunk = data(lim(1):lim(2));
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


