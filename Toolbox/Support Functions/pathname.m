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
s = filesep;    % determine slash direction based on computer type

indx = strfind(fl,s);
sslash= indx(end);
path = fl(1:sslash);