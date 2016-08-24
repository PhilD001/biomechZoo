function r = deriv_line(r,fsamp,filt)

% r = DERIV_LINE(r,fsamp,filt) differentiation with the option to filter.
%
% ARGUMENTS
%  r        ...  Matrix data (n x 1 or n x3)
%  fsamp    ...  Sampling rate of signal
%  filt     ...  Filter options (boolean)
%                filt = 0: do not filter (default)
%                filt = 1: filter data using 4th order butterworth low-pass with 10 Hz cutoff
%                filt = struct: filter according to struc fields (see bmech_filter)
%
% RETURNS
%  r        ...  Differentiated matrix data
%
% NOTES
% - use the following example to test the differentiation method
%     t = (0:0.001:1)';
%     x = sin(2*pi*t);
%     dx1 = 2*pi*cos(2*pi*t);
%     dx2 = deriv_line(x,1000,0);
%     plot(dx1)
%     hold on
%     plot(dx2,'r')
%
% See also bmech_deriv, deriv_data, gradient, filter_line

% Revision History
%
% Created by Philippe C. Dixon July 2016


% Set defaults/check arguments
%
if nargin ==1
    error('missing arguments')
end

if nargin == 2
    filt =0;
    run_filt = false;
end

if isnumeric(filt) || islogical(filt)
    if filt ==0
       run_filt = false;
    elseif filt==1
        filt = struct;
        filt.type   = 'butterworth';
        filt.order  = 4;
        filt.pass   = 'lowpass';
        filt.cutoff = 10;
        run_filt = true;
    end
else
    run_filt = true;
end



% differentiate
%
[~,cl] = size(r);
for i = 1:cl
    r(:,i)  = gradient(r(:,i)).*fsamp;
    if run_filt == true
        r(:,i) = filter_line(r(:,i),fsamp,filt);
    end
end






