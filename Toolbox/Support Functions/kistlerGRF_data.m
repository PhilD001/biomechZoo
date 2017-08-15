function data = kistlerGRF_data(data)

% data = KISTLERGRF_data(data) computes GRF data for Kistler force
% plates based on equations from kistler:
% http://isbweb.org/software/movanal/vaughan/kistler.pdf 
%
% ARGUMENTS
%  data    ...  data to operate on
%
% RETURNS 
% data     ...  new data with GRF channels computed
%
% NOTES
% - all outputs are in Kistler coordinate syste, (local)


% Created by Philippe C. Dixon November 20th 2015





% find number of force plates
%
numPlates = data.zoosystem.Analog.FPlates.NUMUSED;

lbls = data.zoosystem.Analog.FPlates.LABELS;

localOr = getFPLocalOrigin(data);                               % true local FP origin

for i = 1:numPlates
    
    a  = localOr.(['FP',num2str(i)])(1);     % mm
    b = localOr.(['FP',num2str(i)])(2);  
            
    fx1 = data.(['F',num2str(i),'X1']).line; % N
    fx3 = data.(['F',num2str(i),'X3']).line;
    fy1 = data.(['F',num2str(i),'Y1']).line;
    fy2 = data.(['F',num2str(i),'Y2']).line;
    fz1 = data.(['F',num2str(i),'Z1']).line;
    fz2 = data.(['F',num2str(i),'Z2']).line;
    fz3 = data.(['F',num2str(i),'Z3']).line;
    fz4 = data.(['F',num2str(i),'Z4']).line;
        
    Fx = fx1 + fx3;                            % N
    Fy = fy1 + fy2;
    Fz = fz1 + fz2 + fz3 + fz4;
    
    Mx = b * ( fz1 + fz2 - fz3 - fz4);         % N*mm
    My = a * (-fz1 + fz2 + fz3 - fz4);
    Mz = b * (-fx1 + fx3) + a * (fy1 - fy2);
    
    Fx = -Fx;  % display upwards in director
    Fy = -Fy;
    Fz = -Fz;
    
    data = addchannel_data(data,['ForceFx',num2str(i)],Fx,'analog');
    data = addchannel_data(data,['ForceFy',num2str(i)],Fy,'analog');
    data = addchannel_data(data,['ForceFz',num2str(i)],Fz,'analog');
    
    data = addchannel_data(data,['MomentMx',num2str(i)],Mx,'analog');
    data = addchannel_data(data,['MomentMy',num2str(i)],My,'analog');
    data = addchannel_data(data,['MomentMz',num2str(i)],Mz,'analog');
    
    % Compute Tz from existing COP
    %
%     F = [Fx Fy Fz];
%     M = [Mx My Mz];
%     COPg = data.(['COP',num2str(i)]).line;
%     globalOr = getFPGlobalOrigin(data);
%     Tz = free_torque_global(F,M,COPg,globalOr.(['FP',num2str(i)]));
%   
%     data = addchannel_data(data,['Tz',num2str(i)],Tz,'analog');

    
    
lbls = [lbls;['ForceFx',num2str(i)];['ForceFy',num2str(i)];['ForceFz',num2str(i)];...
             ['MomentMx',num2str(i)];['MomentMy',num2str(i)];['MomentMz',num2str(i)],...
             ['Tz',num2str(i)]];

end


% Compute Centre of pressure
%
[globalOr,orientFP] = getFPGlobalOrigin(data);
data = centreofpressure_data(data,localOr,globalOr,orientFP);  % compute cop w orientFP

    
% Compute Free vertical torque
%



% add meta information
%
data.zoosystem.Analog.FPlates.Manufacturer = 'Kistler';
data.zoosystem.Units.Forces = 'N';
data.zoosystem.Units.Moments = 'Nmm';
data.zoosystem.Units.CentreOfPressure = 'mm';

data.zoosystem.Analog.FPlates.LABELS = lbls;

