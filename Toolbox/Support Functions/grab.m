% GRAB is the easy way to open .zoo and .c3d files. Simply type 'grab' and select
% the file you want to open.



% Revision History
%
% Created by Philippe C. Dixon June 2008 
%
% Updated by Philippe C. Dixon Dec 2008
%  -Grab can now grab .c3d , .xls, and .csv files
% 
% Updated by Philippe C. Dixon Feb 2010
% -Grad should now work on Mac and PC platforms
%
% Updated by Philippe C. Dixon November 2011
% - works on mac and pc (xp and 7) platforms
%
% Updated by Philippe C. Dixon September 2013
% - clear all variables except 'data' to avoid confusion in existing
%   workspace
%
% Updated by Philippe C. Dixon September 2015
% - relies on 'readc3d' function to read c3d files instead of the
%  c3d reader from BTK
%
% Updated By Philippe C. Dixon March 2016
% - Support for other file types removed. Grab only reads zoo and c3d files
% - Users can include other files types as required

% catch some possible errors
clear extension

[f,p]=uigetfile('*');
cd(p);

ext = extension(f);

switch ext

    case '.zoo'
        data=load([p,f],'-mat');
        data=data.data;

    case '.c3d'
        data = readc3d([p,f]);
    otherwise
        error(['file type ', ext, ' not supported'])
  
end


% Shorten file path for display 
%
indx = strfind(p,filesep);
[~,c] = size(indx);
disp(' ')
disp('loaded data for:');
disp(' ')

slash = round(c/2);
disp([p(indx(slash):end) f])
disp(' ')

clear p f ext indx slash r c type

disp(data)











