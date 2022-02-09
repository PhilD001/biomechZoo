function openall(pth)


% standalone function used by director
s = filesep;    % determine slash direction based on computer type

if ~strcmp(pth(end),s)
    pth = [pth,s];
end

fl = engine('path',pth);

[bodyf,dataf,fl] = separatefiles(fl);
for i = 1:length(bodyf)
    [f,p] = partitionfile(bodyf{i});
    actor('create',bodyf{i},extension(f,''));
end

fl = [fl;dataf];
for i = 1:length(fl)
    filename = fl{i};
    [f,p] = partitionfile(fl{i});
    switch lower(extension(filename))
        case '.ort'
            actor('load orientation',filename);
        case '.dis'
            actor('load displacement',filename);
        case '.cdata'
            actor('load cdata',filename);
        case '.cam'
            cameraman('load',filename);
        case '.spo'
            costume('load special',[p,f]);
        case '.cos'
            costume('load',filename,extension(f,''));
        case '.grip'
            grips('load',filename);
        case '.light'
            lightman('load',filename);
        case '.prop'
            props('load',filename);
            % disp(['Loading prop - ',filename])
        case '.c3d'
            marker('load c3d',filename);
        case '.z3d'
            marker('load z3d',filename);
            
    end
end


function [ac,d,o] = separatefiles(f)
ac = [];
o = [];
d = [];
for i = 1:length(f)
    switch extension(f{i})
        case '.body'
            ac = [ac;f(i)];
        case '.c3d'
            d = [d;f(i)];
        otherwise
            o = [o;f(i)];
    end
end