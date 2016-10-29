function SegmentPar = getSegmentPar(file)

% SegmentPar = GETSEGMENTPAR(file) standalone function used primarily by kinetics_data 
%
% Made standalone for use with other functions on Nov 11th 2013
%
% See also kinetics_data

% Updated by Philippe C. Dixon Sept 2016
% - read numeric data instead of text (excel sheet also updated)

[num,txt] = xlsread(file);

segment = txt(3:end,1);
CoM = num(:,1);
Mass = num(:,2);
Rox = num(:,3);
Roy = num(:,4);
Roz = num(:,5);

for i = 1:length(segment)
    SegmentPar.(segment{i}).com = CoM(i);
    SegmentPar.(segment{i}).mass = Mass(i);
    SegmentPar.(segment{i}).RadiusGyr_x = Rox(i);
    SegmentPar.(segment{i}).RadiusGyr_y = Roy(i);
    SegmentPar.(segment{i}).RadiusGyr_z = Roz(i);
end