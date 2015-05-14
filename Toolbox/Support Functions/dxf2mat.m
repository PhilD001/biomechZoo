function m = dxf2mat(filename);

fid = fopen(filename,'r');
m = [];
while ~feof(fid)
    vl = [];
    ln = fgetl(fid);
    if strcmpi(ln(1),'V');
        nm = nextstring(fid);
        if ~isstruct(m) 
            m = setfield(m,nm,[]);
            vl.vertices = [];
            v1.vdata = [];
        elseif ~isfield(m,nm);
            m = setfield(m,nm,[]);
            vl.vertices = [];
            vl.vdata =[];
        else
            vl = getfield(m,nm);
            if ~isfield(vl,'vertices');
                vl.vertices = [];
                vl.vdata = [];
            end                
        end        
        fgetl(fid);
        xd = str2num(fgetl(fid));
        fgetl(fid);
        yd = str2num(fgetl(fid));
        fgetl(fid);
        zd = str2num(fgetl(fid));
        plt = [xd,yd,zd];
        vl.vertices = [vl.vertices;plt];
        vl.vdata = [vl.vdata;{polylineread(fid)}];
        m = setfield(m,nm,vl);
    elseif strcmp(ln,'POLYLINE');
        fgetl(fid);
        nm = fgetl(fid);
        pln = polylineread(fid);
        if ~isstruct(m)            
            vl.polyline = pln;
            m = setfield(m,nm,vl);
        elseif ~isfield(m,nm);
            vl.polyline = pln;
            m = setfield(m,nm,vl);
        else
            vl = getfield(m,nm);
            vl.polyline = pln;
            m = setfield(m,'nm',vl);
        end
    end        
end
fclose(fid);

fld = fieldnames(m);
newm = [];
for i = 1:length(fld)
    newm = calcvert(newm,fld{i},getfield(m,fld{i}));
end
m = newm;


function num = polylineread(fid);
num = [];
while 1
    ln = fgetl(fid);
    plt = str2num(ln);
    if isempty(plt);
        break
    elseif plt == 0
        break
    else
        num = [num;plt];
    end
end


function newm = calcvert(oldm,fld,val);

vr = val.vertices;
vdata = val.vdata;
fc = [];
for i = 1:length(vdata)
    vec = vdata{i};
    indx = 0;
    mxindx = length(vec);
    plt = [];
    while 1
        indx = indx+1;
        if indx>mxindx
            break
        end
        fxn = vec(indx);
        indx = indx+1;
        switch fxn;
        case 71
        case 72
        case 73
        otherwise            
            continue
        end
        plt = [plt,vec(indx)];
    end
    if isempty(fc)
        fc = plt;
    else
        if length(fc(1,:)) == length(plt)
            fc = [fc;plt];
        end
    end
end

mnfc = min(min(fc));
mxfc = max(max(fc));

br.faces = fc-mnfc+1;
br.vertices = vr(mnfc:mxfc,:);

newm = oldm;
newm = setfield(newm,fld,br);

function nm = nextstring(fid)
while 1
    nm = fgetl(fid);
    if isempty(str2num(nm))
        break
    end
end
        


   