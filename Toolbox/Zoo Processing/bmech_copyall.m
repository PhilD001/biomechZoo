function bmech_copyall(fld1,fld2,ext,con)

% biomech_copyall(fld1,fld2) copies all files from fld1 to fld2
%
% ARGUMENTS
% fld1   ...  folder to copy from
% fld2   ...  folder to copy to
% ext    ...  copy only by file extension. Default 'all'
% con    ...  choice to use folder
%

% Revision History
%
% Created by Philippe C. Dixon Feb 2015
%
% Updated by Philippe C. Dixon May 2015
% - small bug fixes


tic
% Get files from database
%
if nargin==2
    fl = engine('path',fld1);
else
    fl = engine('path',fld1,'extension',ext);
end

if nargin==3
    con = 0;
end


% check if copy to folder exists
%
if exist(fld2,'dir')==0
    mkdir(fld2)
end

% check if paths end with slash
%
if ~strcmp(fld1(end),slash)
    fld1 = [fld1, slash];
end


if ~strcmp(fld2(end),slash)
    fld2 = [fld1, slash];
end


% copy files from fld1 to fld2
%
for i= 1:length(fl)
    
    batchdisplay(fl{i},'copying file')
    
    [p,f] = fileparts(fl{i});
    ext = extension(fl{i});
    
    indx_fld1 = strfind(fld1,slash);
    sfld = p(indx_fld1(end)+1:end);
    
    if con ==1
        cond = p(indx_fld1(end-1)+1:indx_fld1(end)-1);
        nfl = [fld2,cond,slash,sfld,slash,f,ext];
        
        if ~strcmp(cond(end),slash)
            cond = [cond, slash];
        end
        
    else
        cond = [];
        nfl = [fld2,sfld,slash,f,ext];
    end
    
    
    dest = [fld2,cond,sfld];
    
    if exist(dest,'dir')==0
        mkdir(dest)
    end
    
    r = copyfile(fl{i},nfl,'f');
    
    
    if r==0
        error('copy error detected')
    end
    
end

disp(['all files copied in ',num2str(toc)])
