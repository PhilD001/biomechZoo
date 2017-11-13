function [data,walkDir] = getDir(data)

% [data,dir] = GETDIR(data,ch) determines the global axis and direction of
% walking
%
% ARGUMENTS
%  data    ... Zoo data
%
% RETURNS
%  data    ... Zoo data with direction information added to 'data.zoosystem.CompInfo.Direction'
%  walkDir ... Main direction of motion
%
% NOTES
% - Axis of walking direction (I or J) chosen based on axis with greatest average velocity
% - Direction ('neg' or 'pos') based on whether average velocity is negative or positive


% Revision History
%
% updated November 2012
%
% updated Jan 8th
% - compliant with zoosystem v1.1
%
% Updated June 2016
% - any channel can be used to determine direction. Not just SACR. It is recommended
%   that a trunk or pelvis marker should be used
%
% Updated September 2016
% - Can track motion along x or y
% - z direction motion not supported
%
% Updated June 2017
% - Identifies correct direction for static trials
%
% Updated Oct 2017
% - Error check for files without 'OtherMetaInfo' in zoosystem

% Error Check / Set defaults
%

if isfield(data,'LPSI') && ~isfield(data,'SACR')
    SACR = (data.LPSI.line + data.RPSI.line)/2;
elseif isfield(data,'SACR')
    SACR = data.SACR.line;
else
    error('getDir works with PiG data using SACR or L/R PSI markers')
end


% determine type of trial
%
if ~isfield(data.zoosystem,'OtherMetaInfo')
    static=false;
else
    if isfield(data.zoosystem.OtherMetaInfo.Parameter,'MANUFACTURER')
        if isfield(data.zoosystem.OtherMetaInfo.Parameter.MANUFACTURER,'Company')
            company = strjoin(data.zoosystem.OtherMetaInfo.Parameter.MANUFACTURER.Company.data,'');
        elseif isfield(data.zoosystem.OtherMetaInfo.Parameter.MANUFACTURER,'COMPANY')
            company = strjoin(data.zoosystem.OtherMetaInfo.Parameter.MANUFACTURER.COMPANY.data,'');
        else
            company = 'unknown';
        end
    else
        company = 'unknown';
    end
    
    
    if isempty(strfind(company,'AnalysisCorp'))
        static = data.zoosystem.OtherMetaInfo.Parameter.SUBJECTS.IS_STATIC.data;
    else
        if isfield(data.zoosystem.CompInfo,'TrialType')
            trialType = lower(data.zoosystem.CompInfo.TrialType);
            if strfind(trialType,'static')
                static = true;
            else
                static = false;
            end
        elseif strfind(lower(data.zoosystem.SourceFile),'static')
            static = true;
        elseif strfind(lower(data.zoosystem.SourceFile),'vmtmpl')
            static = true;
        else
            static = false;
        end
    end
    
end

% Run algorithm for static or dynamic trials
%
if static
    front = nanmean(data.RASI.line);
    back = nanmean(data.SACR.line);
    
    xr = front(1);
    yr = front(2);
    xs = back(1);
    ys = back(2);
    
    if xr > xs && yr < ys
        walkDir = 'Ipos';
    elseif xr < xs && yr > ys
        walkDir = 'Ineg';
    elseif xr > xs && yr > ys
        walkDir = 'Jpos';
    elseif xr < xs && yr < ys
        walkDir = 'Jneg';
    else
        error('unknown standing direction')
    end
    
else
    
    istart = find(~isnan(SACR(:,1)),1,'first');
    iend = find(~isnan(SACR(:,1)),1,'last');
    SACR = SACR(istart:iend,:);
    
    % Determine if most of motion is along global X or Y
    %
    X = abs(SACR(1,1)-SACR(end,1));
    Y = abs(SACR(1,2)-SACR(end,2));
    
    if Y > X % moving along Y
        axis = 'J';
        dim = 2;
    else     % moving along X
        axis = 'I';
        dim = 1;
    end
    
    % determine which direction along known axis person is travelling
    %
    SACR =  SACR(:,dim);
    indx = ~isnan(SACR);
    SACR = SACR(indx);
    
    if SACR(1) >  SACR(end)  %
        dir = 'neg'; % negative slope
    else
        dir = 'pos';
    end
    
    walkDir = [axis,dir];
    
end

% Write to zoosystem
%
data.zoosystem.CompInfo.Direction = walkDir;