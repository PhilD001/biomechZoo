function data = jointcentrePiG_data(data,joint,test)

% data = JOINTCENTREPIG_DATA(data,joint) returns knee, or anke joint centre
% computed via the Plug-in gait methods
%
% ARGUMENTS
%  data       ...  Zoo struct
%  joint      ...  Joint to compute (string): 'knee' or 'ankle'.
%  test       ...  Compare against exisiting PiG data, if available(boolean). Default: false
%
% RETURNS
%  data       ...  zoo struct with joint centre coordinates appended
%
% See also hipjointcentrePiG_data, chordPiG


% Revision history:
%
% Created by Philippe C. Dixon October 2012
% - many bugs
%
% Updated by Philippe C. Dixon july 2016
% - No longer uses symbolic math toolbox
% - root mean squared error between the Vicon and custom calculation of the magintude of the
%   joint centre position stored in the joint centre channel event branch
% - fixed bug with joint widths


% Set defaults/Error checking
%
if nargin==2
    test = false;
end

if strcmp(joint,'ankle')
    joint = 'Ankle';
elseif strcmp(joint,'knee')
    joint = 'Knee';
end

if strcmpi(joint,'hip')
    data = hipjointcentrePiG_data(data,test);
    return
end

% Extract info from zoo file
%
mDiameter = getanthro(data,'MarkerDiameter');
rjointW   = getanthro(data,['R',joint,'Width']);
ljointW   = getanthro(data,['L',joint,'Width']);

if isempty(mDiameter) || isempty(ljointW) || isempty(rjointW)
    error('missing anthropometric information')
end


% Extract required quantites
%
switch joint
    
    case 'Ankle'
        prox = 'KneeJC';
        dist = 'ANK';
        wand = 'TIB';
        if ~isfield(data,['R',prox]);
            data = jointcentrePiG_data(data,'Knee');
        end
        
    case 'Knee'
        prox = 'HipJC';
        dist = 'KNE';
        wand = 'THI';
        
        if ~isfield(data,['R',prox]);
            data = hipjointcentrePiG_data(data);
        end
        
end

jointwidth.R = rjointW;
jointwidth.L = ljointW;

side = {'R','L'};

for i = 1:length(side)
    
    proxJC = data.([side{i},prox]).line;
    wandMk = data.([side{i},wand]).line;
    distMk = data.([side{i},dist]).line;
    
    jointWidth = jointwidth.(side{i});
    delta = (jointWidth/2) + mDiameter/2;
    
    JC = chordPiG(wandMk,proxJC,distMk,delta);
    
    % add to zoosystem
    %
    data = addchannel_data(data,[side{i},joint,'JC'],JC,'Video');
    
    % check with existing data if available
    %
    if strcmp(joint,'Knee')
            jointPiG = 'FEO';
        elseif strcmp(joint,'Ankle')
            jointPiG = 'TIO';
        else
            error('unknown joint')
    end
    
        
    if isfield(data,[side{i},jointPiG])
        vicon  = magnitude(data.([side{i},jointPiG]).line);
        biomechZoo = magnitude(data.([side{i},joint,'JC']).line);
        data.([side{i},joint,'JC']).event.NRMSE = [1 nrmse(vicon,biomechZoo) 0];
    end
    
    % test plots
    if test ==1
        
        
        f = figure;
        set(f,'name',[side{i},' side ',joint, ' centre'])
        subplot(1,3,1)
        plot(data.([side{i},joint,'JC']).line(:,1))
        hold on
        plot(data.([side{i},jointPiG]).line(:,1),'r')
        title('x')
        ylabel([joint,' Centre (mm)'])
        r = mean(data.([side{i},joint,'JC']).line(:,1) - data.([side{i},jointPiG]).line(:,1));
        text(1,mean(data.([side{i},joint,'JC']).line(:,1)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,2)
        plot(data.([side{i},joint,'JC']).line(:,2))
        hold on
        plot(data.([side{i},jointPiG]).line(:,2),'r')
        title('y')
        r = mean(data.([side{i},joint,'JC']).line(:,2) - data.([side{i},jointPiG]).line(:,2));
        text(1,mean(data.([side{i},joint,'JC']).line(:,2)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,3)
        plot(data.([side{i},joint,'JC']).line(:,3))
        hold on
        plot(data.([side{i},jointPiG]).line(:,3),'r')
        title('z')
        r = mean(data.([side{i},joint,'JC']).line(:,3) - data.([side{i},jointPiG]).line(:,3));
        text(1,mean(data.([side{i},joint,'JC']).line(:,3)),['Diff = ',num2str(r),' mm'])
        legend('Matlab','PiG')
        
    end
end


