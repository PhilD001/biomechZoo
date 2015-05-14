% function data = grab
% GRAB is the lazyman's way to open zoo data, don't type three lines of
% code, type grab!!
%
% Created by Phil Dixon June 2008 
%
% Updated Dec 2008
%  -Grab can now grab .c3d , .xls, and .csv files
% 
% Updated Feb 2010
% -Grad should now work on Mac and PC platforms
%
% Updated November 2011
% - works on mac and pc (xp and 7) platforms
%
% Updated September 2013
% - clear all variables except 'data' to avoid confusion in existing
%   workspace
%
% Part of the Biomechanics Toolbox. 2008-2013 
% Philippe C. Dixon
% philippe.dixon@gmail




[f,p]=uigetfile({'*.zoo';'*.c3d';'*.xls';'*.csv'});
cd(p);

ext = extension(f);

switch ext

    case '.zoo'

        data=load([p,f],'-mat');
        data=data.data;

    case '.c3d'

        data = readc3dBtk([p,f]);

    case '.xls'

        data = xlsread([p,f]);
       
    case '.csv'
        
        data = xlsread([p,f]);
        
end

type = computer;

switch type
    
    case {'PCWIN','PCWIN64'}
        indx = strfind(p,'\');
        
    case {'MACI','MAC','MACI64'}
        indx = strfind(p,'/');
end

[r,c] = size(indx);
disp(' ')
disp('loaded data for:');
disp(' ')

slash = round(c/2);
disp([p(indx(slash):end) f])
disp(' ')

clear p f ext indx slash r c type

data











