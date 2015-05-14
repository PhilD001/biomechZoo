function varargout = calcsphere(data)
mn = mean(data);

pa = mn(1);
pb = mn(2);
pc = mn(3);

%calculating the initial Energy and radius

L = sqrt((data(:,1)-pa).*(data(:,1)-pa) + (data(:,2)-pb).*(data(:,2)-pb) ...
    + (data(:,3)-pc).*(data(:,3)-pc));

pr = mean(L);

Eprv = L-pr;
Eprv = Eprv'*Eprv;

Estk = Eprv;
calcnum = 1;



while 1
    La = mean((pa-data(:,1))./L);
    Lb = mean((pb-data(:,2))./L);
    Lc = mean((pc-data(:,3))./L);
    mL = mean(L);

    na = mn(1) + mL*La;
    nb = mn(2) + mL*Lb;
    nc = mn(3) + mL*Lc;

    L = sqrt((data(:,1)-na).*(data(:,1)-na) + (data(:,2)-nb).*(data(:,2)-nb) ...
        + (data(:,3)-nc).*(data(:,3)-nc));

    nr = mean(L);
    Enxt = L-nr;
    Enxt = Enxt'*Enxt;
    calcnum = calcnum+1;
    Estk = [Estk;Enxt];

    if calcnum >= 3
        if Estk(end) >= Estk(end-2)
            break
        end
    end
    pa = na;
    pb = nb;
    pc = nc;
    pr = nr;
end
varargout{1} = [pa pb pc];
varargout{2} = pr;