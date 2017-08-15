function [indx1,indx2] = findclosevert(vr1,vr2,coeff);

%this function returns the indices in vr1 and vr2 that are close to each other within the
%coeffient coeff


d = [];
indx = [];
for i = 1:length(vr1(:,1));
    calcdis = [];
    %calculating the distance from all vertices in vr2 to a point in vr1
    calcdis(:,1) = vr2(:,1)-vr1(i,1);
    calcdis(:,2) = vr2(:,2)-vr1(i,2);
    calcdis(:,3) = vr2(:,3)-vr1(i,3);
    calcdis = sqrt(diag(calcdis*calcdis'));
    d = [d;min(calcdis)];
    plt = find(calcdis==min(calcdis));
    indx = [indx;plt(1)];
end
    

indx1 = find(d<=coeff);
indx2 = indx(indx1);
    