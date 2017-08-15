function data = c3d2com(c3d)

%data = c3d2com(c3d_data)
%This function will output segment information from a c3d file created by
%vicon (using the plugin gait model).
%
%Units are in CENTIMETERS
%
%Caution.  all segments above and including the pelvis do not have the
%proper center of mass
%
%Created by JJ Loh  2007/06/21
%Departement of Kinesiology
%McGill University, Montreal, Quebec Canada
%

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
    
dim = {'O','A','L','P'};
data = struct;
for i = 1:length(amat(:,1))
    d = [];
    for j = 1:4
       d{j} = getchannelc3d(c3d,[amat{i,1},dim{j}],'all');
    end
    bn = amat{i,2};
    switch bn
        case 'Pelvis'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftFemur'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .567];
        case 'LeftTibia'
            pjoint = data.LeftFemur.dist_end;
            djoint = [0 0 0];
            com = [0 0 .567];
        case 'LeftFoot'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightFemur'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .567];
        case 'RightTibia'
            pjoint = data.RightFemur.dist_end;
            djoint = [0 0 0];
            com = [0 0 .567];
        case 'RightFoot'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'Thorax'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'Head'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftHumerus'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftRadius'
            pjoint = data.LeftHumerus.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'LeftHand'
            pjoint = data.LeftRadius.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightHumerus'
            pjoint = [0 0 1];
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightRadius'
            pjoint = data.RightHumerus.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        case 'RightHand'
            pjoint = data.RightRadius.dist_end;
            djoint = [0 0 0];
            com = [0 0 .5];
        otherwise
            continue
    end
            
            
    [dis,ort,pjoint,djoint,com] = getdata(d,pjoint,djoint,com);    
    data.(bn).dis =dis;
    data.(bn).ort =ort;
    data.(bn).prox_end = pjoint;
    data.(bn).dist_end = djoint;
    data.(bn).com = com;
end

function [dis,ort,pjnt,djnt,cm] = getdata(data,pjoint,djoint,com)

dis = data{1}/10;

a = (data{2}-data{1})/10;
l = (data{3}-data{1})/10;
p = (data{4}-data{1})/10;

[rw,cl] = size(a);
ort = [];

pjnt = [];
djnt = [];
cm = [];

for i = 1:rw
    unt = [a(i,:);l(i,:);p(i,:)];
    [r,c] = size(pjoint);
    if r==1        
        pjplate = ctransform(unt,gunit,pjoint)+dis(i,:);
        pjnt = [pjnt;pjplate];
    end
    [r,c] = size(djoint);
    if r==1        
        djplate = ctransform(unt,gunit,djoint)+dis(i,:);
        djnt = [djnt;djplate];
    end
    cplate = ctransform(unt,gunit,com)+dis(i,:);
    cm = [cm;cplate];
    ort = [ort;{unt}];
end

if isempty(pjnt)  %if the joints are empty just return the incomeing joint
    pjnt = pjoint;
end
if isempty(djnt)
    djnt = djoint;
end
