function r = getjointcenters

% Lhipvec = [0.001047173543632   0.008637260481034   0.987698733491366];
% Rhipvec = [0.001186173781980  -0.003963635061499   0.986562214450295];
%after some investigation Phil and JJ found [0 0 1] to be good

Lhipvec = [0 0 1];
Rhipvec = [0 0 1];


prp = finddobj('props');
%Right Ankle
hnd = findobj(prp,'tag','RightTibia');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.RightAnkle = hud.dis;
end

%Right knee & hip
hnd = findobj(prp,'tag','RightFemur');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.RightKnee = hud.dis;
    r.RightHip = transform(hud.ort,Rhipvec)+hud.dis;
end

%Right Shoulder
hnd = findobj(prp,'tag','RightClavicle');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.RightShoulder = hud.dis;
end

%Right Elbow
hnd = findobj(prp,'tag','RightHumerus');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.RightElbow = hud.dis;
end

%Right Wrist
hnd = findobj(prp,'tag','RightRadius');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.RightWrist = hud.dis;
end



%Left Ankle
hnd = findobj(prp,'tag','LeftTibia');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.LeftAnkle = hud.dis;
end

%Left knee & hip
hnd = findobj(prp,'tag','LeftFemur');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.LeftKnee = hud.dis;
    r.LeftHip = transform(hud.ort,Lhipvec)+hud.dis;
end

%Left Shoulder
hnd = findobj(prp,'tag','LeftClavicle');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.LeftShoulder = hud.dis;
end

%Left Elbow
hnd = findobj(prp,'tag','LeftHumerus');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.LeftElbow = hud.dis;
end

%Left Wrist
hnd = findobj(prp,'tag','LeftRadius');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.LeftWrist = hud.dis;
end

hnd = findobj(prp,'tag','Pelvis');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.Pelvis = hud.dis;    
end
    
hnd = findobj(prp,'tag','Thorax');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.Thorax = hud.dis;
end

hnd = findobj(prp,'tag','Head');
if ~isempty(hnd)
    hud = get(hnd,'userdata');
    r.Head = hud.dis;
end

r.Trunk = (r.Pelvis+r.Thorax)/2;
r.Neck = (r.Head+r.Thorax)/2;
    

function r = transform(ort,vec)

r = [];
for i = 1:length(ort)
    r = [r;ctransform(ort{i},gunit,vec)];
end
