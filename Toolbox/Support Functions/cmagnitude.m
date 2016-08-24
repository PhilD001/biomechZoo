function r = cmagnitude(m)

m = m(2:end,:)-m(1:end-1,:);
r = sqrt(diag(m*m'));
r = [0;r];