function data = fprename_data(data)

% data = FPRENAME_data(data) renames raw 'ForceFx1'channels to BiomechZoo
% style e.g. 'RightGroundReactonForce'


FP = data.zoosystem.Analog.FPlates.LIMBSIDES;

% reassign fields----
%
if isfield(data,'Fx1')
    sufF = 'F';
    sufM = 'M';
elseif isfield(data,'ForceFx1')
    sufF = 'ForceF';
    sufM = 'MomentM';
end

data.zoosystem.Analog.FPlates.LABELS = {}; % clear labels

indxR = FP.Right;
if ~isin(indxR,'invalid')
    indxR = num2str(indxR(end));
    
    f = [data.([sufF,'x',indxR]).line data.([sufF,'y',indxR]).line data.([sufF,'z',indxR]).line];
    m = [data.([sufM,'x',indxR]).line data.([sufM,'y',indxR]).line data.([sufM,'z',indxR]).line];
    c =  data.(['COP',indxR]).line;
    
    data = addchannel_data(data,'RightGroundReactionForce',f,'Video');
    data = addchannel_data(data,'RightGroundReactionMoment',m,'Video');
    data = addchannel_data(data,'RightCentreOfPressure',c,'Video');
    
    data.zoosystem.Analog.FPlates.LABELS{1} = 'RightGroundReactionForce';
    data.zoosystem.Analog.FPlates.LABELS{2} = 'RightGroundReactionMoment';
end

indxL = FP.Left;
if ~isin(indxL,'invalid')
    indxL = num2str(indxL(end));
    
    f = [data.([sufF,'x',indxL]).line data.([sufF,'y',indxL]).line data.([sufF,'z',indxL]).line];
    m = [data.([sufM,'x',indxL]).line data.([sufM,'y',indxL]).line data.([sufM,'z',indxL]).line];
    c =  data.(['COP',indxL]).line;
    
    data = addchannel_data(data,'LeftGroundReactionForce',f,'Video');
    data = addchannel_data(data,'LeftGroundReactionMoment',m,'Video');
    data = addchannel_data(data,'LeftCentreOfPressure',c,'Video');
    
    if isempty( data.zoosystem.Analog.FPlates.LABELS)
        data.zoosystem.Analog.FPlates.LABELS{1} = 'LeftGroundReactionForce';
        data.zoosystem.Analog.FPlates.LABELS{2} = 'LeftGroundReactionMoment';
    else
        data.zoosystem.Analog.FPlates.LABELS{3} = 'LeftGroundReactionForce';
        data.zoosystem.Analog.FPlates.LABELS{4} = 'LeftGroundReactionMoment';
    end
end

data.zoosystem.Units.Forces = 'N';
data.zoosystem.Units.Moment = 'Nmm';