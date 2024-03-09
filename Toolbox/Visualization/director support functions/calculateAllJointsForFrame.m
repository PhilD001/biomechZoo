


function jointPoints = calculateAllJointsForFrame(data, frame)
    % Initialize a structure to hold joint points for the specified frame
    jointPoints = struct();

    adjacentBones = {
    {'PEL'}, {'LFE'}, {'LFE'}, {'LTI'}, {'LTI'}, {'LFO'}, {'LFO'}, {'LTO'},
    {'PEL'}, {'RFE'}, {'RFE'}, {'RTI'}, {'RTI'}, {'RFO'}, {'RFO'}, {'RTO'},
    {'TRX'}, {'LCL'}, {'LCL'}, {'LHU'}, {'LHU'}, {'LRA'}, {'LRA'}, {'LHN'},
    {'TRX'}, {'RCL'}, {'RCL'}, {'RHU'}, {'RHU'}, {'RRA'}, {'RRA'}, {'RHN'}
};

% Concatenate the rows into a single row
adjacentBonesList = [adjacentBones{1,:}, adjacentBones{2,:}, adjacentBones{3,:}, adjacentBones{4,:}];

    % Loop through each pair of adjacent bones
    for i = 1:16
        bone1 = adjacentBonesList{2*i-1};
        bone2 = adjacentBonesList{2*i};

        % Construct marker names
        marker1 = [bone1, 'O']; % End of the first bone
        marker2 = [bone2, 'P']; % Start of the second bone

            % Extract marker data for the specified frame
            marker1Data = data.(marker1).line(frame, :);
            marker2Data = data.(marker2).line(frame, :);

            % Calculate the joint point
            jointPoints.(bone1 + "_" + bone2) = ...
                (marker1Data + marker2Data) / 2;
    
        
    end
end

