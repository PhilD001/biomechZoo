function loadbones

jnt = getjointcenters;
gns = cine_groot_suntay;

jtable = {'RightAnkle','RightFoot';...
    'RightKnee','RightTibia';...
    'RightHip','RightFemur';...
    'LeftAnkle','LeftFoot';...
    'LeftKnee','LeftTibia';...
    'LeftHip','LeftFemur';...
    'RightWrist','RightHand';...
    'RightElbow','RightRadius';...
    'RightShoulder','RightHumerus';...
    'LeftWrist','LeftHand';...
    'LeftElbow','LeftRadius';...
    'LeftShoulder','LeftHumerus';...
    'Trunk','Pelvis';...
    'Neck','Head'};


prp = finddobj('props');
for i = 1:length(jtable(:,1))
    phnd = findobj(prp,'tag',jtable{i,2});
    ud = get(phnd,'userdata');
    ud.JointCenter=jnt.(jtable{i,1});
    ud.GrootSuntay = gns.(jtable{i,1});
    set(phnd,'userdata',ud);
end
    
