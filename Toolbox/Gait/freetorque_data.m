function data = freetorque_data(data)

limbs = data.zoosystem.Analog.FPlates.LIMBSIDES;
globalOr = getFPGlobalOrigin(data);
      
if isfield(data,'RightCentreOfPressure')
    side = 'Right';
    COP = data.([side,'CentreOfPressure']).line;
    F = data.([side,'GroundReactionForce']).line;
    M = data.([side,'GroundReactionMoment']).line;
    indx = limbs.(side);
    indx = indx(end);
    Or = globalOr.(['plate',num2str(indx)]);
    
    Tz= free_torque_global(F,M,COP,Or);
    
    data = addchannel_data(data,'RightFreeTorque',Tz,'Analog');


end

if isfield(data,'LeftCentreOfPressure')
    side = 'Left';
    COP = data.([side,'CentreOfPressure']).line;
    F = data.([side,'GroundReactionForce']).line;
    M = data.([side,'GroundReactionMoment']).line;
    indx = limbs.(side);
    indx = indx(end);
    Or = globalOr.(['plate',num2str(indx)]);
    
    Tz= free_torque_global(F,M,COP,Or);
    
    data = addchannel_data(data,'LeftFreeTorque',Tz,'Analog');
    
end

data.zoosystem.Units.FreeTorque = 'Nmm/kg';
