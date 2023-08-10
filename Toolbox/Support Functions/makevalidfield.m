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




if isempty(ch)
    ch = 'empty';
else


    % replace this list of characters with underscore
    % bad_chars = {'-','[', ']' };
    %

    ch = strrep(ch,' ','_');

    % if contains(ch, bad_chars)
    %     ch = strrep(ch, '_');
    % end

    % if ~isempty(strfind(ch,'['))
    ch = strrep(ch,'[','');
    %
    % end
    % if ~isempty(strfind(ch,']'))
    ch = strrep(ch,']','');
    % end
    %
    % if ~isempty(strfind(ch,'^'))
    ch = strrep(ch,'^','');
    % end
    %
    % if ~isempty(strfind(ch,'='))
    ch = strrep(ch,'=','');
    % end
    %
    % if ~isempty(strfind(ch,'('))
    ch = strrep(ch,'(','');
    % end
    %
    % if ~isempty(strfind(ch,')'))
    ch = strrep(ch,')','');
    % end

    %if ~isempty(strfind(ch,'+'))
    ch = strrep(ch,'+','');
    %end

    %if ~isempty(strfind(ch,'.'))
    ch = strrep(ch,'.','');
    %end

    %if ~isempty(strfind(ch,'\'))
    ch = strrep(ch,'\','');
    %end

    %if ~isempty(strfind(ch,'?'))
    ch = strrep(ch,'?','');
    %end

    %if ~isempty(strfind(ch,','))
    ch = strrep(ch,',','');
    %end




    %if ~isempty(strfind(ch,'*'))
    ch = strrep(ch,'*','star');

    %end

    %if ~isempty(strfind(ch,'#'))
    ch = strrep(ch,'#','numbersign');
    %end

    %if ~isempty(strfind(ch,':'))
    ch = strrep(ch,':','');
    %end

    %if ~isempty(strfind(ch,'%'))
    ch = strrep(ch,'%','percent');

    % indx = strfind(ch,'%');
    % ch = [ch(1:indx-1),'percent',ch(indx+1:end)];
    %end

    %if ~isempty(strfind(ch,'$'))
    ch = strrep(ch,'$','dollarsign');
    %end

    %if ~isempty(strfind(ch,'/'))
    ch = strrep(ch,filesep,'per');

    % indx = strfind(ch,'/');
    % ch = [ch(1:indx-1),'per',ch(indx+1:end)];
    %end


    % special cases
    if ~isempty(str2num(ch)) && length(ch) ==1  %#ok<ST2NM> % don't change
        ch = ['marker',ch];
    end

    if ~isempty(str2num(ch(1))) && length(ch) ~=1 %#ok<ST2NM> % don't change
        ch = ch(2:end);
    end

    if strfind(ch(1),'_')
        ch = ch(2:end);
    end

    if strfind(ch,'''')
        ch = strrep(ch,'''','');
    end

    if isnumeric(ch(1))
        ch = ['n',num2str(ch)];
    end

    % check if final fieldname exceeds matlabs max length
    if length(ch)>namelengthmax
        ch = ch(1:namelengthmax);
    end



    % if anything is still bad deal with it
    a = struct;
    try
        a.(ch) = 3;
    catch
        disp(['invalid field name ', ch, ' ...ignoring'])
        ch = 'invalid_field_name';
    end

end

