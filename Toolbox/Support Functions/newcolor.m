function r = newcolor(varargin)

if nargin == 0
    phnd = findobj(gcf,'tag','somarker');
    num = length(phnd)+1;
else
    num = varargin{1};
end

if num <=6
    str = dec2bin(num,3);
    r = [str2num(str(1)),str2num(str(2)),str2num(str(3))];
    return
elseif num<=12 & num>6
    num = num-6;
    str = dec2bin(num,3);
    r = [str2num(str(1)),str2num(str(2)),str2num(str(3))];
    r = r./2;
    return
end

num = num-12;

tri = [mod(floor(num/9),3),mod(floor(num/3),3),mod(num,3)];
r = max(min(tri/2,1),0);

if r == [1 1 1] | r == [0 0 0]
    r = newcolor(num+1);
end
if num >26
    r = newcolor(num-26);
end



