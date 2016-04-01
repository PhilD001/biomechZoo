function [flx,abd,tw] = groodsuntay(r,jnt,data)



% Axis set-up follows Vicon

%---SET UP VARIABLES ---

pbone = jnt{2};
dbone = jnt{3};

pax = r.(pbone).ort;  % contains xyz local axes for each frame
dax = r.(dbone).ort;






if ~isempty(strfind(pbone,'Right'))
    bone = pbone(6:end);
elseif ~isempty(strfind(pbone,'Left'))
    bone = pbone(5:end);
else
    bone = pbone;
end

%---CREATE AXES FOR GROOD AND SUNTAY CALCULATIONS----


switch bone

    
    %-----OFM cases-------
     
    case {'TibiaOFM'}   % hindfoot tibia angle
        
        [floatax,i1,i2,j1,j2,k1,k2] = makeaxox(pax,dax,bone); 
        
         flx = -angle(floatax,i1)+180;        % plantar/ dorsi
         abd = -angle(j1,i2)+90;         % int / ext
         tw = angle(floatax,j2)-90;     % pro / suppination

    case 'HindFoot'  % forefoot hindfoot angle

        [floatax,i1,i2,j1,j2,k1,k2] = makeaxox(pax,dax,bone);
        flx = -angle(floatax,i1)+90;        % plantar/ dorsi
        abd = -angle(j1,i2)+90;         % int / ext
        tw = -angle(floatax,j2)+90;     % pro / suppination

    case 'ForeFoot'   % hallux angle
        
        [floatax,i1,i2,j1,j2,k1,k2] = makeaxox(pax,dax,bone);
        flx = angle(floatax,i1);        % plantar/ dorsi
        abd = zeros(size(flx));         % crap data
        tw = zeros(size(flx));      % crap data

%---Plugingait cases----------
        
    case 'Pelvis'   % Hip angles

       [floatax,i1,i2,j1,j2,k1,k2] = makeax(pax,dax); 
       
        flx = angle(floatax,k1);
        abd = angle(j1,k2);
        tw = -angle(floatax,j2);

    case 'Femur'      % Knee  Angles

        [floatax,i1,i2,j1,j2,k1,k2] = makeax(pax,dax); 

        flx = -angle(floatax,k1);
        abd = -angle(j1,k2);
        tw = angle(floatax,j2);

    case 'TibiaPG'    % Ankle PG angles

        [floatax,i1,i2,j1,j2,k1,k2] = makeax(pax,dax); 

        flx = -angle(floatax,i1);
        abd = -angle(j1,k2);
        tw = angle(floatax,j2);

end



% 
%      case {'RightTibiaOFM','LeftTibiaOFM'}
% 
%         flx = angle(floatax,i1)-90;        % plantar/ dorsi
% 
%         if ~isempty(strfind(pbone,'Right'))    % Hindfoot / Tibia Angle
%             abd = -angle(j1,i2)+90;         % int / ext
%             tw = -angle(floatax,j2)+90;     % pro / suppination
%         end
% 
%         if ~isempty(strfind(pbone,'Left'))  % Hindfoot / Tibia Angle
%             abd = angle(j1,i2)-90;         % int / ext
%             tw = angle(floatax,j2)-90;     % pro / suppination
%         end



%     case 'Hindfoot' 
%     
%         flx = angle(floatax,i1)-90;        % plantar/ dorsi
% 
%         if ~isempty(strfind(pbone,'Right'))    % Hindfoot / Tibia Angle
%             abd = -angle(j1,i2)+90;         % int / ext
%             tw = -angle(floatax,j2)+90;     % pro / suppination
%         end
% 
%         if ~isempty(strfind(pbone,'Left'))  % Hindfoot / Tibia Angle
%             abd = angle(j1,i2)-90;         % int / ext
%             tw = angle(floatax,j2)-90;     % pro / suppination
%         end
%         
% 
% 
%     case 'Forefoot'
%         flx = angle(floatax,i1)-90;        % plantar/ dorsi
%         abd = zeros(size(flx));         % crap data
%         tw = zeros(size(flx));      % crap data


%---Change for left side abd and tw -------------

if ~isempty(strfind(pbone,'Left'))
    abd = -abd;         
    tw = -tw;    
end
     
     
    
 
   
% Grood and Suntay angle calculations based on adaptation by Vaughan 'The
% Gait Book' Appendix B, p95. Offsets made to match oxford foot model
% outputs



%checkflip(flx,i1,floatax,pbone);


function [floatax,i1,i2,j1,j2,k1,k2] = makeax(pax,dax)

i1 = [];
j1 = [];
k1 = [];
floatax = [];  

i2 = [];
j2 = [];
k2 = [];

for i = 1:length(pax)

    ip = pax{i}(1,:);   
    jp = pax{i}(2,:);
    kp = pax{i}(3,:);   

    id = dax{i}(1,:);
    jd = dax{i}(2,:);
    kd = dax{i}(3,:);

    i1 = [i1;ip];
    j1 = [j1;jp];
    k1 = [k1;kp];

    fax = cross(jp,kd);
    floatax = [floatax;fax];

    i2 = [i2;id];
    j2 = [j2;jd];
    k2 = [k2;kd];
    
end


function [floatax,i1,i2,j1,j2,k1,k2] = makeaxox(pax,dax,bone)

i1 = [];
j1 = [];
k1 = [];
floatax = [];  

i2 = [];
j2 = [];
k2 = [];

if ~isempty(strfind(bone,'Tibia'))

for i = 1:length(pax)

    ip = pax{i}(1,:);   
    jp = pax{i}(2,:);
    kp = pax{i}(3,:);   

    id = dax{i}(1,:);
    jd = dax{i}(2,:);
    kd = dax{i}(3,:);

    i1 = [i1;ip];
    j1 = [j1;jp];
    k1 = [k1;kp];
    
    i2 = [i2;id];
    j2 = [j2;jd];
    k2 = [k2;kd];
    
    %fax = cross(jp,id); % good but far away
    fax = cross(jp,id);
    floatax = [floatax;fax];
    
end


else
    
    for i = 1:length(pax)

    ip = pax{i}(1,:);   
    jp = pax{i}(2,:);
    kp = pax{i}(3,:);   

    id = dax{i}(1,:);
    jd = dax{i}(2,:);
    kd = dax{i}(3,:);

    i1 = [i1;ip];
    j1 = [j1;jp];
    k1 = [k1;kp];

    fax = cross(kp,jd);
%         fax = cross(jp,kd);  close but no
    floatax = [floatax;fax];

    i2 = [i2;id];
    j2 = [j2;jd];
    k2 = [k2;kd];
    
    end

end



function checkflip(flx,i1,floatax,pbone)

%---fix flipping problem-----
% Algorithm has been updated. Correct channel is chosen based on most
% common vector direction. Warning, if you are mostly wrong, then
% calculations will be wrong!

flxtag = [];

for i = 1:length(flx)
    vec_cross = cross(i1(i,:),floatax(i,:));
    flxtag = [flxtag;vec_cross(1)];  
end
       
flxplus = find(flxtag>=0);
flxminus = find(flxtag<=0);

if isempty(flxplus) || isempty(flxminus)  % no flipping occured, angle must be correct
    return
else
    disp(['vector flip detected for angle with proximal bone: ',pbone,' please check data for labeling consistency'])
    disp(' ')
    
end
