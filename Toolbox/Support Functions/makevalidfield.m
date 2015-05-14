function ch = makevalidfield(ch)

% This function fixes common invalid field names
% 
% ch = makevalidfield(ch)
%
% ARGUMENTS
%   ch    ...   name of channel as stting
%   
% RETURNS
%   ch    ...   new name of channel as string with invalid fieldnames removed
% 
%
% Created by JJ Loh
% 
% Updated by Phil Dixon Nov 2008
%   - This function now uses recursion to fix channel names with multiple
%     problems
%
% Updated by Phil Dixon Nov 2011
% - subcase ':' can handle invalid characters at the end of the field
% 
% updated by Phil Dixon March 2013
% - added new cases
%
% Updated by Philippe C. Dixon May 2014
% - added new cases
% - use of 'strrep' to clean code
%






if ~isempty(strfind(ch,' '))
    ch = strrep(ch,' ','_');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch(1),'_'))
    ch = ch(2:end);
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'-'))
    ch = strrep(ch,'-','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'('))
    ch = strrep(ch,'(','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,')'))
    ch = strrep(ch,')','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'+'))
    ch = strrep(ch,'+','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'.'))
    ch = strrep(ch,'.','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'\'))
    ch = strrep(ch,'\','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'*'))
    ch = 'star';
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'#'))
    ch = 'numbersign';
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,':'))
    ch = strrep(ch,':','');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,'%'))
    indx = strfind(ch,'%');
    ch = [ch(1:indx-1),'percent',ch(indx+1:end)];
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,'$'))
    ch = strrep(ch,'$','dollarsign');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,'/'))
    indx = strfind(ch,'/');
    ch = [ch(1:indx-1),'per',ch(indx+1:end)];
    ch = makevalidfield(ch);
    
elseif ~isempty(str2num(ch)) && length(ch) ==1  % don't change
    ch = ['marker',ch];
    ch = makevalidfield(ch);

elseif ~isempty(str2num(ch(1))) && length(ch) ~=1 % don't change
    ch = ch(2:end);
    ch = makevalidfield(ch);

end
