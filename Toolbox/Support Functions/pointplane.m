function r = pointplane(action,pt,pln);

switch action
    case 'intersect'
        a = pln(1,:);
        b = pln(2,:);
        c = pln(3,:);

        alpha = cross(a,b)+cross(b,c)+cross(c,a);
        alpha = makeunit(alpha);

        vec = a-pt;
        m = dot(alpha,vec);
        vec = m*alpha;
        r = vec+pt;
    case 'distance'
        a = pln(1,:);
        b = pln(2,:);
        c = pln(3,:);

        alpha = cross(a,b)+cross(b,c)+cross(c,a);
        alpha = makeunit(alpha);

        vec = a-pt;
        r = abs(dot(alpha,vec));
end