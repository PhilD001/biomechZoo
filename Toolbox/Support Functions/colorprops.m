function colorprops(nclr)
fld = uigetfolder;
cd(fld);
fl = engine('path',fld,'extension','prop');

for i = 1:length(fl)
    object = load(fl{i},'-mat');
    object = object.object;
    if isfield(object,'color');
        object.color = nclr;
    end
    if isfield(object,'cdata');
        object.cdata(:,:,1) = nclr(1);
        object.cdata(:,:,2) = nclr(2);
        object.cdata(:,:,3) = nclr(3);
    end
    save(fl{i},'object');
end