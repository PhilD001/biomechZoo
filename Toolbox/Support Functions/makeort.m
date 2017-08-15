function [o,z,y,x]= makeort(data,root)

bone0 = clean(data.([root,'0']).line);
bone1 = clean(data.([root,'0']).line);
bone2 = clean(data.([root,'0']).line);
bone3 = clean(data.([root,'0']).line);

o = bone0;
z = bone1-o;
y = bone2-o;
x = bone3-o;