function manipulateBoneByName(ax, boneName,filepath,frame)
    % boneName: The tag/name of the bone Patch object
    % scale: A 1x3 vector to scale the object along x, y, and z ([sx, sy, sz])
    % rotation: A 1x3 vector of Euler angles ([rx, ry, rz]) in degrees
    % translation: A 1x3 vector to translate the object along x, y, and z ([tx, ty, tz])
persistent OriginVertices X HeadPatches bonePatchBis data marker3 marker4 marker1 marker2
   
if  isempty(X)
   
   [~,~,ext] = fileparts(filepath);
    if strcmp(ext,'.c3d')
       data = c3d2zoo(filepath); 
    else
        data = zload(filepath); 
    end
end


amat = {'PEL','Pelvis';...
    'LFE','LeftFemur';...
    'LTI','LeftTibia';...
    'LFO','LeftFoot';...
    'LTO','LeftToe';...
    'RFE','RightFemur';...
    'RTI','RightTibia';...
    'RFO','RightFoot';...
    'RTO','RightToe';...
    'TRX','Thorax';...
    'HED','Head';...
    'LCL','LeftClavicle';...
    'LHU','LeftHumerus';...
    'LRA','LeftRadius';...
    'LHN','LeftHand';...
    'RCL','RightClavicle';...
    'RHU','RightHumerus';...
    'RRA','RightRadius';...
    'RHN','RightHand'};


    abbreviation = ''; 
    for i = 1:size(amat, 1)
        if strcmp(amat{i, 2}, boneName)
            abbreviation = amat{i, 1};
            break; 
        end
    end

    if isempty(abbreviation)
        disp(['Aucune abréviation trouvée pour ', boneName]);
    end


    marker1 = [abbreviation, 'O'];
    marker2 = [abbreviation, 'P'];
    marker3 = [abbreviation, 'A'];
     marker4 = [abbreviation, 'L'];
     

Vect2 = data.(marker3).line(frame,:) - data.(marker1).line(frame,:);
Vect3 = data.(marker4).line(frame,:) - data.(marker1).line(frame,:);

high = sqrt(sum((data.(marker1).line(frame,:) - data.(marker2).line(frame,:)).^2));

vector = data.(marker2).line(frame,:) - data.(marker1).line(frame,:);
VectX = [1, 0, 0];
Vecty = [0,1,0];
VectZ = [0,0,1];

dot_product = dot(Vect2, VectX); 
norm_vector = norm(vector);
norm_VectX = norm(VectX); 
cos_theta = dot_product / (norm_vector * norm_VectX);
angle_degreesZ = acosd(cos_theta);

dot_product = dot(vector, VectX); 
norm_vector = norm(vector);
norm_VectX = norm(VectX); 
cos_theta = dot_product / (norm_vector * norm_VectX);
angle_degreesY = acosd(cos_theta); 

dot_product = dot(vector, Vecty); 
norm_vector = norm(vector); 
norm_Vecty = norm(Vecty); 
cos_theta = dot_product / (norm_vector * norm_Vecty); 
angle_degreesX = acosd(cos_theta);

if checkIfThorax(boneName)

% Define the transformation parameters
scale = [high, high, high]; % Scale factors for x, y, and z
rotation = [-angle_degreesZ, angle_degreesX+90, 90-angle_degreesY]; % Rotation around x, y, and z axis in degrees
translation = data.(marker1).line(frame,:); % Translation along x, y, and z axis

else
    % Define the transformation parameters
scale = [high, high, high]; % Scale factors for x, y, and z
rotation = [angle_degreesZ, 90-angle_degreesX, 90-angle_degreesY]; % Rotation around x, y, and z axis in degrees
translation = data.(marker1).line(frame,:); % Translation along x, y, and z axis
end



if ~exist('OriginVertices', 'var')
    OriginVertices = struct();
    disp('remise a zero')
end


if ~isempty(X)
   
else
X = 1;
bonesToManipulate = {'LeftClavicle','LeftHumerus', 'LeftRadius','LeftHand','LeftFemur', 'LeftTibia','LeftFoot','LeftToe', 'Pelvis','RightClavicle','RightHumerus', 'RightRadius','RightHand', 'RightFemur', 'RightTibia','RightFoot','RightToe', 'Thorax', 'Head'};

% Parcourir la liste des os et stocker leurs vertices
for i = 1:length(bonesToManipulate)
    boneNameOrigin = bonesToManipulate{i};
    bonePatchOrigin = findobj('Tag', boneNameOrigin);

    if ~isempty(bonePatchOrigin)
        % Stocker les vertices seulement si elles ne sont pas déjà stockées
        if ~isfield(OriginVertices, boneNameOrigin)
            OriginVertices.(boneNameOrigin) = get(bonePatchOrigin, 'Vertices');
        end
    else
        disp(['Aucun patch trouvé pour : ' boneNameOrigin]);
    end
end

end
    
    % Apply rotation
    % Convert Euler angles to rotation matrix (assuming ZYX order)
    rotMat = eul2rotm(deg2rad(rotation), 'ZYX');

    
    rotatedVertices = (rotMat * OriginVertices.(boneName)')';

    scaledVertices = bsxfun(@times, rotatedVertices, scale);

    % Apply translation
    translatedVertices = bsxfun(@plus, scaledVertices, translation);
    

if  ~isempty(HeadPatches) 
    boneTag = [boneName, 'Bis'];
    bonePatchBis = findobj(ax,'type','patch','Tag', boneTag);

 set(bonePatchBis,'Vertices', translatedVertices);

else

% Find the patch object by its name (tag)
    bonePatch = findobj('Tag', boneName);
    
    if isempty(bonePatch)
        disp(['No bone found with the name: ' boneName]);
        return;
    end

boneTag = [boneName, 'Bis'];

      patch('Parent', ax, ...
              'Faces', get(bonePatch, 'Faces'), ...
              'Vertices', translatedVertices, ...
              'FaceColor', 'flat', ...
              'FaceVertexCData', bonePatch.FaceVertexCData, ...
              'EdgeColor', 'none', ...
              'Tag', boneTag);

     HeadPatches = findobj(ax,'Type', 'patch', 'Tag', 'HeadBis');
     
end

end

function R = eul2rotm(eul, ~)
    % eul2rotm Convert Euler angles to rotation matrix
    % eul: A 1x3 vector of Euler angles in radians
    % order: A string for the order of rotations, e.g., 'ZYX'
    % This is a simplified implementation, assuming 'ZYX' order for rotation

    Rz = [cos(eul(1)) -sin(eul(1)) 0; sin(eul(1)) cos(eul(1)) 0; 0 0 1];
    Ry = [cos(eul(2)) 0 sin(eul(2)); 0 1 0; -sin(eul(2)) 0 cos(eul(2))];
    Rx = [1 0 0; 0 cos(eul(3)) -sin(eul(3)); 0 sin(eul(3)) cos(eul(3))];
    
    R = Rz * Ry * Rx;
end

function isThorax = checkIfThorax(boneName)
    % Check if the input is a string
    if ~ischar(boneName) && ~isstring(boneName)
        error('Input must be a string');
    end
    
    % Normalize the input (e.g., convert to lowercase) for consistency
    normalizedBoneName = lower(boneName);

    % Use strcmpi for case-insensitive comparison
    isThorax = strcmpi(normalizedBoneName, 'thorax');
end