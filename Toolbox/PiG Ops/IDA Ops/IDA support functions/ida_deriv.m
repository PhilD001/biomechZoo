function deriv = ida_deriv(data,fsamp,f,cut)

% Differentiates data with the option to filter. To change filter settings, input new settings
% in the EDIT section of this m-file 
%
% deriv = bmech_deriv(data,fsamp,f)
%
%   ARGUMENTS
%   data     ...  the data coming in 
%   fsamp    ...  sampling rate of data
%   f        ...  f = 0 do not filter, f = 1 filter data (default) Default is 4th order butter lowepass 
%   cut      ...  cut-off frequency for filter. Default 10hz
%
%   RETURNS  
%   deriv    ...  differentiated data
%
%   Notes
%   1) To run multiple derivaties simply run bmech_deriv the required number
%   of times.
%   2) use the following example to test the validity of the
%   differentiation method
%     t = (0:0.001:1);
%     x = sin(2*pi*t);
%     dx1 = 2*pi*cos(2*pi*t);
%    dx2 = bmech_deriv(x,1000,0);
%
%   Updated July 2008: 
%    - Use of function gradient. Gradient conserves length of input vector.
%   - can handle vectors as columns or rows
%
%   Updated January 2009: 
%   -  FDA is not functional and has been disabled
%
%   Updated June 2013
%   - clean up for for better readability
%
%  Updated August 2013
% - allow choice of cutoff frequency for filtering

% © Part of the Biomechanics Toolbox, Copyright ©2008, 
% Phil Dixon, Montreal, Qc, CANADA



if nargin == 2                      %default is diff followed by regular filtering
    f = 1;
    cut = 10;
end

if nargin==3
    cut = 10;
end

    

[rw cl]=size(data);

if rw ==1
    data = makecolumn(data);
end

[rw cl]=size(data);

%-----------------------choosing a filtering method--------------------
%
%               f = 0: None 
%               f = 1: regular filtering
%               f=  2: FDA filtering

deriv_stk =[];


switch f
    case 0
    
        for i =1:cl    
        raw_deriv  = gradient(data(:,i)).*fsamp;
        deriv_stk = [deriv_stk raw_deriv];
        end
    
    case 1
        for i = 1:cl
        raw_deriv  = gradient(data(:,i)).*fsamp;
        filt_deriv = bmech_filter('vector',raw_deriv,'fsamp',fsamp,'cutoff',cut,'ftype','butterworth','order',4,'pass','lowpass'); 
        deriv_stk = [deriv_stk filt_deriv];
        end
                 
end

deriv = deriv_stk;



