% Sample zoosystem processing to accompany "zoo_presentation.ppt"
%
% User guide: Run each block of code ('ctrl-enter' or 'command-enter') to explore 
% different features of the zoosystem 
% 
%
% Last updated by Philippe C. Dixon May 12th 2015

%% SET PATH TO ZOOSYSTEM --------------------------------------------------------------------------
%
% - This block loads all the zoosystem m-files into the matlab path

disp('Loading the zoosystem toolbox (setting path)')

restoredefaultpath

cfld = which('presentation');
zfld = cfld(1:end-23);
tfld = [zfld,'Toolbox'];
addpath(genpath(zfld))
cd(zfld)


%% DEMO ZOO FILE STRUCTURE -----------------------------------------------------------------------
%
disp(' ')
disp('This block loads a standard zoofile to reveal the zoo file structure')
disp(' ')

hfld = [zfld,'Help Files'];

fl = engine('fld',hfld,'extension','zoo');

data = zload(fl{1});          

% Single branch
data.RHipAngles_y
 
 figure(1)
 plot(data.RHipAngles_y.line)
 data.RHipAngles_y.event
 
 figure(2)
 zplot(data.RHipAngles_y)
 
 pause()
 %% DEMO ZOO PROCESS
 %
 % go to zoo_process_example and run through steps
 
 
 
 