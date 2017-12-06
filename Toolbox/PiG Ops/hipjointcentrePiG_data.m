function [data,localjc] = hipjointcentrePiG_data(data,test)

% data = HIPJOINTCENTREPIG_DATA(data,test) computes left and right hip joint centers for
% plug-in gait (PiG) marker data
%
% ARGUMENTS
%  data      ... Zoo data containing PiG markers. Required markers are 'RASI','LASI','SACR'
%                or 'RASI','LASI','RPSI','LPSI'
%  test      ... Tests against PiG values, if available (boolean). Default: false
%
% RETURNS
%  data      ... Zoo data with appended hip joint center virtual marker as RHipJC and LHipJC.
%  localjc   ... Coordinates of the hip joint centre (struct) in local coordinates
%
% NOTES
% - computation method based on Davis et al. "A gait analysis data collection and reduction
%   technique". Hum Mov Sci. 1991. (see also PiG manual)
% - If zoo files don't contain anthro data (e.g. contain only PiG markers), user must add
%   these fields to zoo files in a previous step, or enter antrho values as arguments
% - root mean squared error between the Vicon and custom calculation of the magitude of the
%   hip joint centre position stored in the hip joint centre channel event branch
%
% See also bmech_jointcentrePiG, jointCenterPiG


% Revision History
%
% Created by Yannick Michaud-Paquette 2008
%
% Updated by Philippe C. Dixon march 2016
% - reformatted code for batch processing
% - results expressed in global coordinates
%
% Updated by Philippe C. Dixon July 2016
% - computes error wrt to vicon if data are available

% Set defaults/Error check
%
if nargin==1
    test = false;
end

COSBETA  = cos(0.314);                                              % 18.0 deg Davis 1991
SINBETA  = sin(0.314);
COSTHETA = cos(0.496);                                              % 28.4 deg Davis 1991
SINTHETA = sin(0.496);


% Extract pelvis marker positions
%
if ~isfield(data,'RASI')
    error('PiG Pelvis markers must be present for processing')
else
    RASI = data.RASI.line;
    LASI = data.LASI.line;
end

if isfield(data,'RPSI')
    RPSI = data.RPSI.line;
    LPSI = data.LPSI.line;
    SACR = (RPSI+LPSI)/2;
else
    SACR = data.SACR.line;
end


% Extract info from data
%
if isfield(data.zoosystem,'Anthro')
    mDiam = getanthro(data,'MarkerDiameter');
    rLegLength = getanthro(data,'RLegLength');
    lLegLength = getanthro(data,'LLegLength');
else
    error('anthropometric info must be added before running this process')
end


% compute basic quantities
%
if isempty(findfield(data,'InterAsisDistance'))
    interAsis = magnitude(data.LASI.line - data.RASI.line);
    interAsis = nanmean(interAsis);
    data.zoosystem.Anthro.InterAsisDistance = interAsis;
else
    interAsis = findfield(data,'InterAsisDistance');
end

legLength = mean([rLegLength lLegLength]);



% Define pelvis coordinate system
%
PELO = (LASI + RASI)/2;                                                % origin (O)
PELy = makeunit(LASI-PELO);                                            % lateral (L)
PELtemp = SACR - PELO;                                                 % temp anterior
PELz = makeunit(cross(PELy,PELtemp));                                  % proximal (P)
PELx = makeunit(cross(PELy,PELz));                                     % anterior (A)


% Compute hip joint centers
%
side = {'R','L'};
localjc = struct;

for i = 1:length(side)
    
    % check if ASIS-TROC distance is known
    %
    if isfield(data.zoosystem.Anthro,[side{i},'AsisTrochanterDistance'])
        asisTroc =  data.zoosystem.Anthro.([side{i},'AsisTrochanterDistance']);
        if asisTroc ==0
            asisTroc = [];
        end
    else
        asisTroc = [];
    end
    
    % compute ASIS Troc if required
    if isempty(asisTroc)
        
        % GTR is available but ASIS-TROC has not been computed
        %
        if isfield(data,[side{i},'GTR'])
            asisTroc = magnitude(data.([side{i},'ASI']).line-data.([side{i},'GTR']).line);
            asisTroc = nanmean(asisTroc);
            data.zoosystem.Anthro.([side{i},'AsisTrochanterDistance']) = asisTroc;
            
        else
            asisTroc = (0.1288*legLength)-48.56;                           % PiG manual
            data.zoosystem.Anthro.([side{i},'AsisTrochanterDistance']) = asisTroc;
        end
    end
    
    
    
    C = (legLength*0.115) - 15.3;                                      % (4) Davis 1991
    
    HipPCSx = C*COSTHETA*SINBETA - (asisTroc + mDiam/2)*COSBETA;       % (5) Davis 1991 (A)
    HipPCSy = -(C*SINTHETA - (interAsis/2));                           % (6) Davis 1991 (L)
    HipPCSz = -C*COSTHETA*COSBETA - (asisTroc + mDiam/2)*SINBETA;      % (7) Davis 1991 (P)
    
    if side{i}=='R'
        HipPCSy =  -HipPCSy;
    end
    
    HipPCS = [HipPCSx HipPCSy HipPCSz];
    
    % Transform from pelvis coordinate system to global coordinate system
    HipGCS = ones(size(RASI));
    GCS = gunit;
    for j = 1:length(RASI)
        PCS = [PELx(j,:); PELy(j,:) ; PELz(j,:)];
        HipGCS(j,:) = ctransform(PCS,GCS,HipPCS)+PELO(j,:);
    end
    
    % add to zoosystem
    data.zoosystem.Anthro.([side{i},'AsisTrochanterDistance']) = asisTroc;
    data = addchannel_data(data,[side{i},'HipJC'],HipGCS,'Video');
    
    
    % add pelvis based to struct
    %
    localjc.(side{i}) = HipPCS;
    
    
    % check with existing data if available
    %
    if isfield(data,[side{i},'HJC'])
        vicon  = magnitude(data.([side{i},'HJC']).line);
        matlab = magnitude(data.([side{i},'HipJC']).line);
        data.([side{i},'HipJC']).event.RMSerror = [1 rmse(vicon,matlab) 0];
    end
    
    
    % test plots
    if test ==1
        f = figure;
        set(f,'name',[side{i},' side hip joint centres'])
        subplot(1,3,1)
        plot(data.([side{i},'HipJC']).line(:,1))
        hold on
        plot(data.([side{i},'HJC']).line(:,1))
        title('x')
        ylabel('Hip Joint Centre (mm)')
        r = mean(data.([side{i},'HipJC']).line(:,1) - data.([side{i},'HJC']).line(:,1));
        text(1,mean(data.([side{i},'HJC']).line(:,1)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,2)
        plot(data.([side{i},'HipJC']).line(:,2))
        hold on
        plot(data.([side{i},'HJC']).line(:,2))
        title('y')
        r = mean(data.([side{i},'HipJC']).line(:,2) - data.([side{i},'HJC']).line(:,2));
        text(1,mean(data.([side{i},'HJC']).line(:,2)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,3)
        plot(data.([side{i},'HipJC']).line(:,3))
        hold on
        plot(data.([side{i},'HJC']).line(:,3))
        title('z')
        r = mean(data.([side{i},'HipJC']).line(:,3) - data.([side{i},'HJC']).line(:,3));
        text(1,mean(data.([side{i},'HJC']).line(:,3)),['Diff = ',num2str(r),' mm'])
        legend('Matlab','PiG')
    end
    
    
end



% test ctransform
%
% GCS = [1 0 0; 0 1 0; 0 0 1];
% PCS = [0.996 0.08 0; -0.08 0.996 0; 0 0 1];
%
% PELO_GCS = [2 2 0];
% a_PCS = [1 2 0];
%
% a_GCS = ctransform(PCS,GCS,a_PCS)+PELO_GCS;   %


