function pos = nextposition(varargin)

if (nargin/2)~= round(nargin/2);
    pos = [];
    return
end

dx = .1;
dy = .1;
h = .5;
w = 1.5;
num = 0;
mxcl = 5;
offx = 0;
offy = 0;
for i = 1:2:nargin
    switch varargin{i}
        case 'number'
            num = varargin{i+1};
        case 'dx'
            dx = varargin{i+1};
        case 'dy'
            dy = varargin{i+1};
        case 'height'
            h = varargin{i+1};
        case 'width'
            w = varargin{i+1};
        case 'max column'
            mxcl = varargin{i+1};
        case 'xoffset'
            offx = varargin{i+1};
        case 'yoffset'
            offy = varargin{i+1};
    end
end
if num == 0
    pos = [];
    return
end
num = num-1;
xpos = (mod(num,mxcl)+1)*dx+mod(num,mxcl)*w;
ypos = (floor(num/mxcl)+1)*dy+floor(num/mxcl)*h;

pos = [xpos+offx,ypos+offy,w,h];