 function path = pathname(fl)
 
 % this m-file returns only the path to which the file belongs 
% 
% ARGUMENTS
%     fl      ...   complete file name as string.
%
% RETURNS
%     path   ...   path of file    
%
% Created Feb 2010
%
% © Part of the Biomechanics Toolbox, Copyright ©2008-2010 
% Phil Dixon, Montreal, Qc, CANADA
%
s = slash;

indx = strfind(fl,s);
sslash= indx(end);
path = fl(1:sslash);