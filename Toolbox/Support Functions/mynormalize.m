function r = mynormalize(vec,idata,lim);

if nargin == 2
    lim = [1,length(vec)];
elseif nargin == 1
    idata = (0:100);
    lim = [1,length(vec)];
end

xdata = (1:length(vec));
xdata = (xdata-lim(1))/(lim(2)-lim(1));
xdata = xdata*100;

r = interp1(xdata,vec,idata);