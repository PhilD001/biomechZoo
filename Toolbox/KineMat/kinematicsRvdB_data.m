function data = kinematicsRvdB_data(sdata,data,Pelvis,Thigh,Shank,Foot,sequence,test)

% data = KINEMAT_DATA(sdata,data,Pelvis,Thigh,Shank,Foot,sequence,test) computes
% lower-limb (ankle, knee, hip) joint kinematics
%
% ARGUMENTS
% sdata     ... zoo struct representing static trial
% data      ... zoo struct representing dynamic trial
% Pelvis    ... cell array of markers (min 3) defining pelvis segment
% Thigh     ... cell array of markers (min 3) defining Thigh segment
% Shank     ... cell array of markers (min 3) defining Shank segment
% Foot      ... cell array of markers (min 3) defining Foot segment
% sequence  ... cardan sequence to follow. Default 'yxz'
% test      ... Compare results against PiG computations (boolean). Requires
%               fully processed data file. Default false
% RETURNS
% data      ... zoo struct with lowelimb kinematics appended as
%               'R/L' Ankle, Knee, Hip 'Kinemat'
%
% NOTES
% - Code based on 'cardan.m' part of Reinschmidt and Van den Bogert
%   'kinemat' toolbox: http://isbweb.org/software/movanal/kinemat/
% - For the purposes of comparison with PiG, a right side kinematics offset is
%   added based on PiG static trial. Otherwise, static pose is assumed to
%   have 0 deg in all angles

% Revision History:
%
% Created by Philippe C. Dixon March 18th 2016



% Set defaults
%
if nargin ==2
    Pelvis = {'RASI','LASI','SACR'};
    Thigh  = {'KNE','THI','HipJC'};
    Shank  = {'ANK','TIB','KneeJC'};
    Foot   = {'ANK','TOE','HEE'};
    sequence = 'yxz';
    test = false;
end

if nargin==7
    test = false;
end




% Check if joint centres must be computed before running (slow)
%
if ~isfield(sdata,'RHipJC') && ismember('HipJC',Thigh)
    sdata = hipjointcentrePiG_data(sdata);
    sdata = jointcentrePiG_data(sdata,'Knee');
    sdata = jointcentrePiG_data(sdata,'Ankle');
end

if ~isfield(data,'RHipJC')&& ismember('HipJC',Thigh)
    data = hipjointcentrePiG_data(data);
    data = jointcentrePiG_data(data,'Knee');
    data = jointcentrePiG_data(data,'Ankle');
end



% Initialize Stat anatomical position matrices
%
rowsStat   = length(sdata.(Pelvis{1}).line);
pelvisStat = zeros(rowsStat,length(Pelvis)*3);
thighStat  = zeros(rowsStat,length(Thigh)*3);
shankStat  = zeros(rowsStat,length(Shank)*3);
footStat   = zeros(rowsStat,length(Foot)*3);

% Initialze Dyn trial matrices
%
rowsDyn   = length(data.(Pelvis{1}).line);
pelvisDyn = zeros(rowsDyn,length(Pelvis)*3);
thighDyn  = zeros(rowsDyn,length(Thigh)*3);
shankDyn  = zeros(rowsDyn,length(Shank)*3);
footDyn   = zeros(rowsDyn,length(Foot)*3);



% Compute Kinematics
%
side = {'R','L'};

for j = 1:length(Pelvis)
    pelvisStat(:,3*j-2:3*j) = sdata.(Pelvis{j}).line;
    pelvisDyn(:,3*j-2:3*j)  = data.(Pelvis{j}).line;
end

for i = 1:length(side)
    
    for j = 1:length(Thigh)
        thighStat(:,3*j-2:3*j) = sdata.([side{i},Thigh{j}]).line;
        thighDyn(:,3*j-2:3*j)  = data.([side{i},Thigh{j}]).line;
    end
    
    for j = 1:length(Shank)
        shankStat(:,3*j-2:3*j) = sdata.([side{i},Shank{j}]).line;
        shankDyn(:,3*j-2:3*j)  = data.([side{i},Shank{j}]).line;
    end
    
    for j = 1:length(Foot)
        footStat(:,3*j-2:3*j) = sdata.([side{i},Foot{j}]).line;
        footDyn(:,3*j-2:3*j)  = data.([side{i},Foot{j}]).line;
    end
    
    pelvisStatMean = nanmean(pelvisStat,1);
    thighStatMean  = nanmean(thighStat,1);
    shankStatMean  = nanmean(shankStat,1);
    footStatMean   = nanmean(footStat,1);
    
    % compute angles
    %
    [hipAngles]   = cardan(pelvisStatMean,thighStatMean,pelvisDyn,thighDyn,sequence);
    [kneeAngles]  = cardan(thighStatMean,shankStatMean,thighDyn,shankDyn,sequence);
    [ankleAngles] = cardan(shankStatMean,footStatMean,shankDyn,footDyn,sequence);
    
    % convert to PiG ref system
    %
    kneeAngles(:,1) = -kneeAngles(:,1);
    if side{i} == 'R'
        kneeAngles(:,3)  = -kneeAngles(:,3);
        hipAngles(:,3)   = -hipAngles(:,3);
    else
        hipAngles(:,2)   = -hipAngles(:,2);
        kneeAngles(:,2)  = -kneeAngles(:,2);
    end
    
    if isfield(sdata,'RHipAngles')
        disp('adding PiG static offset angles')
        for j = 1:3
            ankleAngles(:,j) = ankleAngles(:,j) + nanmean(sdata.([side{i},'AnkleAngles']).line(:,j));
            kneeAngles(:,j)  = kneeAngles(:,j)  + nanmean(sdata.([side{i},'KneeAngles']).line(:,j));
            hipAngles(:,j)   = hipAngles(:,j)   + nanmean(sdata.([side{i},'HipAngles']).line(:,j));
        end
    end
    
    % Add to zoosystem channels
    %
    data = addchannel_data(data,[side{i},'HipKinemat'],hipAngles(:,1:3),'Video');
    data = addchannel_data(data,[side{i},'KneeKinemat'],kneeAngles(:,1:3),'Video');
    data = addchannel_data(data,[side{i},'AnkleKinemat'],ankleAngles(:,1:3),'Video');
    
    
    if test ==1
        f = figure;
        set(f,'name',[side{i},' side kinematics'])
        subplot(3,3,1)
        plot(data.([side{i},'HipKinemat']).line(:,1))
        hold on
        plot(data.([side{i},'HipAngles']).line(:,1))
        title('x')
        ylabel('Hip Angles')
        
        subplot(3,3,2)
        plot(data.([side{i},'HipKinemat']).line(:,2))
        hold on
        plot(data.([side{i},'HipAngles']).line(:,2))
        title('y')
        
        subplot(3,3,3)
        plot(data.([side{i},'HipKinemat']).line(:,3))
        hold on
        plot(data.([side{i},'HipAngles']).line(:,3))
        title('z')
        
        subplot(3,3,4)
        plot(data.([side{i},'KneeKinemat']).line(:,1))
        hold on
        plot(data.([side{i},'KneeAngles']).line(:,1))
        ylabel('Knee Angles')
        
        subplot(3,3,5)
        plot(data.([side{i},'KneeKinemat']).line(:,2))
        hold on
        plot(data.([side{i},'KneeAngles']).line(:,2))
        
        subplot(3,3,6)
        plot(data.([side{i},'KneeKinemat']).line(:,3))
        hold on
        plot(data.([side{i},'KneeAngles']).line(:,3))
        
        subplot(3,3,7)
        plot(data.([side{i},'AnkleKinemat']).line(:,1))
        hold on
        plot(data.([side{i},'AnkleAngles']).line(:,1))
        ylabel('Ankle Angles')
        
%         subplot(3,3,8)
%         plot(data.([side{i},'AnkleKinemat']).line(:,2))
%         hold on
%         plot(data.([side{i},'AnkleAngles']).line(:,2))
%         
%         subplot(3,3,9)
%         plot(data.([side{i},'AnkleKinemat']).line(:,3))
%         hold on
%         plot(data.([side{i},'AnkleAngles']).line(:,3))
%         legend('Kinemat','PiG')
%         
    end
    
    
    
    
    
end