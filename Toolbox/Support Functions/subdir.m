function [sub,fls] = subdir(CurrPath)

% SUBDIR  lists (recursive) all subfolders and files under given folder
%    
% [sub,fls] = subdir(CurrPath)
%
% ARGUMENTS
%    CurrPath     ...   pth as outputted from uigetfolder
%
% RETURNS
%    SUB       ...  path of each subfolder as string array
%    FLS       ...  filenames as string array
%
% NOTES
%   use sort([F{:}]) to get sorted list of all filenames.
%   See also DIR, CD
%
% Created by Elmar Tarajan [Elmar.Tarajan@Mathworks.de]  07-Dez-2004
%
%
% updated by phil dixon october 2011
%  - works with  MAC platorm



if nargin == 0
   CurrPath = cd;
end

if nargout == 1
   sub = subfolder(CurrPath,'');
else
   [sub, fls] = subfolder(CurrPath,'','');
end



%-----EMBEDDED FUNCTIONS--------------


function [sub,fls] = subfolder(CurrPath,sub,fls)

tmp = dir(CurrPath);
tmp = tmp(~ismember({tmp.name},{'.' '..'}));
for i = {tmp([tmp.isdir]).name}
    sub{end+1} = [CurrPath, filesep, i{:}];   % updated PD
    
    if nargin==2
        sub = subfolder(sub{end},sub);
    else
        tmp = dir(sub{end});
        fls{end+1} = {tmp(~[tmp.isdir]).name}; %#ok<*AGROW>
        [sub, fls] = subfolder(sub{end},sub,fls);
    end
end
