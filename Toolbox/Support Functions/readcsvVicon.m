function r = readcsvVicon(fl)

% r = READCSVVICON(fl)reads csv files generated by the Vicon Nexus 
%
% ARGUMENTS
%  fl    ...  Full file name and path of csv file (string)
%
% RETURNS
%  r     ...  Structured array
%
% NOTES
% - Files should be exported using LEgacy "Export data to ASCII file" function
% - all outputs should be checked in "ASCII Dump options"
% - "Invalid co-ordinate value" should be left blank
% - Gait events identified in Nexus will appear under the event branch of the
%   SACR channel if it exists, otherwise, they will appear in the the first channel
%   in the video channel list
%
%
% Created by Philippe C. Dixon October 2012
%
% Updated by Philippe C. Dixon November 2013
% - event bug fixed



% Read csv file and clean up
%
txt= readtext(fl);                      % very slow
txt(cellfun(@isempty,txt)) = {NaN};     % clean

% Setup export variablres
%
r = struct;


% Find indices of each data types in csv file
%
INDXANALYSIS =[];
INDXEVENTS = [];                        % some events define in Vicon
INDXTRAJ = [];                          % the markers and model outputs
INDXANALOG = [];                        % analog data e.g. EMG
INDXFP = [];                            % force plate data

for j = 1:length(txt(:,1))
    
    if strcmp('ANALYSIS',txt{j,1})
        INDXANALYSIS = j;
    elseif strcmp('EVENTS',txt{j,1})
        INDXEVENTS = j;
    elseif  strcmp('TRAJECTORIES',txt{j,1})
        INDXTRAJ = j;
    elseif strcmp('ANALOG',txt{j,1})
        INDXANALOG = j;
    elseif strcmp('FORCE PLATES',txt{j,1})
        INDXFP = j;
    end
end

INDXALL = [INDXANALYSIS; INDXEVENTS; INDXTRAJ; INDXANALOG; INDXFP];


% Extract header information ------------------------------------------------------------------
%
% - Header is all information before first data section in capitals

if isempty(INDXALL)
    r = [];
    return
end

header = txt(1:INDXALL(1)-2,1:2);

for i = 1:length(header)
    field = header{i,1};
    field = makevalidfield(field);
    r.Header.(field) = header{i,2};
end


% Extract trajectory data ---------------------------------------------------------------------
%
vidfreq = txt(INDXTRAJ+1);
vidfreq = vidfreq{1};

vch = txt(INDXTRAJ+2,:);

INDXNEXT = find(INDXALL>INDXTRAJ,1,'first');
INDXNEXT = INDXALL(INDXNEXT);

r.Video.Data = cell2mat(txt(INDXTRAJ+4:INDXNEXT-2,:)); % all marker data

istk = ones(length(vch),1);
chstk = cell(length(vch),1);
for i = 1:length(vch)
    ch = vch{i};
    
    if ~isnan(ch)
        istk(i) = i;
        chstk{i} = ch;
    end
end

chstk(cellfun(@isempty,chstk)) = [];
r.Video.Channels = chstk; % overwrite vch with final video channels
r.Video.Freq = vidfreq;



% Extract event information
%
if ~isempty(INDXEVENTS)
    INDXNEXT = find(INDXALL>INDXEVENTS,1,'first');
    INDXNEXT = INDXALL(INDXNEXT);
    
    sframe = cell2mat(txt(INDXNEXT+4));
    nevents = INDXNEXT-INDXEVENTS-3;
    
    LeftFS = [];
    LeftFO = [];
    RightFS = [];
    RightFO = [];
    
    for i=1:nevents
        
        basename = [txt{INDXEVENTS+1+i,2} txt{INDXEVENTS+1+i,3}];
        basename = strrep(basename,' ','');
        val = txt{INDXEVENTS+1+i,4};
        val = val*vidfreq - sframe+1;
        val = round(val); % simply removes .000 from end of event
        
        if isin(basename,'LeftFootStrike')
            LeftFS = [LeftFS;val]; %#ok<AGROW>
            
        elseif isin(basename,'LeftFootOff')
            LeftFO = [LeftFO;val];%#ok<AGROW>
            
        elseif isin(basename,'RightFootStrike')
            RightFS = [RightFS;val];%#ok<AGROW>
            
        elseif isin(basename,'RightFootOff');
            RightFO = [RightFO;val];%#ok<AGROW>
            
        else
            disp('event name not found')
        end
        
    end
    
    LeftFS = sort(LeftFS);
    LeftFO = sort(LeftFO);
    RightFS = sort(RightFS);
    RightFO = sort(RightFO);
    
    for j = 1:length(LeftFS)
        r.Events.(['LeftFS',num2str(j)]) = [LeftFS(j) 0 0];
    end
    
    for k = 1:length(LeftFO)
        r.Events.(['LeftFO',num2str(k)]) = [LeftFO(k) 0 0];
    end
    
    for l = 1:length(RightFS)
        r.Events.(['RightFS',num2str(l)]) = [RightFS(l) 0 0];
    end
    
    for m = 1:length(RightFO)
        r.Events.(['RightFO',num2str(m)]) = [RightFO(m) 0 0];
    end
    
end



% Extract Analog chanels ----------------------------------------------------------------------
%
if ~isempty(INDXANALOG)
    
    analfreq = txt(INDXANALOG+1);
    analfreq = analfreq{1};
    
    INDXNEXT = find(INDXALL>INDXANALOG,1,'first');
    INDXNEXT = INDXALL(INDXNEXT);
    
    r.Analog.Data = cell2mat(txt(INDXANALOG+4:INDXNEXT-2,:)); % all marker Data
    
    ach = txt(INDXANALOG+2,2:end);  % removes the first column (sample num
    
    chstk = cell(length(ach),1);
    for i = 1:length(ach)
        if ~isnan(ach{i})
            chstk{i} = ach{i};
        end
    end
    
    chstk(cellfun(@isempty,chstk)) = [];
    
    r.Analog.Channels = ['frames';chstk];
    r.Analog.Freq = analfreq;
end



% Extract force plate information
%
if ~isempty(INDXFP)
    
    fpfreq = txt(INDXFP+1);
    fpfreq = fpfreq{1};
   
    subtxt = (txt(INDXFP:end,1));
    
    rr = zeros(length(subtxt),1,'single');
    for i = 1:length(subtxt)
        rr(i)= isin(subtxt{i},'Sample #');
    end
    INDXFPch = find(rr==1,1,'first');
    INDXFPch = INDXFP+INDXFPch-1;
    
    fpch = txt(INDXFPch,2:end); % remove column 1
    r.Forces.Data = cell2mat(txt(INDXFPch+2:end,:)); % all marker Data
    
    chstk = cell(length(fpch),1);
    for i = 1:length(fpch)
        if ~isnan(fpch{i})
            
            if ~isempty(strfind(fpch{i},'Force'))
                fpch{i} = strrep(fpch{i},'Force','ForceF');
                temp = fpch{i};
                temp = temp(end);
                fpch{i} = strrep(fpch{i},temp,lower(temp));
                
            elseif ~isempty(strfind(fpch{i},'Moment'))
                fpch{i} = strrep(fpch{i},'Moment','MomentM');
                temp = fpch{i};
                temp = temp(end);
                fpch{i} = strrep(fpch{i},temp,lower(temp));
            elseif ~isempty(strfind(fpch{i},'COP'))
                temp = fpch{i};
                temp(end) = lower(temp(end));
                temp = [temp(1:end-1),'_',temp(end)];
                fpch{i} = temp;
            end
            
            chstk{i} =fpch{i};
        end
    end
    
    chstk(cellfun(@isempty,chstk)) = [];
    fpch = chstk(1:end);
    
    r.Forces.Freq = fpfreq;
    r.Forces.Channels = fpch;
    r.Forces.Data = r.Forces.Data(:,1:length(fpch)+1);   % all fpch columns + the index column


    % extract corner information
    %
    c = txt(INDXFP+4:INDXFPch-3,2:13); % remove column 1
    [rows,cols] = size(c);
    stk = zeros(3,4,rows);
    for i = 1:rows
        plate = cell2mat(c(i,:));
        stk(:,:,i) = [plate(1:3)' plate(4:6)' plate(7:9)' plate(10:12)'];
    end
    r.Forces.FPlates.CORNERS = stk;
    r.Forces.FPlates.NUMUSED = rows;
    
end





