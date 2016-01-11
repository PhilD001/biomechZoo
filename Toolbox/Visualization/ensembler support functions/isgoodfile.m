function r = isgoodfile(fl,nm)

%indx = strfind(nm,'/');
indx = strfind(nm,'+');    %join search strings

if isempty(indx)
    str = nm;
    if isempty(strfind(fl,str))
        r = 0;
    else
        r = 1;
    end
else
    indx = [0,indx,length(nm)+1];
    r = 1;
    for i = 2:length(indx)
        str = nm(indx(i-1)+1:indx(i)-1);
        if isempty(strfind(fl,str))
            r = 0;
            return
        end
    end
end