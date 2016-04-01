function data = hipJointCentrePiG(data,markerRadius,rLegLength,lLegLength,test)

% data = hipJointCenterPiG(data,markerRadius,rLegLength,lLegLength) computes left
% and right hip joint centers for plug-in gait marker data
%
% ARGUMENTS
%  data                  ... zoo structured array containing PiG markers. Required markers
%                            are 'RASI','LASI','SACR' or 'RASI','LASI','RPSI','LPSI'
%  markerRadius          ... Radius of marker (mm). If not entered, program will search for
%                            value stored in 'data.zoosystem.Anthro.MarkerDiameter'.
%  rLegLength,lLegLength ... Leg lengths of subjects (m). If not entered, program will search
%                            for values stored in 'data.zoosystem.Anthro.RLegLength' and
%                            'data.zoosystem.Anthro.LLegLength',respectively.
%  test                  ... Tests hip joint centre calculation against PiG values. Data must
%                            have been processed in Vicon PiG modeller to obtain 'RHJC','LHJC' 
%                            virtual markers. Default = 0 (off).
%                            
% RETURNS
%  data                  ... zoo structed array with appended hip joint center virtual
%                            markers (RHipJC and LHipJC).
%
% NOTES
% - computation method based on Davis et al. "A gait analysis data collection and reduction
%   technique". Hum Mov Sci. 1991. (see also PiG manual)
% - If zoo files don't contain anthro data (e.g. contain only PiG markers), user must add
%   these fields to zoo files in a previous step, or enter antrho values as arguments


% Revision History
%
% Created by Yannick Michaud-Paquette 2008
%
% Updated by Philippe C. Dixon march 2016
% - reformatted code for batch processing
% - results expressed in global coordinates


% Part of the Zoosystem Biomechanics Toolbox v1.2 Copyright (c) 2006-2016
% Main contributors: Philippe C. Dixon, Yannick Michaud-Paquette, and J.J Loh
% More info: type 'zooinfo' in the command prompt

% Set defaults
%
if nargin==1
    markerRadius = [];                                              % enter here or as args
    rLegLength = [];                                                % if unavalible in
    lLegLength = [];                                                % anthro branch
    test = 0;
end

if nargin==4
    test = 0;
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
   markerRadius = data.zoosystem.Anthro.MarkerDiameter/2;
   rLegLength = data.zoosystem.Anthro.RLegLength;
   lLegLength = data.zoosystem.Anthro.LLegLength;
end


% compute basic quantities
%
interAsis = magnitude(data.LASI.line - data.RASI.line);
interAsis = mean(interAsis);
legLength = mean([rLegLength lLegLength]);



% Define pelvis coordinate system
%
PELO = (LASI + RASI)/2;                                                      % origin (O)
PELy = makeunit(LASI-PELO);                                                  % lateral (L)
PELtemp = SACR - PELO;                                                       % temp anterior
PELz = makeunit(cross(PELy,PELtemp));                                        % proximal (P)
PELx = makeunit(cross(PELy,PELz));                                           % anterior (A)


% Compute hip joint centers
%
side = {'R','L'};

for i = 1:length(side)
    asisTrocDist = data.zoosystem.Anthro.([side{i},'AsisTrocanterDistance']);
    
    if asisTrocDist == 0
        asisTrocDist = (0.1288*legLength)-48.56;                           % PiG manual
    end
    
    C = (legLength*0.115) - 15.3;                                          % (4) Davis 1991
    
    HipPCSx = C*COSTHETA*SINBETA - (asisTrocDist + markerRadius)*COSBETA;  % (5) Davis 1991 (A)
    HipPCSy = -(C*SINTHETA - (interAsis/2));                               % (6) Davis 1991 (L)
    HipPCSz = -C*COSTHETA*COSBETA - (asisTrocDist + markerRadius)*SINBETA; % (7) Davis 1991 (P)
    
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
    data = addchannel(data,[side{i},'HipJC'],HipGCS,'Video');
    
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


