function ob = plugingait(bones,c3d)

if nargin == 0
    [f,p] = uigetfile('*.obj');
    bones = readobj([p,f],'two');
    cd(p);
    [f,p] = uigetfile('*.c3d');
    c3d = readc3d([p,f]);
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
    

dim = {'O','A','L','P'};
ob = struct;
for i = 1:length(amat(:,1))
    d = [];
    for j = 1:4
       d{j} = getchannelc3d(c3d,[amat{i,1},dim{j}],'all');
    end
    bn = amat{i,2};
    [ob.(bn).vertices,ob.(bn).faces,ob.(bn).dis,ob.(bn).ort] = getdata(d,bones,bn);
    ob.(bn).color = [.8 .8 .8];    
end

pth = uigetfolder;

for i = 1:length(amat(:,1))
    bn = amat{i,2};
    object = ob.(bn);
    save(concatfile(pth,[bn,'.prop']),'object');
end




function [vr,fc,dis,ort] = getdata(data,allbones,bone);

vr = allbones.(bone).vertices/10;
fc = allbones.(bone).faces;

dis = data{1}/10;

a = (data{2}-data{1})/10;
l = (data{3}-data{1})/10;
p = (data{4}-data{1})/10;

[rw,cl] = size(a);
ort = [];
for i = 1:rw
       ort = [ort;{[a(i,:);l(i,:);p(i,:)]}];
end

