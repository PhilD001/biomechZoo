 function con = condition(fl)
 
 % this m-file returns only the condition from the output of engine
% 
% ARGUMENTS
%     fl      ...   complete file name as string.
%
% RETURNS
%     con   ...   condition    
%
% Created November 2011 by Phil Dixon
%
%
%
%
%
% © Part of the Biomechanics Toolbox, Copyright ©2008-2011 
% Phil Dixon



s = filesep;


if isempty(strfind(fl,s))    % fl might come from pc zoosystem info    
    fl = strrep(fl,'\','/');
end

indx = strfind(fl,s);
s1= indx(end-1);
s2 = indx(end);
con = fl(s1+1:s2-1);
