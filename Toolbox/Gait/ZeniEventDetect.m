function indx = ZeniEventDetect(data,side,evt,delta)

% ind = ZENIEVENTDETECT(data,side,evt,delta) estimates FS and FO based on oscillation of the
% heel marker about the sacrum (coord method) acording to:
% Zeni et al. (2008) "Two simple methods for determining gait events during treadmill and
% overground walking using kinematic data" Gait and Posture 27. 710-14
%
% ARGUMENTS
% data     ...   zoo data to be operated on
% side     ...   leg (left 'L' right 'R')
% evt      ...   name of event. 'FS' or 'FO'
% delta    ...   threshold for event detection. See 'peakdet.m'
%
% RETURNS
% indx     ...  indx of event
%
%


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


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon, Dept of Engineering Science. University of Oxford. Oxford, UK.
% Yannick Michaud-Paquette, Dept of Kinesiology. McGill University. Montreal, Canada.
% JJ Loh, Medicus Corda. Montreal, Canada.
% 
% Contact: 
% philippe.dixon@gmail.com
%
% Web: 
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the paper below if the zoosystem was used in the preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement Analysis 
% Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of Movement Analysis in 
% Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014. 




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


File = data.zoosystem.SourceFile;


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
    
    if ostart~=start
        error([side,'TOE marker data has NaNs at start, correct in Vicon'])
    end
    
    if ofin~=fin
        error([side,'TOE marker data has NaNs at end, correct in Vicon '])
    end
    
end


if sum(isnan(mhee))~=0
    start = find(~isnan(mhee),1,'first');
    fin = find(~isnan(mhee),1,'last');
    
    if ostart~=start
        error([side,'HEE marker data has NaNs at start, correct in Vicon'])
    end
    
    if ofin~=fin
        error([side,'HEE marker data has NaNs at end, correct in Vicon '])
    end
end


if sum(isnan(msacr))~=0
    start = find(~isnan(msacr),1,'first');
    fin = find(~isnan(msacr),1,'last');
    
    if ostart~=start
        error('SACR marker data has NaNs at start, correct in Vicon')
    end
    
    if ofin~=fin
        error('SACR marker data has NaNs at end, correct in Vicon ')
    end
end

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
        
        if maxs(1,1)==1
            indx =  maxs(2:end,1);
        elseif maxs(end,1) ==length(hee_still)
            indx = maxs(1:end-1,1);
        else
            indx = maxs(:,1);
        end
        
        
    case 'FO'
        [~,mins] = peakdet(toe_still,delta);
        
        if isempty(mins)
            batchdisplay(File,'no events detected')
            indx = NaN;      
        elseif mins(1,1)==1
            indx =  mins(2:end,1);
        elseif mins(end,1) ==length(hee_still)
            indx = mins(1:end-1,1);
        else
            indx = mins(:,1);
        end
        
end





