function r = cine_groot_suntay

arm = [-1 0 0;0 -1 0;0 0 1];
Rflip = [1 0 0;0 -1 0;0 0 1];
Lflip = [1 0 0;0 1 0;0 0 1];
Tflip = [1 0 0;0 -1 0;0 0 1];
Pflip = [1 0 0;0 -1 0;0 0 1];
THflip = [1 0 0;0 1 0;0 0 -1];
jnt = {'RightAnkle','RightTibia',Rflip,'RightFoot',Rflip;...
    'RightKnee','RightFemur',Rflip,'RightTibia',Rflip;...
    'RightHip','Pelvis',Pflip,'RightFemur',Rflip;...
    'LeftAnkle','LeftTibia',Lflip,'LeftFoot',Lflip;...
    'LeftKnee','LeftFemur',Lflip,'LeftTibia',Lflip;...
    'LeftHip','Pelvis',gunit,'LeftFemur',Lflip;...
    'Trunk','Thorax',Tflip*THflip,'Pelvis',gunit;...
    'RightWrist','RightRadius',arm*Rflip,'RightHand',arm*Rflip;...
    'RightElbow','RightHumerus',arm*Rflip,'RightRadius',arm*Rflip;...
    'RightShoulder','Thorax',gunit*THflip,'RightHumerus',arm*Rflip;...
    'LeftWrist','LeftRadius',arm*Lflip,'LeftHand',arm*Lflip;...
    'LeftElbow','LeftHumerus',arm*Lflip,'LeftRadius',arm*Lflip;...
    'LeftShoulder','Thorax',Tflip*THflip,'LeftHumerus',arm*Lflip;...
    'Neck','Head',gunit,'Thorax',Tflip*THflip};


delete(findobj('tag','tempobj'));

for i = 1:length(jnt(:,1))
    [r.(jnt{i,1}).flexion,r.(jnt{i,1}).abduction,r.(jnt{i,1}).twist,r.(jnt{i,1}).vectors] = grootsuntay(jnt(i,2:end));
end

function [flx,abd,tw,vec] = grootsuntay(m)
%the order of the vectors goes row:1 = anterior, 2 Lateral, 3 proximal

prp = finddobj('props');

pbone = m{1};
dbone = m{3};
phnd = findobj(prp,'tag',pbone);
dhnd = findobj(prp,'tag',dbone);

pflip = m{2};
dflip = m{4};

if isempty(phnd) || isempty(dhnd)
    flx = [];
    abd = [];
    tw = [];
    return
end

pud = get(phnd,'userdata');
pax = pud.ort;

dud = get(dhnd,'userdata');
dax = dud.ort;



e1 = [];
e1r = [];  
e2 = [];  %floating axes;
e3r = [];
e3 = [];
vec = [];
frm = finddobj('frame','number');
for i = 1:length(pax)
    p = pax{i};
    d = dax{i};
    
    if ~isempty(findstr(pbone,'Foot'))
        p = p([3,2,1],:);
        p(1,:) = -p(1,:);
    end

    if ~isempty(findstr(dbone,'Foot'))
        d = d([3,2,1],:);
        d(1,:) = -d(1,:);
    end
    p = pflip*p;
    d = dflip*d;
    e1 = [e1;p(2,:)];
    e1r = [e1r;p(3,:)];
    fax = cross(d(3,:),p(2,:));
    %making sure the cross product points anterior
    if dot(fax,p(1,:))<0
        fax = -fax;
    end
    e2 = [e2;fax];
    e3r = [e3r;d(2,:)];
    e3 = [e3;d(3,:)];
    vplate = makeunit([p(3,:);fax;p(2,:);d(3,:);fax;d(2,:)]);
    vec{i,1} = vplate;
end

alpha = angle(e1r,e2);
beta = angle(e1,e3);
gamma = angle(e2,e3r);
flx = alpha-90;
abd = beta-90;
tw = gamma-90;



function r = angle(m1,m2)

dotp = diag(m1*m2');

mag1 = sqrt(diag(m1*m1'));
mag2 = sqrt(diag(m2*m2'));

r = acos(dotp./(mag1.*mag2));

r = r*180;
r = r/pi;
