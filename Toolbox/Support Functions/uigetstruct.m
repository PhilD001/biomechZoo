function varargout = uigetstruct(varargin);

fl = '*.*';
nm = 'open your file';
kwnm = 'enter your keywords';
for i = 1:2:nargin
    switch varargin{i}
        case 'name'
            nm = varargin{i+1};
        case 'extension'
            kw = varargin{i+1};
        case 'name2'
            kwnm = varargin{i+1};
    end
end


[f,p] = uigetfile(fl,nm);

if f == 0;
    varargout{1} = [];
    return
end
cd(p);

switch extension(f);
    case {'.zoo','.soo','.zens'}
        t = load([p,f],'-mat');
        fld = allfieldnames(t);
        kw = mylistdlg('name',kwnm,'list',{},'source list',fld);
        if isempty(kw);
            varargout{1} = [];
            return
        end
        varargout{1} = searchstruct(t,kw);
        varargout{2} = kw;    
    otherwise
        varargout{1} = file2mat([p,f]);
        varargout{2} = [];
end