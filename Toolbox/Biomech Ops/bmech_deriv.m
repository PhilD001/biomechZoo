function deriv = bmech_deriv(data,fsamp,f,cut)

% deriv = bmech_deriv(data,fsamp,f,cut) differentiates data with the option to filter. 
%
% ARGUMENTS
%  data     ...  the data coming in
%  fsamp    ...  sampling rate of data
%  f        ...  f = 0 do not filter, f = 1 filter data (default) Default is 4th order butter lowepass
%                f can also be a struct with the following fields
%                'ftype','order','pass','cutoff'
%  cut      ...  cut-off frequency for filter. Default 10hz
%
% RETURNS
%  deriv    ...  differentiated data
%
% Notes
%  1) To run multiple derivaties simply run bmech_deriv the required number
%     of times.
%  2) use the following example to test the validity of the
%     differentiation method
%     t = (0:0.001:1);
%     x = sin(2*pi*t);
%     dx1 = 2*pi*cos(2*pi*t);
%    dx2 = bmech_deriv(x,1000,0);


% Revision History
%
% Created based on earlier functions from JJ Loh 2006
%
% Updated by Philippe C. Dixon July 2008:
%  - Use of function gradient. Gradient conserves length of input vector.
%  - can handle vectors as columns or rows
%
% Updated by Philippe C. Dixon January 2009:
%  - FDA is not functional and has been disabled
%
% Updated by Philippe C. Dixon June 2013
%  - clean up for for better readability
%
% Updated by Philippe C. Dixon August 2013
% - allow choice of cutoff frequency for filtering
% - preallocation of deriv_stk
%
% Updated by Philippe C. Dixon february 14th 2014
% - full customization of filtering properties possible by setting f as a
%   struct


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

% Set defaults
%
if nargin < 2
    error('missing arguments')
end

if nargin == 2                      % full default settings
    f.ftype = 'butterworth';
    f.order = 4;
    f.pass = 'lowpass';
    f.cutoff = 10;
end


if nargin==3                      
    
    if ~isstruct(f)
        if f==1
            f.ftype = 'butterworth';
            f.order = 4;
            f.pass = 'lowpass';
            f.cutoff = 10;
        end
        
    end
    
end


if nargin==4
    if ~isstruct(f)
        if f==1
            f.ftype = 'butterworth';
            f.order = 4;
            f.pass = 'lowpass';
            f.cutoff = cut;
        end
        
    end 
end



% extract info for filtering
%
if isstruct(f)
    ftype = f.ftype;
    order = f.forder;
    pass = f.pass;
    cut = f.cutoff;
    filt = 'on';
else
    filt = 'off';
end
     


[rw, cl]=size(data);

if rw ==1
    data = makecolumn(data);
end

[rw, cl]=size(data);


deriv_stk = zeros(rw,cl);

switch filt
    
    case 'off'
        
        for i =1:cl
            raw_deriv  = gradient(data(:,i)).*fsamp;
            deriv_stk(:,i) = raw_deriv;
        end
        
    case 'on'
        for i = 1:cl
            raw_deriv  = gradient(data(:,i)).*fsamp;
            filt_deriv = filterline(raw_deriv,fsamp,f);
            deriv_stk(:,i) = filt_deriv;
        end
        
end

deriv = deriv_stk;



