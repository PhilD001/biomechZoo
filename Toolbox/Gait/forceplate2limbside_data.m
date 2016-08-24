function data = forceplate2limbside_data(data,ch,thresh)

% data = FORCEPLATE2LIMBSIDE_DATA(data,fch,thresh,ref) determines which limb (right
% or left) made contact with force plate n. Information is stored in
% zoosystem (data.zoosystem.Analog.FPlates.LIMBSIDES)
%
% ARGUMENTS
%  data     ...   Zoo data
%  ch       ...   name of force plate channels used in algorithm. Default ForceFz
%  thresh   ...   Threshold for detecting gait event. Default 20

% RETURNS
%  data     ...   Zoo data with new force plates channels (with prefix 'R','L') appended
%
% See also forceplate2limbside_data, ZeniEventDetect


% Set defaults/error check
%
% suf = 'GroundReaction';            % new channel names
sides = {'Right','Left'};            % new force channel prefix
prec = 10;                           % if disagreement btw kinematics and GRF>prec, invalid FP

if nargin==1
    ch = 'ForceFz';
    thresh = 20;
end

if nargin==2
    thresh = 20;
end

if nargin==3
end

AVR = data.zoosystem.AVR;                              % Analog/Video rate

% Get info from metadata
%
nForcePlates = data.zoosystem.Analog.FPlates.NUMUSED;
units = data.zoosystem.Units.Forces;

if strcmp(units,'N/kg')
    m = getanthro(data,'Bodymass');
else
    m = 1;
end


% get force plate events
%
FPstk = ones(nForcePlates,1);
for j = 1:nForcePlates

    yd = m*data.([ch,num2str(j)]).line;
    ref = peakSign(yd);
    yd = ref*yd;
    r = find(yd>thresh,1,'first');
    
%     if ~isempty(r) && yd(r+20) < yd(r)
%         error('incorrect FS event idenfitied, increase dectection threshold')
%     end
    
    if isempty(r)
        r = inf;
    end
    
    if AVR ~= 1
        r = round(r/AVR);
    end
    FPstk(j) = r;
end

% Run algorithm for each side
%

for i = 1:length(sides)
    side = sides{i};
    
    % get and check for kinematic data
    FS = ZeniEventDetect(data,side(1),'FS',thresh);
%     if isnan(FS)
%         data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = 'invalid';
%         continue
%     end
%     
%     if sum(isinf(FPstk))==nForcePlates
%         data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = 'invalid';
%         continue
%     end
    
    % associate event with correct limb side
    Diffs = ones(nForcePlates,length(FS));    % rows are FPs, columns are events
    for j = 1:nForcePlates
        Diffs(j,:) = abs(FS-FPstk(j))';
    end
    
    minsRows = min(Diffs,[],2);               % mins in each row (force plate)
    [~,FPindx] = min(minsRows);               % indx of correct FP
    diffFPkin = minsRows(FPindx);              % returns diff betw FP and kin estimate,
    
    
    % add to zoosystem
    if isempty(FPindx)
        data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = 'invalid';
    elseif diffFPkin > prec
        data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = 'invalid';
    else
        data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = ['FP',num2str(FPindx)];
    end
    
   
end





