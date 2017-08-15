function indx = ZeniEventDetect(data,side,evt,delta)

% ind = ZENIEVENTDETECT(data,side,evt,delta) estimates foot strike (FS) and 
% foot off (FO) events during gait 
%
% ARGUMENTS
%  data     ...   zoo data to be operated on
%  side     ...   leg (left 'L' right 'R')
%  evt      ...   name of event. 'FS' or 'FO'
%  delta    ...   threshold for event detection. See 'peakdet.m'
%
% RETURNS
% indx     ...  indx of event
% 
% NOTES
% - Refer to Zeni et al. (2008) "Two simple methods for determining gait events during 
%   treadmill and overground walking using kinematic data" Gait and Posture 27. 710-14



% Error checking
%
% - check if required channels are present
% - make substitution if requried
%
if ~isfield(data,[side,'HEE']) && ~isfield(data,[side,'HEE_x'])
    error(['required marker ',side,'HEE missing'])
end

if ~isfield(data,[side,'TOE']) && ~isfield(data,[side,'TOE_x'])
    error(['required marker ',side,'TOE missing'])
end

if ~isfield(data,'SACR') && ~isfield(data,'SACR_x')
    
    if isfield(data,'PELO') || isfield(data,'PELO_x')
        top = 'PELO';
    else
       error('required marker to estimte SACR position missing')
    end
    
else
    top = 'SACR';
end


% Extract quantities
%
if isfield(data,[side,'HEE_x'])
    HEE = [data.([side,'HEE_x']).line data.([side,'HEE_y']).line];
    TOE = [data.([side,'TOE_x']).line data.([side,'TOE_y']).line];
    SACR = [data.([top,'_x']).line data.([top,'_y']).line];
else
    HEE = data.([side,'HEE']).line(:,1:2);
    TOE = data.([side,'TOE']).line(:,1:2);
    SACR = data.(top).line(:,1:2);
end

% check for missing data
%
[start,fin] = check_missing(HEE,TOE,SACR,side);

% Compute new channels
%
mhee = magnitude([gradient(HEE(start:fin,1)) gradient(HEE(start:fin,2))]);
mtoe = magnitude([gradient(TOE(start:fin,1)) gradient(TOE(start:fin,2))]);
msacr = magnitude([gradient(SACR(start:fin,1)) gradient(SACR(start:fin,2))]);

cumd_hee = cumsum(mhee);
cumd_toe = cumsum(mtoe);
cumd_sacr = cumsum(msacr);

hee_still = cumd_hee - cumd_sacr; % removes forward movement from hee data to mimic treadmill walking
toe_still = cumd_toe - cumd_sacr; % removes forward movement from toe data to mimic treadmill walking



% Zeni algorithm
%
switch evt
    
    case 'FS'
        maxs = peakdet(hee_still,delta);
        
        if isempty(maxs)
            disp('no events detected')
            indx = NaN;
        elseif maxs(1,1)==1
            indx =  maxs(2:end,1);
        elseif maxs(end,1) ==length(hee_still)
            indx = maxs(1:end-1,1);
        else
            indx = maxs(:,1);
        end
        
        
    case 'FO'
        [~,mins] = peakdet(toe_still,delta);
        
        if isempty(mins)
            disp('no events detected')
            indx = NaN;      
        elseif mins(1,1)==1
            indx =  mins(2:end,1);
        elseif mins(end,1) ==length(hee_still)
            indx = mins(1:end-1,1);
        else
            indx = mins(:,1);
        end
        
end

% add possible missing frames
%
indx = indx+start-1;

function [start,fin] = check_missing(HEE,TOE,SACR,side)

start_stk = [];
fin_stk = [];

% normal case, no nans
%
start = 1;
fin = length(HEE(:,1));

start_stk = [start_stk; start];
fin_stk   = [fin_stk; fin];

% check for nans
%
if ~isempty(find(isnan(HEE), 1))
     disp(['WARNING: ',side,'HEE marker data contains NaNs'])
     start = find(~isnan(HEE(:,1)),1,'first');
     fin   = find(~isnan(HEE(:,1)),1,'last');
     start_stk = [start_stk; start];
     fin_stk   = [fin_stk; fin];
end

if ~isempty(find(isnan(TOE), 1))
     disp(['WARNING: ',side,'TOE marker data contains NaNs'])
     start = find(~isnan(TOE(:,1)),1,'first');
     fin   = find(~isnan(TOE(:,1)),1,'last');
     start_stk = [start_stk; start];
     fin_stk   = [fin_stk; fin];
end

if ~isempty(find(isnan(SACR), 1))
     disp(['WARNING: ',side,'SACR marker data contains NaNs'])
     start = find(~isnan(SACR(:,1)),1,'first');
     fin   = find(~isnan(SACR(:,1)),1,'last');
     start_stk = [start_stk; start];
     fin_stk   = [fin_stk; fin];
end
    

    
% check if indices must be updated
%
start = max(start_stk);
fin   = min(fin_stk);
    
% 
% ostart = 1;
% ofin = length(mhee);
% 
% if sum(isnan(mtoe))~=0
%     start = find(~isnan(TOE(:,1)),1,'first');
%     fin = find(~isnan(TOE(:,1)),1,'last');
%     l = length(mtoe);
%     
%     if ostart~=start
%         disp(['WARNING: ',side,'TOE marker data has NaNs at start'])
%         pad = ones(start-1,1) * mtoe(start);
%         mtoe(1:start-1) = pad;
%     end
%     
%     if ofin~=fin
%         disp(['WARNING: ',side,'TOE marker data has NaNs at end'])
%         pad =ones(l-fin+1,1) * mtoe(fin);
%         mtoe(fin:l) = pad;
%     end
%     
%     if sum(isnan(mtoe))~=0
%         error('Additional NaNs in data. Fill gaps and rerun program')
%     end
%     
% end
% 
% 
% if sum(isnan(mhee))~=0
%     start = find(~isnan(mhee),1,'first');
%     fin = find(~isnan(mhee),1,'last');
%     l = length(mhee);
% 
%     if ostart~=start
%         disp(['WARNING: ',side,'HEE marker data has NaNs at start'])
%         pad =ones(start-1,1) * mhee(start);
%         mhee(1:start-1) = pad;
%     end
%     
%     if ofin~=fin
%         disp(['WARNING: ',side,'HEE marker data has NaNs at end'])
%         pad =ones(l-fin+1,1) * mhee(fin);
%         mhee(fin:l) = pad;
%     end
%     
%     if sum(isnan(mhee))~=0
%         error('Additional NaNs in data. Fill gaps and rerun program')
%     end
%     
% end
% 
% 
% if sum(isnan(msacr))~=0
%     start = find(~isnan(msacr),1,'first');
%     fin = find(~isnan(msacr),1,'last');
%     l = length(msacr);
% 
%     if ostart~=start
%         disp('WARNING: SACR marker data has NaNs at start')
%         pad =ones(start-1,1) * msacr(start);
%         msacr(1:start-1) = pad;
%     end
%     
%     if ofin~=fin
%         disp('WARNING: SACR marker data has NaNs at end')
%         pad =ones(l-fin+1,1) * msacr(fin);
%         msacr(fin:l) = pad;
%     end
%     
%     if sum(isnan(msacr))~=0
%         error('Additional NaNs in data. Fill gaps and rerun program')
%     end
%     
% end
% 


