function comparePiG(data,segment,mO,mA,mL,mP)

if nargin==4
    mL = [];
    mP = [];
else
    R = [];
    L = [];
end

switch segment
    
    case 'Pelvis'
        seg = 'PEL';
        
    case 'Left Femur'
        seg = 'LFE';
        
    case 'Left Tibia'
        seg = 'LTI';
        
    case 'Left Foot';
        seg = 'LFO';
        
    case 'Right Femur'
        seg = 'RFE';
        
    case 'Right Tibia'
        seg = 'RTI';
        
    case 'Right Foot'
        seg = 'RFO';
        
    case 'HipJC'
        seg = [];
        joint = segment(1:end-2);
        suf = 'HJC';
        R = mO;
        L = mA;
        
    case 'KneeJC'
        seg = [];
        joint = segment(1:end-2);
        suf = 'FEO';
        R = mO;
        L = mA;
        
    case 'AnkleJC'
        seg = [];
        joint = segment(1:end-2);
        suf = 'TIO';
        R = mO;
        L = mA;
end

if ~isempty(seg)
    
    O = data.([seg,'O']).line;
    A = data.([seg,'A']).line;
    L = data.([seg,'L']).line;
    P = data.([seg,'P']).line;
    
    rO = rmse(O,mO);
    rA = rmse(A,mA);
    rL = rmse(L,mL);
    rP = rmse(P,mP);
    
    
    figure
    subplot(2,2,1)
    plot(O)
    hold on
    plot(mO)
    title([seg,'O',' RMS diff = ',num2str(rO)])
    
    
    subplot(2,2,2)
    plot(A)
    hold on
    plot(mA)
    title([seg,'A',' RMS diff = ',num2str(rA)])
    
    subplot(2,2,3)
    plot(L)
    hold on
    plot(mL)
    title([seg,'L',' RMS diff = ',num2str(rL)])
    
    subplot(2,2,4)
    plot(P)
    hold on
    plot(mP)
    title([seg,'P',' RMS diff = ',num2str(rP)])
    
else
    side = {'R','L'};
    
    for i = 1:length(side)
        
        if i==1
            d = R;
        else
            d = L;
        end
        
        f = figure;
        set(f,'name',[side{i},' side ', joint])
        
        subplot(1,3,1)
        plot(d(:,1))
        hold on
        plot(data.([side{i},suf]).line(:,1))
        title('x')
        ylabel(joint)
        r = mean(d(:,1) - data.([side{i},suf]).line(:,1));
        text(1,mean(data.([side{i},suf]).line(:,1)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,2)
        plot(d(:,2))
        hold on
        plot(data.([side{i},suf]).line(:,2))
        title('y')
        r = mean(d(:,2) - data.([side{i},suf]).line(:,2));
        text(1,mean(data.([side{i},suf]).line(:,2)),['Diff = ',num2str(r),' mm'])
        
        subplot(1,3,3)
        plot(d(:,3))
        hold on
        plot(data.([side{i},suf]).line(:,3))
        title('z')
        r = mean(d(:,3) - data.([side{i},suf]).line(:,3));
        text(1,mean(data.([side{i},suf]).line(:,3)),['Diff = ',num2str(r),' mm'])
        legend('Matlab','PiG')
        
    end
end
