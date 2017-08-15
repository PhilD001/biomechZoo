function vectlabel(p1,p2,color,label)

x0 = p1(1);
x1 = p2(1);

y0 = p1(2);
y1 = p2(2);

if length(p1)==3
    
    z0 = p1(3);
    z1 = p2(3);
    
    text(mean([x0 x1]),mean([y0 y1]),mean([z0 z1]),label,'color',color); 
else
    text(mean([x0 x1]),mean([y0 y1]),label,'color',color);
end