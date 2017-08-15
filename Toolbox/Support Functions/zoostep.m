 function step = zoostep(fl)
 
 % this m-file returns only the processing step from the output of engine
% 
% ARGUMENTS
%     fl      ...   complete file name as string.
%
% RETURNS
%     step   ...   zoo processing step    
%
% Created January  2012 by Philippe C. Dixon
%
%
%
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008-2012 
% Phil Dixon



s = slash;


if isempty(strfind(fl,s))    % fl might come from pc zoosystem info    
    fl = strrep(fl,'\','/');
end

indx = strfind(fl,s);
s1= indx(end-3);
s2 = indx(end-2);
step = fl(s1+1:s2-1);
