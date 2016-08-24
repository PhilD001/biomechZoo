function r = euler2unit(eu);

eu = eu*pi/180;

t(1,1) = cos(eu(2))*cos(eu(3));
t(1,2) = sin(eu(1))*sin(eu(2))*cos(eu(3))+cos(eu(1))*sin(eu(3));
t(1,3) = -cos(eu(1))*sin(eu(2))*cos(eu(3))+sin(eu(1))*sin(eu(3));
t(2,1) = -cos(eu(2))*sin(eu(3));
t(2,2) = -sin(eu(1))*sin(eu(2))*sin(eu(3))+cos(eu(1))*cos(eu(3));
t(2,3) = cos(eu(1))*sin(eu(2))*sin(eu(3))+sin(eu(1))*cos(eu(3));
t(3,1) = sin(eu(2));
t(3,2) = -sin(eu(1))*cos(eu(2));
t(3,3) = cos(eu(1))*cos(eu(2));

gunit = [1 0 0;0 1 0;0 0 1];
r = makeunit(t*gunit);
   