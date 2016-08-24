function [vr,fc,cdata] = mergepatch(vr1,fc1,cdata1,vr2,fc2,cdata2)
if isempty(vr1)
    vr = vr2;
    fc = fc2;
    cdata = cdata2;
    return
elseif isempty(vr2)
    vr = vr1;
    fc = fc1;
    cdata = cdata1;
    return
end

lvr = length(vr1(:,1));
lfc1 = length(fc1(:,1));
lfc2 = length(fc2(:,1));

s1 = size(cdata1);
s2 = size(cdata2);

if length(s1) == 2
    clr = cdata1;
    cdata1 = [];
    cdata1(1:lfc1,1,1) = clr(1);
    cdata1(1:lfc1,1,2) = clr(2);
    cdata1(1:lfc1,1,3) = clr(3);
end
    
if length(s2) ==2
    clr = cdata2;
    cdata2 = [];
    cdata2(1:lfc2,1,1) = clr(1);
    cdata2(1:lfc2,1,2) = clr(2);
    cdata2(1:lfc2,1,3) = clr(3);
end

s1 = size(cdata1);
s2 = size(cdata2);

if s1(2)>s1(1)
    cdata1 = permute(cdata1,[2 1 3]);
end

if s2(2)>s2(1)
    cdata2 = permute(cdata2,[2 1 3]);
end

vr = [vr1;vr2];
fc = [fc1;fc2+lvr];
cdata = [cdata1;cdata2];