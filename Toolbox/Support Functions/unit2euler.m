function e = unit2euler(unt)
c1 = [1 0 0;0 1 0;0 0 1];
c2 = unt;

ic1 = c1(1,:);
jc1 = c1(2,:);
kc1 = c1(3,:);

ic2 = c2(1,:);
jc2 = c2(2,:);
kc2 = c2(3,:);

t = [dot(ic1,ic2),dot(ic1,jc2),dot(ic1,kc2);...
        dot(jc1,ic2),dot(jc1,jc2),dot(jc1,kc2);...
        dot(kc1,ic2),dot(kc1,jc2),dot(kc1,kc2)]';

e(2) = asin(t(3,1));
if e == pi/2 | e==-pi/2
    %gimbal lock
    e = [NaN,NaN,NaN];
    return
end

if t(3,3)*cos(e(2)) > 0
    e(1) = atan(-t(3,2)/t(3,3));
elseif t(3,3)*cos(e(2)) < 0
    e(1) = atan(-t(3,2)/t(3,3))+pi;
end
if t(1,1)*cos(e(2)) > 0
    e(3) = atan(-t(2,1)/t(1,1));
elseif t(1,1)*cos(e(2)) < 0
    e(3) = atan(-t(2,1)/t(1,1))+pi;
end

if length(e)~=3
    e = [NaN,NaN,NaN];
end
e = e*180/pi;