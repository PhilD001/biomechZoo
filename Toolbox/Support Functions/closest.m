function indx = closest(pt,mt);

%this function finds the closest in mt to pt
%mt is a n by 3 matrix and pt is a 1 by 3

mt(:,1) = mt(:,1)-pt(1);
mt(:,2) = mt(:,2)-pt(2);
mt(:,3) = mt(:,3)-pt(3);

mt = sqrt(diag(mt*mt'));
indx = find(mt ==min(mt));