function data = fpaddzeros(data)

% Updated Jaunuary 3rd 2014 by Philippe C. Dixon
%
% Serch for nans changed to COP instead of GroundReactionForce data. This is the exact right interval based
% on the 'thresh' setting in COP_oneplate.m
%
% Updated Feb 10th 2014
% - cleaned-up function.

    


    
    
if isfield(data,'RightGroundReactionForce')
    
    indx= find(isnan(data.RightCentreOfPressure.line(:,1)));
    data.RightGroundReactionForce.line(indx,:)=0;
    data.RightGroundReactionMoment.line(indx,:)=0;
    
    data.RightCentreOfPressure.line(indx,:)=0;
    
    
end


if isfield(data,'LeftGroundReactionForce')
    
    indx= find(isnan(data.LeftCentreOfPressure.line(:,1)));
    data.LeftGroundReactionForce.line(indx,:)=0;
    data.LeftGroundReactionMoment.line(indx,:)=0;
    
    data.LeftCentreOfPressure.line(indx,:)=0;
end

    
    
    
    



    