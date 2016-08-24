function extract_norm_schwartz


% takes values from norm_schartz.mat into format for plotting in ensembler
%
% if norm_schartz.mat is not available then schwartz2mat should be run first
%
% Created November 29th 2013 by Philippe C. Dixon



% Find norm_schwartz on computer---
file = which('extract_norm_schwartz.m');
pth = fileparts(file);
file = 'norm_schwartz.mat';
s = filesep;    % determine slash direction based on computer type


data = load([pth,s,file],'-mat');
data = data.normdata;

Velocities = {'Very Slow'  'Slow'  'Free'  'Fast'  'Very Fast'}; 

a = 0:2:100;
a = [a fliplr(a)]';

for i = 1:length(Velocities)
    
    
    Vel = makevalidfield(Velocities{i});
    
    for j = 1:length(data.anglelist)
    
        r = data.anglelist(j);
        
        ch = r.name;
        
        d = r.vel(i).sms;   % n x 3 with n=1 lower sd n=2 mean n=3 upper sd
        indx = 0:1:length(d(:,1));
        lower = d(:,1)';
        upper = fliplr(d(:,3)');
        
        p.(ch).(Vel).x = a; % indx fliplr(indx)];
        p.(ch).(Vel).y = [lower'; upper'];
        
        
        
        disp(['for speed:  ',Vel,' writing ',ch]) 

        
        save([pth,s,ch,'_',Vel, '.mat'],'p')
        
        
    end
    
end