function [nvr,nfc] = cleanpatch(vr,fc,cuttoff);

if nargin ==2
    cuttoff = .1;
end

index = 1;
while 1
    if index > length(vr(:,1))
        break
    end
    pt = vr(index,:);
    mg = [];
    mg(:,1) = vr(:,1)-pt(1);
    mg(:,2) = vr(:,2)-pt(2);
    mg(:,3) = vr(:,3)-pt(3);
    mg = sqrt(diag(mg*mg'));
    ind = find(mg<cuttoff);
    ind = setdiff(ind,index);
    fc = findreplace(fc,ind,index);
    [vr,fc] = deletevert(vr,fc,ind);
    index = index+1;
end

lindx = findlonelyvert(vr,fc);
[vr,fc] = deletevert(vr,fc,lindx);

nvr = vr;
nfc = fc;


function nfc = findreplace(fc,ind,index);

for i = 1:length(ind)
    for j = 1:length(fc(1,:))
        indx = find(fc(:,j)==ind(i));
        fc(indx,j) = index;
    end
end
nfc = fc;
    

function [nvr,nfc] = deletevert(vr,fc,index)

if isempty(index)
    nvr = vr;
    nfc = fc;
    return
end
vr(index,:) = [];
for i = 1:length(index)
    vindx = index(i);
    xindx = find(fc(:,1)>vindx);
    yindx = find(fc(:,2)>vindx);
    zindx = find(fc(:,3)>vindx);
    fc(xindx,1) = fc(xindx,1)-1;
    fc(yindx,2) = fc(yindx,2)-1;
    fc(zindx,3) = fc(zindx,3)-1;
    
    iindex = find(index>index(i));
    index(iindex) = index(iindex)-1;
end

nvr = vr;
nfc = fc;


function indx = findlonelyvert(vr,fc);

allindx = (1:length(vr(:,1)));
for i = 1:length(fc(1,:));
    allindx = setdiff(allindx,fc(:,i));
end

indx = allindx;