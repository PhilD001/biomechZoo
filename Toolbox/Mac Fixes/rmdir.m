function rmdir(fld,mode)

% RMDIR removes folders for the mac platform
%
% ARGUMENTS
%  fld       ...  folder to remove as string
%  mode      ...  force deletion of files

% Revision History
%
% Created by Philippe C. Dixon based on Matlab Newsgroup file Feb 2012


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

if nargin==1
    mode = '';
end

if ispc
    dos(['rmdir /S/Q ' fld]);
    disp('this function should only load on mac platform. Check your path')
else
    if strfind(mode,'s')
        unix(['rm -f -R ' '"' fld '"']);
    else
        unix(['rm -R ' '"' fld '"']);
    end
    
end

