function bmech_forceplate2limbside(fld)

% Associates force plates to a limb side (Right or Left) using
% marker data. New force plate channels with prefix 'R','L' 
% also created
%
% ARGUMENTS
%  fld  ...   folder of data to operate on


% Revision History
%
% Created by Philippe C. Dixon Mach 20th 2017


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt



% Set defaults
%
if nargin==0
    fld = uigetfolder;
end

thresh = 10;        % threshold for detecting gait event (see ZeniEventDetect)
ch = 'Fz';          % name of force plate channels used in algorithm
peakSign = -1;      % change to '1' if peak is positive

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisplay(fl{i},'associating limb to force plate')
    data= forceplate2limbside(data,ch,thresh,peakSign);
    zsave(fl{i},data);
end


function data = forceplate2limbside(data,fch,thresh,peakSign)

% error check
%
AVR = data.zoosystem.AVR;                              % Analog/Video rate

if AVR~=1
    disp(['Warning: Force and video channels recorded at different frequencies,'...
          'unable to compare events'])
end
    

sides = {'Right','Left'};
nForcePlates = data.zoosystem.Analog.FPlates.NUMUSED;
fpch = data.zoosystem.Analog.FPlates.LABELS;

units = data.zoosystem.Units.Forces;
if strcmp(units,'N/kg')
    m = data.zoosystem.Anthro.Bodymass;
else
    m = 1;
end


for i = 1:length(sides)
    side = sides{i};
    
    % get and check for kinematic data
    FS = ZeniEventDetect(data,side(1),'FS',thresh);
    if isnan(FS)
        data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = 'none';
        continue
    end
    
    % get force plate events
    FPstk = ones(nForcePlates,1);
    for j = 1:nForcePlates
        yd = m*peakSign*data.([fch,num2str(j)]).line;
        r = find(yd>thresh,1,'first');
        if isempty(r)
            r = inf;
        end
        FPstk(j) = r;
    end
    
    if sum(isinf(FPstk))==nForcePlates
        data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = 'none';
        continue
    end
    
    % associate event with correct limb side
    Diffs = ones(nForcePlates,length(FS));    % rows are FPs, columns are events
    for j = 1:nForcePlates
        Diffs(j,:) = abs(FS-FPstk(j))';
    end
    
    minsRows = min(Diffs,[],2);     % mins in each row (force plate)
    [~,FPindx] = min(minsRows);     % returns indx of correct FP
    
    
    
    % add to zoosystem
    data.zoosystem.Analog.FPlates.LIMBSIDES.(side) = ['FP',num2str(FPindx)];

    % Create GRF channels with side appended
    for j = 1:length(fpch)
        och = fpch{j};
       
        if isin(och,num2str(FPindx))
            nch = [side(1),strrep(och,num2str(FPindx),'')];
            r = data.(och).line;
            data = addchannel(data,nch,r,'Analog');
            data.zoosystem.Analog.FPlates.LABELS{j} = nch;
        end
        
        
    end
    
 
end








