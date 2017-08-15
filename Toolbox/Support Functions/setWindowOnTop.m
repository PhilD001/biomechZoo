function setWindowOnTop(h,state)
% SETWINDOWONTOP sets a figures Always On Top state on or off
%
%  Copyright (C) 2006  Matt Whitaker
% 
%  This program is free software; you can redistribute it and/or modify it
%  under
%   the terms of the GNU General Public License as published by the Free
%   Software Foundation; either version 2 of the License, or (at your
%   option) any later version.
% 
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%  General Public License for more details.
%
% SETWINDOWONTOP(H,STATE): H is figure handle or a vector of figure handles
%                          STATE is a string or cell array of strings-
%                               'true' - set figure to be always on top
%                               'false' - set figure to normal
%                           if STATE is a string the state is applied to
%                           all H. If state is a cell array the length STATE
%                           must equal that of H and each state is applied
%                           individually.
%  Examples: 
%   h= figure;
%   s = 'true';
%   setWindowOnTop(h,s) %sets h to be on top
%   
%   h(1) = figure;
%   h(2) = figure; 
%   s = 'true';
%   setWindowOnTop(h,s) %sets both figures to  be on top
%
%   h(1) = figure;
%   h(2) = figure; 
%   s = {'true','false'};
%   setWindowOnTop(h,s) %sets h(1) on top, h(2) normal
% Notes: 
% 1. Figures must have 'Visible' set to 'on' and not be docked for
%    setWindowOnTop to work.
% 2. Routine does not work for releases prior to R14SP2
% 3. The Java calls are undocumented by Mathworks
%
% Revisions: 09/28/06- Corrected call to warning and uopdated for R2006b

drawnow; %need to make sure that the figures have been rendered or Java error can occur

%check input argument number
error(nargchk(2, 2, nargin, 'struct'));

%is JVM available
if ~usejava('jvm')
   error('setWindowOnTop requires Java to run.');
end

[j,s] = parseInput;
setOnTop; %set the on top state

    function [j,s] = parseInput
        % is h all figure handles
        if ~all(ishandle(h)) || ~isequal(length(h),length(findobj(h,'flat','Type','figure')))
            error('All input handles must be valid figure handles');
        end %if

        %handle state argument
        if ischar(state)
            %make it a cell 
            s = cellstr(repmat(state,[length(h),1]));
            
        elseif iscellstr(state)
            if length(state) ~= length(h)
                error('Cell array of strings: state must be same length as figure handle input');
            end %if
             s = state;            
        else
            error('state must be a character array or a cell array of strings');
        end %if
        
        %check that the states are all valid 
        if ~all(ismember(s,{'true','false'}))
            error('Invalid states entered')
        end %if
        
        if length(h) == 1
            j{1} = get(h,'javaframe');
        else
            j = get(h,'javaframe');
        end %if

    end %parseInput

    function setOnTop
        %get version so we know which method to call
        v = ver('matlab');
        %anticipating here that Mathworks will continue to change these
        %undocumented calls
        switch v(1).Release
            case {'(R14SP2)','(R14SP3)'}
                on_top = 1;
            case {'(R2006a)','(R2006b)'}
                on_top = 2;
            otherwise %warn but try method 2
                warning('setWindowOnTop:UntestedVersion',['setWindowOnTop has not been tested with release: ',v.Release]);
                on_top = 2;
        end %switch
        for i = 1:length(j)
            switch on_top
                case 1  %R14SP2-3
                    w = j{i}.fClientProxy.getFrameProxy.getClientFrame;
                case 2 %R2006a+
                    w= j{i}.fFigureClient.getWindow;
                otherwise %should not happen
                    error('Invalid on top method');
            end %switch
            awtinvoke(w,'setAlwaysOnTop',s{i});
        end %for j
    end %setOnTop

end %setWindowOnTop
