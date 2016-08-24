 function fpath = filepath(fl)
%
%
% this m-file returns only the filepath from the output of engine
% 
% ARGUMENTS
%     fl      ...   complete file name as string.
%
% RETURNS
%     fpath   ...   filepath    
%
% Created January 2011
%
%
% Updated October 2011
% - compatible with mac 
%
%
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008, 
% Phil Dixon, Montreal, Qc, CANADA
%

s = slash;

indx = strfind(fl,s);
sslash= indx(end);
fpath = fl(1:sslash);