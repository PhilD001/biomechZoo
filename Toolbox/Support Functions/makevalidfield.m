function ch = makevalidfield(ch)

% ch = makevalidfield(ch) fixes common invalid field names for structed
% arrays
% 
% ARGUMENTS
%   ch    ...   name of channel as string
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
% Updated by Philippe C. Dixon Oct 2016
% - Removed '_' as invalid field
% - Added '^,=' as invalid fields
% - Truncates any field that exceeds MATLAB's maximum name length
% - Converts numeric channel names x to nx

if isnumeric(ch)
    ch = ['n',num2str(ch)];
    ch = makevalidfield(ch);
end

if length(ch)>63
    ch = ch(1:63);
    ch = makevalidfield(ch);
end

if ~isempty(strfind(ch,' '))
    ch = strrep(ch,' ','_');
    ch = makevalidfield(ch);
elseif ch == ""
    ch = 'empty';
elseif ~isempty(strfind(ch,'-'))
    ch = strrep(ch,'-','');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,'['))
    ch = strrep(ch,'[','');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,']'))
    ch = strrep(ch,']','');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,'^'))
    ch = strrep(ch,'^','');
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'='))
    ch = strrep(ch,'=','');
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

elseif ~isempty(strfind(ch,'?'))
    ch = strrep(ch,'?','');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,','))
    ch = strrep(ch,',','');
    ch = makevalidfield(ch);
    
elseif ~isempty(strfind(ch,'*'))
    ch = 'star';
    ch = makevalidfield(ch);

elseif ~isempty(strfind(ch,'#'))
    ch = strrep(ch,'#','numbersign');
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
    
elseif ~isempty(str2num(ch)) && length(ch) ==1  %#ok<ST2NM> % don't change
    ch = ['marker',ch];
    ch = makevalidfield(ch);

elseif ~isempty(str2num(ch(1))) && length(ch) ~=1 %#ok<ST2NM> % don't change
    ch = ch(2:end);
    ch = makevalidfield(ch);

elseif strfind(ch(1),'_')
    ch = ch(2:end);
    ch = makevalidfield(ch);
    
elseif strfind(ch,'''')
    ch = strrep(ch,'''','');
    ch = makevalidfield(ch);
    
end
