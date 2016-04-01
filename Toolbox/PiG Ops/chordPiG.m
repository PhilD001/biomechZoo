function JCpl = chordPiG(proxJCpl,distMk,jointWidth,mDiameter,mode)

% JCpl = chordPiG(proxJCpl,distMk,jointWidth,mDiameter,mode) computes joint
% center based on PiG 'chord' function
%   
% NOTES
% - This function will need to be updated in future Matlab versions. See
%   warning in newer Matlab versions


% Revision History
%
% Created by Philippe C. Dixon 2013
%
% Updated by Philippe C. Dixon March 2016
% - 'step up' proces by allowing the first proper solution at any frame 
%   to be used. This should provide good results since joint centers should
%   not 'move' relative to markers


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

allFrames = length(distMk);

r = (jointWidth+mDiameter*2)/2;  % radius of circle in plane

rstring = ['r^2-',num2str(r^2)];
x1string = 'x1-0';
y1string = 'y1-0';
    
if strcmp(mode,'fast')
    
    JCpl = [0 0 0];
    
    notDone = true;
    count = 1;
    while notDone
        x2 = proxJCpl(count,1);
        y2 = proxJCpl(count,2);
        
        x2string = ['x2-',num2str(x2)];
        y2string = ['y2-',num2str(y2)];
        
        s = solve('((y1-y3)/(x1-x3))+((x2-x3)/(y2-y3))','x3^2+y3^2-r^2',...
            rstring,x1string,x2string,y1string,y2string,'Real',true);
        
        if ~isfield(s,'x3')    % fix for r2014b
            count = count+1;
            continue
        elseif count == allFrames;
            error('no solution to chord function')
        else
            JCpl(1,1) = s.x3(1);
            JCpl(1,2) = -(abs(s.y3(1)));  %  negative is the right solution
            notDone = false;
        end
        
    end
    
else
    
    JCpl = zeros(size(distMk));
   
    for i = 1:length(distMk)
        x2 = proxJCpl(i,1);
        y2 = proxJCpl(i,2);
        
        x2string = ['x2-',num2str(x2)];
        y2string = ['y2-',num2str(y2)];
        
        s = solve('((y1-y3)/(x1-x3))+((x2-x3)/(y2-y3))','x3^2+y3^2-r^2',...
            rstring,x1string,x2string,y1string,y2string,'Real',true);
        
        if ~isfield(s,'x3')    % fix for r2014b
            JCpl(i,1:2) = NaN;
        else
            JCpl(i,1) = s.x3(1);
            JCpl(i,2) = -(abs(s.y3(1)));  %  negative is the right solution
        end
    end
end