function data = grfref_data(data,orientFP)

% data = GRFREF_DATA (data,orientFP) reorientes GRF data based on global
% coordinates

% updated October 20th 2013
% - Full functionality with FP3

% FP1 = data.zoosystem.CompInfo.FP1;
% FP2 = data.zoosystem.CompInfo.FP2;

FP = data.zoosystem.Analog.FPlates.LIMBSIDES;


indxR = FP.Right;
if ~isin(indxR,'invalid')
    indxR = num2str(indxR(end));

    Fx = data.RightGroundReactionForce.line(:,1);
    Fy = data.RightGroundReactionForce.line(:,2);
    Fz = data.RightGroundReactionForce.line(:,3);
    
    Mx = data.RightGroundReactionMoment.line(:,1);
    My = data.RightGroundReactionMoment.line(:,2);
    Mz = data.RightGroundReactionMoment.line(:,3);
    
    F = [Fx Fy Fz];
    M = [Mx My Mz];
    
    F_rot = ctransform_line(F,gunit,orientFP.(['FP',indxR]));
    M_rot = ctransform_line(M,gunit,orientFP.(['FP',indxR]));

    data.RightGroundReactionForce.line = F_rot;
    data.RightGroundReactionMoment.line = M_rot;

end

indxL = FP.Left;
if ~isin(indxL,'invalid')
    indxL = num2str(indxL(end));

    Fx = data.LeftGroundReactionForce.line(:,1);
    Fy = data.LeftGroundReactionForce.line(:,2);
    Fz = data.LeftGroundReactionForce.line(:,3);
    
    Mx = data.LeftGroundReactionMoment.line(:,1);
    My = data.LeftGroundReactionMoment.line(:,2);
    Mz = data.LeftGroundReactionMoment.line(:,3);
    
    F = [Fx Fy Fz];
    M = [Mx My Mz];
    
    F_rot = ctransform_line(F,gunit,orientFP.(['FP',indxL]));
    M_rot = ctransform_line(M,gunit,orientFP.(['FP',indxL]));
    
    data.LeftGroundReactionForce.line = F_rot;
    data.LeftGroundReactionMoment.line = M_rot;
end


% 
% %-----test better code----
% 
% 
% if isin(FP1,'Left')
%     FL_rot = ctransform_line(FL,gunit,orientFP.FP1);
%     ML_rot = ctransform_line(ML,gunit,orientFP.FP1);
%     
% elseif isin(FP2,'Left')
%     FL_rot = ctransform_line(FL,gunit,orientFP.FP2);
%     ML_rot = ctransform_line(ML,gunit,orientFP.FP2);
%     
% 
% else
%     disp('no left')
%     
% end
% 
% if isin(FP1,'Right')
%     FR_rot = ctransform_line(FR,gunit,orientFP.FP1);
%     MR_rot = ctransform_line(MR,gunit,orientFP.FP1);
%     
%     
% elseif isin(FP2,'Right')
%     FR_rot = ctransform_line(FR,gunit,orientFP.FP2);
%     MR_rot = ctransform_line(MR,gunit,orientFP.FP2);
%     
% 
% else
%     disp('no right')
% end
% 
% 
% 
% %---write to zoosystem----
% if isfield(data,'RightGroundReactionForce')
%     data.RightGroundReactionForce.line  = FR_rot;  % [Fx_r Fy_r Fz_r];
%     data.RightGroundReactionMoment.line = MR_rot; % [Mx_r My_r Mz_r];
% end
% 
% if isfield(data,'LeftGroundReactionForce')
%     data.LeftGroundReactionForce.line  = FL_rot; % [Fx_l Fy_l Fz_l];
%     data.LeftGroundReactionMoment.line = ML_rot; % [Mx_l My_l Mz_l];
% end

