function [indx,data] = ZeniEventDetect_old(data,side,evt,delta)

% ind = ZENIEVENTDETECT(data,side,evt,delta) estimates FS and FO based on oscillation of the
% heel marker about the sacrum (coord method) acording to the Zeni method 
%
% ARGUMENTS
% data     ...   zoo data to be operated on
% side     ...   leg (left 'L' right 'R')
% evt      ...   name of event. 'FS' or 'FO'
% delta    ...   threshold for event detection. See 'peakdet.m'
%
% RETURNS
% indx     ...  indx of event
% data     ...  updated zoo data
%
% NOTES
% - Refer to Zeni et al. (2008) "Two simple methods for determining gait events during 
%   treadmill and overground walking using kinematic data" Gait and Posture 27. 710-14


% Revision History
%
% Created by Philippe C. Dixon November 2011
%
% Updated December 2011
% - If max or min is discovered in first or last frame, it is ignored. Data
%   should be labeled with at least 5 frames before and after gait events for
%   best identification
%
% Updated April 11th 2012
% - Fixed small bug with if statement
%
% Updated June 10th 2012
% - Uses toe data as described in Zeni for FO detection
%
% Updated May 13th 2014
% - If nans exist in HEE, TOE, or SACR markers at start or end of trial program is aborted.
%   All trials should be labeled over the entire selected region
%
% Updated March 2015
% - Cleaned up function
% - Added error checking
% - Added choice of 'PELO' instead of 'SACR' marker to estimate SACR position
%
% Updated March 2016
% - If no FS events are detect 'NaN' is returned
%
% Updated July 2016
% - Removed reference to original c3d file
% - fixed bug with NaN checking at SACR



% Set defaults
%
if nargin==3
    delta = 10; % threshold for peak detect
end

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

if isfield(data,'RPSI')                                     % in cases where SACR
    RPSI = data.RPSI.line;                                  % marker was not used
    LPSI = data.LPSI.line;                                  % it can be computed
    SACR = (RPSI+LPSI)/2;                                   % from RPSI and LPSI
    data = addchannel_data(data,'SACR',SACR,'video');
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



% Compute new channels
%
mhee = magnitude([gradient(HEE(:,1)) gradient(HEE(:,2))]);
mtoe = magnitude([gradient(TOE(:,1)) gradient(TOE(:,2))]);
msacr = magnitude([gradient(SACR(:,1)) gradient(SACR(:,2))]);

ostart = 1;
ofin = length(mhee);

if sum(isnan(mtoe))~=0
    start = find(~isnan(mtoe),1,'first');
    fin = find(~isnan(mtoe),1,'last');
    l = length(mtoe);
    
    if ostart~=start
        disp(['WARNING: ',side,'TOE marker data has NaNs at start'])
        pad = ones(start-1,1) * mtoe(start);
        mtoe(1:start-1) = pad;
    end
    
    if ofin~=fin
        disp(['WARNING: ',side,'TOE marker data has NaNs at end'])
        pad =ones(l-fin+1,1) * mtoe(fin);
        mtoe(fin:l) = pad;
    end
    
    if sum(isnan(mtoe))~=0
        error('Additional NaNs in data. Fill gaps and rerun program')
    end
    
end


if sum(isnan(mhee))~=0
    start = find(~isnan(mhee),1,'first');
    fin = find(~isnan(mhee),1,'last');
    l = length(mhee);

    if ostart~=start
        disp(['WARNING: ',side,'HEE marker data has NaNs at start'])
        pad =ones(start-1,1) * mhee(start);
        mhee(1:start-1) = pad;
    end
    
    if ofin~=fin
        disp(['WARNING: ',side,'HEE marker data has NaNs at end'])
        pad =ones(l-fin+1,1) * mhee(fin);
        mhee(fin:l) = pad;
    end
    
    if sum(isnan(mhee))~=0
        error('Additional NaNs in data. Fill gaps and rerun program')
    end
    
end


if sum(isnan(msacr))~=0
    start = find(~isnan(msacr),1,'first');
    fin = find(~isnan(msacr),1,'last');
    l = length(msacr);

    if ostart~=start
        disp('WARNING: SACR marker data has NaNs at start')
        pad =ones(start-1,1) * msacr(start);
        msacr(1:start-1) = pad;
    end
    
    if ofin~=fin
        disp('WARNING: SACR marker data has NaNs at end')
        pad =ones(l-fin+1,1) * msacr(fin);
        msacr(fin:l) = pad;
    end
    
    if sum(isnan(msacr))~=0
        error('Additional NaNs in data. Fill gaps and rerun program')
    end
    
end

cumd_hee = cumsum(mhee);
cumd_toe = cumsum(mtoe);
cumd_sacr = cumsum(msacr);

hee_still = cumd_hee - cumd_sacr; % removes forward movement from hee data to mimic treadmill walking
toe_still = cumd_toe - cumd_sacr; % removes forward movement from toe data to mimic treadmill walking

if ~isfield(data,[side,'HEE_still'])
    data = addchannel_data(data,[side,'HEE_still'],hee_still,'Video');
    data = addchannel_data(data,[side,'TOE_still'],toe_still,'Video');
end

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





