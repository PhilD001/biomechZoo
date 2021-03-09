function bmech_copyall(fld1,fld2,ext)

% biomech_copyall(fld1,fld2) copies all files from fld1 to fld2
%
% ARGUMENTS
%  fld1   ...  folder to copy from
%  fld2   ...  folder to copy to
%  ext    ...  copy only by file extension. Default 'all'


% Revision History
%
% Created by Philippe C. Dixon Feb 2015
%
% Updated by Philippe C. Dixon May 2015
% - small bug fixes


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt




tic

s = filesep;    % determine slash direction based on computer type


% Get files from database
%
if nargin==2
    fl = engine('path',fld1);
else
    fl = engine('path',fld1,'extension',ext);
end



% check if copy to folder exists
%
if exist(fld2,'dir')==0
    mkdir(fld2)
end

% check if paths end with s
%
if ~strcmp(fld1(end),s)
    fld1 = [fld1, s];
end


if ~strcmp(fld2(end),s)
    fld2 = [fld2, s];
end


% copy files from fld1 to fld2
%
for i= 1:length(fl)
    
    batchdisp(fl{i},'copying file')
    
    [p,f] = fileparts(fl{i});
    ext = extension(fl{i});
    
  
    % find subfolder
    %
    last_slash_indx = strfind(fld1,s);   
    last_slash_indx = last_slash_indx(end);
    con = p(last_slash_indx+1:end);
    
    
    % copy to directory
    %
    dest = [fld2,con,s];
    nfl =  [dest,f,ext];   
    
    if exist(dest,'dir')==0
        mkdir(dest)
    end
    
    r = copyfile(fl{i},nfl,'f');
    
    
    if r==0
        error('copy error detected')
    end
    
end

disp(['all files copied in ',num2str(toc)])
