function [data,localjc] = jointCentrePiG(data,joint,mode,test)

% data = kneeJointCentrePiG(data,joint) returns knee or anke joint centre
% using the PiG chord function
%
% ARGUMENTS
%  data     ...    zoo struct
%  joint    ...    compute 'knee' or 'ankle' joint.
%  mode     ...    Method for computation in 'fast' mode, a single frame is
%                  chosen for computation, otherwise computation is repeated
%                  over all frames of data. Default 'fast'.
%
% RETURNS
%  data     ...   zoo struct with right and knee joint centre coordinates
%                 appended as R/L KneeJC'
%
%
% NOTES
% - Code based on Jessica Leitch. The Biomechanics of Patellofemoral Pain Syndrome in Distance
%   Runners. DPhil Thesis. University of Oxford, Department of Engineering Science,2011
%
% - KJC must fulfill the following:
%   1. It lies in the same plane as the HJC and the THI and KNE markers.
%   2. The distance to the KNE marker is half the measured knee width and marker diameter.
%   3. The line from the KJC to the KNE marker is perpendicular to the line from the KJC to the HJC.
%
% - Computation of the PiG "Chord" function uses Matlab's Symbolic Math Toolbox


% Revision history:
%
% Created by Philippe C. Dixon October 2012
%
% Updated by Philippe C. Dixon Jan 2010
% - Incorporated into the zoosystem process


% Part of the Zoosystem Biomechanics Toolbox v1.2
%
% Main contributors:
% Philippe C. Dixon (D.Phil.), Harvard University. Cambridge, USA.
% Yannick Michaud-Paquette (M.Sc.), McGill University. Montreal, Canada.
% JJ Loh (M.Sc.), Medicus Corda. Montreal, Canada.
%
% Contact:
% philippe.dixon@gmail.com or pdixon@hsph.harvard.edu
%
% Web:
% https://github.com/PhilD001/the-zoosystem
%
% Referencing:
% please reference the conference abstract below if the zoosystem was used in the
% preparation of a manuscript:
% Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. The Zoosystem: An Open-Source Movement
% Analysis Matlab Toolbox.  Proceedings of the 23rd meeting of the European Society of
% Movement Analysis in Adults and Children. Rome, Italy.Sept 29-Oct 4th 2014.


% Set defaults
%
if nargin==0
    grab
    mode = 'fast';
    joint = 'Ankle';
    test = 1;
end

if nargin ==2
    mode = 'fast';
    test = 0;
end

if nargin ==3
    test = 0;
end





% Extract required quantites
%
switch joint
    
    case 'Ankle'
        prox = 'KneeJC';
        dist = 'ANK';
        wand = 'TIB';
        if ~isfield(data,['R',prox]);
            data = jointCentrePiG(data,'Knee');
        end
        
    case 'Knee'
        prox = 'HipJC';
        dist = 'KNE';
        wand = 'THI';
        
        if ~isfield(data,['R',prox]);
            data = hipJointCentrePiG(data);
        end
        
end



sides = {'R','L'};

mDiameter = data.zoosystem.Anthro.MarkerDiameter;

localjc = struct;

for j = 1:length(sides)
    
    proxJC = data.([sides{j},prox]).line;
    wandMk = data.([sides{j},wand]).line;
    distMk = data.([sides{j},dist]).line;
    
    jointWidth = data.zoosystem.Anthro.([sides{j},joint,'Width']);
    
    
    %--TRANSLATE GCS TO PLANE COORDINATE SYSTEM (PCS)
    %
    disTr = zeros(size(distMk));
    wandTr = wandMk-distMk;
    proxJCTr = proxJC-distMk;
    
    %--CREATE PCS WITH ORIGIN AT KNEE
    %
    ipl   = makeunit(proxJCTr);
    tempj = makeunit(wandTr);
    kpl   = makeunit(cross(ipl,tempj,2));
    jpl   = makeunit(cross(kpl,ipl,2));
    
    %--CONVERT MARKERS TO PCS
    %
    proxJCpl = zeros(size(distMk));
    disMkpl = zeros(size(distMk));
    wandpl = zeros(size(distMk));
    
    for i = 1:length(distMk)
        PLCS = [ipl(i,:) ; jpl(i,:) ; kpl(i,:)];
        proxJCpl(i,:) = ctransform(gunit,PLCS,proxJCTr(i,:));
        disMkpl(i,:) = ctransform(gunit,PLCS,disTr(i,:));
        wandpl(i,:) = ctransform(gunit,PLCS,wandTr(i,:));
    end
    
    %--SOLVE SYSTEM OF EQUATIONS THAT SATISFIES 1,2,3 (IN PCS)
    %
    JCpl = chordPiG(proxJCpl,distMk,jointWidth,mDiameter,mode);
    
 
    % Transform to global
    %    
    if strcmp(mode,'fast')
        ipl =  nanmean(ipl);
        jpl =  nanmean(jpl);
        kpl =  nanmean(kpl);
        PLCS = [ipl; jpl; kpl];
        
        jc = ctransform(PLCS,gunit,JCpl);  % transform to GCS
        
    else
        jc = zeros(allFrames,3);
        for i = 1:length(jc)
            PLCS = [ipl(i,:) ; jpl(i,:) ; kpl(i,:)];
            jc(i,:) = ctransform(PLCS,gunit,JCpl(i,:));
        end
        
    end
    
    JC(:,1) = data.([sides{j},dist]).line(:,1)+jc(:,1);
    JC(:,2) = data.([sides{j},dist]).line(:,2)+jc(:,2);
    JC(:,3) = data.([sides{j},dist]).line(:,3)+jc(:,3);
    
    localjc.([sides{j},joint,'JC']) = jc;
    
    % add to zoosystem
    %
    data = addchannel(data,[sides{j},joint,'JC'],JC,'Video');
    
     % test plots
    if test ==1
        
        if strcmp(joint,'Knee')
            jointPiG = 'FEO';
        elseif strcmp(joint,'Ankle')
            jointPiG = 'AJC';
        else
            error('unknown joint')
        end
        f = figure;
        set(f,'name',[sides{j},' side ',joint, ' centre'])
        subplot(1,3,1)
        plot(data.([sides{j},joint,'JC']).line(:,1))
        hold on
        plot(data.([sides{j},jointPiG]).line(:,1))
        title('x')
        ylabel([joint,' Centre (mm)'])
        r = mean(data.([sides{j},joint,'JC']).line(:,1) - data.([sides{j},jointPiG]).line(:,1));
        text(1,mean(data.([sides{j},joint,'JC']).line(:,1)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,2)
        plot(data.([sides{j},joint,'JC']).line(:,2))
        hold on
        plot(data.([sides{j},jointPiG]).line(:,2))
        title('y')
        r = mean(data.([sides{j},joint,'JC']).line(:,2) - data.([sides{j},jointPiG]).line(:,2));
        text(1,mean(data.([sides{j},joint,'JC']).line(:,2)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,3)
        plot(data.([sides{j},joint,'JC']).line(:,3))
        hold on
        plot(data.([sides{j},jointPiG]).line(:,3))
        title('z')
        r = mean(data.([sides{j},joint,'JC']).line(:,3) - data.([sides{j},jointPiG]).line(:,3));
        text(1,mean(data.([sides{j},joint,'JC']).line(:,3)),['Diff = ',num2str(r),' mm'])
        legend('Matlab','PiG')
    
    end
end


