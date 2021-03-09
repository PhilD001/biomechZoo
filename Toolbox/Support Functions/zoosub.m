 function sub = zoosub(fl)
 
 % this m-file returns only the processing subject from the output of engine
% 
% ARGUMENTS
%     fl      ...   complete file name as string.
%
% RETURNS
%     sub   ...   zoo processing subject    
%
% Created January  2012 by Philippe C. Dixon
%
%
%
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008-2012 
% Phil Dixon



s = filesep;


if isempty(strfind(fl,s))    % fl might come from pc zoosystem info    
    fl = strrep(fl,'\','/');
end

indx = strfind(fl,s);
s1= indx(end-2);
s2 = indx(end-1);
sub = fl(s1+1:s2-1);
