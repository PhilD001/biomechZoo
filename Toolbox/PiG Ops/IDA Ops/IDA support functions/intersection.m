function p = intersection(a,b,u,v)
%computes the intersetion of a_b and u_v
% a b u and v have to be 2d point vectors eg. a = [3 4];

% updated August 15th 2013 by Philippe C. Dixon
% - missing * at line 19 prevented function from working

x1=a(1);
x2=b(1);
x3=u(1);
x4=v(1);
y1=a(2);
y2=b(2);
y3=u(2);
y4=v(2);

ua = ((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3))/((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1));
x = x1 + ua*(x2 - x1);
y = y1 + ua*(y2 - y1);
p = [x,y];