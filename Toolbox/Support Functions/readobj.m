function r = readobj(filename,mode);

if nargin == 1
    mode = filename;
    [f,p] = uigetfile('*.obj');
    if f == 0
        return
    end
    filename = [p,f];
    cd(p)    
end

fid = fopen(filename,'r');
switch mode
    case 'one'
        vr = [];
        fc = [];
        nm = '';
        fld = '';
        r = [];
        while ~feof(fid)
            ln = fgetl(fid);
            if isempty(ln)
                continue
            end
            switch ln(1)
                case 'g'
                    nm = ln(2:end);
                    if ~isempty(nm);
                        fld = nm;
                    else
                        if ~isempty(vr) & ~isempty(fc) & ~isempty(fld)
                            tmp.vertices = vr*10;
                            tmp.faces = fc;
                            r = setfield(r,validfield(fld),tmp);
                            vr = [];
                            fc = [];
                            fld = '';
                        end
                    end
                case 'v'
                    vr = [vr;str2num(ln(2:end))];
                case 'f'
                    fc = [fc;str2num(ln(2:end))];
            end

        end

        if ~isfield(r,fld)
            tmp.vertices = vr;
            tmp.faces = fc;
            r = setfield(r,validfield(fld),tmp);
        end

        fld = fieldnames(r);
        plvr = 0;
        for i = 2:length(fld)
            pvl = getfield(r,fld{i-1});
            vl = getfield(r,fld{i});
            plvr = plvr+length(pvl.vertices(:,1));
            vl.faces = vl.faces-plvr;
            r = setfield(r,fld{i},vl);
        end
    case 'two'
        vr = [];
        fc = [];
        nm = '';
        fld = '';
        r = [];
        vn = [];
        fn = [];
        eoseg = 0;
        pln = 'a';
        while ~feof(fid)            
            ln = fgetl(fid);
            if ~isempty(pln) & ~isempty(ln)
                if strcmp([pln(1),ln(1)],'fv');
                    eoseg = 1;
                else
                    eoseg = 0;
                end
            end
            pln = ln;
            if isempty(ln)
                continue
            end
            switch ln(1)
                case 'g'
                    nm = ln(2:end);
                    if ~isempty(nm);
                        fld = nm;                                           
                    end
                case 'v'
                    if strcmp(ln(2),'n')
                        vn = [vn;str2num(ln(3:end))];
                    else
                        vr = [vr;str2num(ln(2:end))];
                    end
                case 'f'
                    ln = strrep(ln(2:end),'//',' ');
                    ln = str2num(ln);
                    fcplate = ln(1:2:end);
                    fnplate = ln(2:2:end);
                    fcplate = fcplate(1:3);
                    fnplate = fnplate(1:3);
                    fc = [fc;fcplate];
                    fn = [fn;fnplate];
            end
            if ~isempty(vr) & ~isempty(fc) & ~isempty(fld) & eoseg
                tmp.vertices = vr;
                tmp.faces = fc;
                tmp.nvertices = vn;
                tmp.nfaces = fn;
                r = setfield(r,validfield(fld),tmp);
                vr = [];
                fc = [];
                fn = [];
                vn = [];
                fld = '';
            end

        end

end
    
    