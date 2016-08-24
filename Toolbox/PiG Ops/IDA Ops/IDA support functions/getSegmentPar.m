function SegmentPar = getSegmentPar(file)

% SegmentPar = GETSEGMENTPAR(file) standalone function used primarily by kinetics_data 
%
% Made standalone for use with other functions on Nov 11th 2013
%
% See also kinetics_data


[~,txt] = xlsread(file);

segment = txt(3:end,1);
CoM = txt(3:end,2);
Mass = txt(3:end,3);
Rox = txt(3:end,4);
Roy = txt(3:end,5);
Roz = txt(3:end,6);

for i = 1:length(segment)
    SegmentPar.(segment{i}).com = str2double(CoM{i});
    SegmentPar.(segment{i}).mass = str2double(Mass{i});
    SegmentPar.(segment{i}).RadiusGyr_x = str2double(Rox{i});
    SegmentPar.(segment{i}).RadiusGyr_y = str2double(Roy{i});
    SegmentPar.(segment{i}).RadiusGyr_z = str2double(Roz{i});
end