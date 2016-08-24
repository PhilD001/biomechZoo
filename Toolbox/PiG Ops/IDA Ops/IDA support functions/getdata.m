function [ort,cm,pjnt,djnt] = getdata(d,pjnt,djnt,com)

% NOTES
%
% Vicon zdata is in mm. Keep in mm for viewing of COM in director!
%
% Made standalone for use with other functions on Nov 11th 2013



a = (d{2}-d{1});         %a: distal joint - origin (new vector starting at O)
l = (d{3}-d{1});         %l: lateral - origin
p = (d{4}-d{1});         %p: proximal joint - origin

rw = size(a);

ort = [];
cm = [];

for i = 1:rw
    unt = [a(i,:);l(i,:);p(i,:)];  % LCS
    cplate = pointonline(djnt(i,:),pjnt(i,:),com);
    cm = [cm;cplate];
    
    oplate(1,1:3,1) = unt(1,1:3);          %segment embedded axes i
    oplate(1,1:3,2) = unt(2,1:3);           %segment embedded axes j
    oplate(1,1:3,3) = unt(3,1:3);           %segment embedded axes k
    ort = [ort;oplate];
end