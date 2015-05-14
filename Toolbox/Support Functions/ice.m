function [ic,brd] = ice;

ax = gca;
vr = [];
fc = [1 2 3 4];
vr = [0 0 0;2621.3 0 0;...
    0 -381 .2;2621.3 -381 .2;2621.3 -411.48 .2;0 -411.48 0;...
    0 -2209.8 0;2621.3 -2209.8 0;2621.3 -2240.3 .2;0 -2240.3 0;...
    0 -3032.8 0;2621.3 -3032.8 0;2621.3 -3063.2 .2;0 -3063.2 0;...
    0 -3855.7 0;2621.3 -3855.7 0;2621.3 -3886.2 .2;0 -3886.2 0;...
    0 -5684.5 0;2621.3 -5684.5 0;2621.3 -5715 .2;0 -5715 0;...
    2621.3 -6096 0;0 -6096 0];

fc = [2 1 3 4;3 4 5 6;6 5 8 7;7 8 9 10;10 9 12 11; 11 12 13 14;...
    14 13 16 15;15 16 17 18;18 17 20 19;19 20 21 22;21 22 24 23];
cdata = [];
cdata(1:length(fc(:,1)),1:3) = 1;
cdata([4,8],1:2) = 0;
cdata([2,6,10],2:3) = 0;
ic = patch('parent',ax,'tag','ice','facevertexcdata',cdata,'facecolor','flat','edgecolor','none','facelighting','phong',...
    'vertices',vr,'faces',fc,'userdata',[],'buttondownfcn','grips(''buttondown'')','clipping','off');

%the walls
[x,y,z] = sphere(20);
x = abs(x(11,1:6)*396.24*2);
x = abs(x-max(x));
y = abs(y(11,1:6)*396.24*2);
y = abs(y-max(y));



xlim = [min(vr(:,1)),max(vr(:,1))];
ylim = [min(vr(:,2)),max(vr(:,2))];
xdata = [];
ydata = [];
zdata = [];

for i = 1:5
    switch i
        case 1
            pt = [xlim(1),ylim(1)];
            xd = x+pt(1);
            yd = y+pt(2);
            pt = pt-30;
        case 2
            pt = [xlim(2),ylim(1)];
            xd = -fliplr(x)+pt(1);
            yd = fliplr(y)+pt(2);
            pt(1) = pt(1)+30;
            pt(2) = pt(2)-30;
        case 3
            pt = [xlim(2),ylim(2)];
            xd = -x+pt(1);
            yd = -y+pt(2);
            pt = pt+30;
        case 4
            pt = [xlim(1),ylim(2)];
            xd = fliplr(x)+pt(1);
            yd = -fliplr(y)+pt(2);
            pt(1) = pt(1)-30;
            pt(2) = pt(2)+30;
        case 5
            pt = [xlim(1),ylim(1)];
            xd = x(1)+pt(1);
            yd = y(1)+pt(2);
            pt = pt-30;
    end

    xd = [xd;xd];
    xd(3:4,:) = pt(1);
    yd = [yd;yd];
    yd(3:4,:) = pt(2);
    zd = zeros(size(xd));
    zd(2:end-1,:) = 100;
    xdata = [xdata,xd];
    ydata = [ydata,yd];
    zdata = [zdata,zd];

end

brd = surface('parent',ax,'xdata',xdata,'ydata',ydata,'zdata',zdata,'facecolor',[.3 .3 .9],'edgecolor','none','facelighting','phong','clipping','off','buttondownfcn',get(ax,'buttondownfcn'),'tag','ice');

