function bmech_imu_joint_angle(fld,parameters,segment_pairs)

% ARGUMENTS
%  fld              ...   root folder to operate on
%  parameters       ...   Struct, with the complementary filter parameters setttings
%  segment_pairs    ...   Cell Array, combination of the sensors used for calculating joint angle
% RETURNS
%  zoo file with new added channels hipR_flex, hipL_flex, kneeR_flex, kneeL_flex
% Also see, quaternion_line_v2

if nargin==2
    segment_pairs = { {'trunk', 'thighR'}, {'thighR', 'shankR'},{'trunk', 'thighL'},{'thighL', 'shankL'}};
end
if nargin==1
    segment_pairs = { {'trunk', 'thighR'}, {'thighR', 'shankR'},{'trunk', 'thighL'},{'thighL', 'shankL'}};
    parameters.SampleRate=100;
    parameters.AccelerometerGain=0.01;
    parameters.MagnetometerGain=0.01;
    parameters.HasMagnetometer=True;
    parameters.OrientationFormat="quaternion";
end

if nargin==0
    segment_pairs = { {'trunk', 'thighR'}, {'thighR', 'shankR'},{'trunk', 'thighL'},{'thighL', 'shankL'}};
    parameters.SampleRate=100;
    parameters.AccelerometerGain=0.01;
    parameters.MagnetometerGain=0.01;
    parameters.HasMagnetometer=True;
    parameters.OrientationFormat="quaternion";
    fld=uigetfolder;
end

fl = engine('fld', fld, 'extension', 'zoo');
for i = 1:length(fl)
    batchdisp(fl{i}, 'computing joint angles')
    data = zload(fl{i});
    data = joint_angle_data(data, segment_pairs,parameters);
    zsave(fl{i},data)
end

function data = joint_angle_data(data, segment_pairs,parameters)


for i = 1:length(segment_pairs)
    
    segment_pair = segment_pairs{i};
    
    % right hip
    if ismember({'trunk', 'thighR'}, segment_pair)
        Qtrunk= quaternion_line_v2(data,'trunk',parameters);
        QthighR= quaternion_line_v2(data,'thighR',parameters);
        QhipR = conj(Qtrunk) .* QthighR;
        QhipR=quat2eul(QhipR);
        hipR_flex= -rad2deg(QhipR);
        
        data = addchannel_data(data,"hipR_flex",hipR_flex(:,2),'Video');
    end
    
    % right knee
    if ismember({'thighR', 'shankR'}, segment_pair)
        QthighR= quaternion_line_v2(data,'thighR',parameters);
        QshankR= quaternion_line_v2(data,'shankR',parameters);
        QkneeR =conj(QthighR) .*QshankR;
        QkneeR=quat2eul(QkneeR);
        kneeR_flex = -rad2deg(QkneeR);
        data = addchannel_data(data,"kneeR_flex",kneeR_flex(:,1),'Video');
    end
    
    % left hip
    if ismember({'trunk', 'thighL'}, segment_pair)
        Qtrunk= quaternion_line_v2(data,'trunk',parameters);
        QthighL= quaternion_line_v2(data,'thighL',parameters);
        QhipL = conj(Qtrunk) .* QthighL;
        QhipL=quat2eul(QhipL);
        hipL_flex= rad2deg(QhipL);
        
        
        data = addchannel_data(data,"hipL_flex",hipL_flex(:,2),'Video');
    end
    % right knee
    if ismember({'thighL', 'shankL'}, segment_pair)
        QthighL= quaternion_line_v2(data,'thighL',parameters);
        QshankL= quaternion_line_v2(data,'shankL',parameters);
        QkneeL =conj(QthighL) .*QshankL;
        QkneeL=quat2eul(QkneeL);
        kneeL_flex = rad2deg(QkneeL);
        data = addchannel_data(data,"kneeL_flex",kneeL_flex(:,1),'Video');
    end
end
